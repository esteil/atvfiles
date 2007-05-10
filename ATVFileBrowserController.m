//
//  ATVFileBrowserController.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFileBrowserController.h"
#import "ATVBRMetadataExtensions.h"
#import "ATVFCoreAudioHelper.h"

@implementation ATVFileBrowserController

// create our menu!
-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory {
  return [self initWithScene:scene forDirectory:directory useFolderNameForTitle:YES];
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory useFolderNameForTitle:(BOOL)useFolderName {
  [super initWithScene:scene];
  
  if(useFolderName) {
    NSString *title = [directory lastPathComponent];
    [self setListTitle:title];
  } else {
    [self setListTitle:BRLocalizedString(@"Files", "ATVFiles app name (should match CFBundleName)")];
  }
  
  _directory = directory;
  _contents = [[ATVDirectoryContents alloc] initWithScene:scene forDirectory:directory];
  [[self list] setDatasource:_contents];
  
  _restoreSampleRate = NO;
  return self;
}

// handler when a menu item is clicked
- (void)itemSelected:(long)index {
  // get the ATVMediaAsset for the index
  id asset = [[[self list] datasource] mediaForIndex:index];
  
  LOG(@"Asset item selected: %@", [asset mediaURL]);

  // either go to a folder or play
  if([asset isDirectory]) { // asset is folder
    // load the next controller
    NSString *theDirectory = [[NSURL URLWithString:[asset mediaURL]] path];
    ATVFileBrowserController *folder = [[[ATVFileBrowserController alloc] initWithScene:[self scene] forDirectory:theDirectory] autorelease];
    [folder setListIcon:[self listIcon]];
    [_stack pushController:folder];

  } else {
    // play it here
    NSError *error = nil;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefEnableAC3Passthrough]) {
      LOG(@"Enabling AC3 Passthrough...");
      // set the audio output sample rate as appropriate
      _previousPassthroughPreference = [ATVFCoreAudioHelper getPassthroughPreference];
    } // ac3 passthrough setup
    
    // get the player for this asset
    id player = [BRMediaPlayerManager playerForMediaAsset:asset error:&error];
    [player setMedia:asset error:&error];
    LOG(@"Player: (%@)%@, error %@", [player class], player, error);

    // FIXME: choose the right controller for video or other
    id controller;
    controller = [[[BRVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    [controller setAllowsResume:YES];
    [controller setVideoPlayer:player];
    
    [_stack pushController:controller];
  }
}

// this just restores the sample rate and passthrough preference
-(void)resetSampleRate {
  if(_restoreSampleRate) {
    LOG(@"Restoring sample rate to %f", _previousSampleRate);
    // reset sample rate
    if(![ATVFCoreAudioHelper setSystemSampleRate:_previousSampleRate]) {
      ELOG(@"Unable to restore sample rate");
    }
    
    // restore preference
    [ATVFCoreAudioHelper setPassthroughPreference:_previousPassthroughPreference];
    if(_previousPassthroughPreference) {
      CFRelease(_previousPassthroughPreference);
      _previousPassthroughPreference = nil;
    }
    
    _restoreSampleRate = NO;
  }
}


// method to display a preview controller
-(id)previewControllerForItem:(long)index {
  BRMetadataPreviewController *result = [[[BRMetadataPreviewController alloc] initWithScene: [self scene]] autorelease];
  [result setAsset:[[[self list] datasource] mediaForIndex:index]];
  [result activate];
/*  [result setShowsMetadataImmediately:YES];*/
  BRMetadataLayer *metadataLayer = [result metadataLayer];
  LOG(@"MDLayer: (%@)%@", [metadataLayer class], metadataLayer);
  LOG(@"Lables: %@, Objs: %@", [metadataLayer metadataLabels], [metadataLayer metadataObjects]);
  [metadataLayer setMetadata:[NSArray arrayWithObject:@"BlahBlah"] withLabels:[NSArray arrayWithObject:@"Label"]];
  LOG(@"Lables: %@, Objs: %@", [metadataLayer metadataLabels], [metadataLayer metadataObjects]);
  
  LOG(@"In -previewControllerForItem:%d, returning: (%@)%@", index, [result class], result);
  
  return result;
}

// easter egg!
// up up down down left right left right
// 140 140 141 141 139 138 139 138
-(BOOL)brEventAction:(BREvent *)action {
  static int step = 0;
  int cmd = 0;
  
  if([action value] == 1) {
    switch(step) {
      case 0:
        step = ([action usage] == 140) ? step + 1 : 0;
        break;
      case 1:
        step = ([action usage] == 140) ? step + 1 : 0;
        break;
      case 2:
        step = ([action usage] == 141) ? step + 1 : 0;
        break;
      case 3:
        step = ([action usage] == 141) ? step + 1 : 0;
        break;
      case 4:
        step = ([action usage] == 139) ? step + 1 : 0;
        break;
      case 5:
        step = ([action usage] == 138) ? step + 1 : 0;
        break;
      case 6:
        step = ([action usage] == 139) ? step + 1 : 0;
        break;
      case 7:
        step = ([action usage] == 138 || [action usage] == 139) ? step + 1 : 0;
        if([action usage] == 139) cmd = 1;
        break;
      default:
        step = 0;
        break;
    }
    
    // display it here!
    if(step == 8) {
      if(cmd == 0) {
        // easter egg
        NSString *shortVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        BRAlertController *alert = [BRAlertController alertOfType:0
                   titled:@"ATVFiles Important Information"
              primaryText:[NSString stringWithFormat:@"Version: %@ (%@)%@", shortVersion, [NSNumber numberWithFloat:ATVFilesVersionNumber], 
#ifdef DEBUG
              @"\nDEBUG BUILD"
#else
              @""
#endif
            ]
            secondaryText:[NSString stringWithFormat:@"Copyright (C) 2007 Eric Steil III (ericiii.net)\n\nSpecial Thanks: alan_quatermain\n\n%s", ATVFilesVersionString]
                withScene:[self scene]];
        [alert setHasGoBackControl:YES];

        [_stack pushController:alert];
      } else if(cmd == 1) {
#ifdef DEBUG
        [self _debugOptionsMenu];
#endif
      }
      step = 0;
    }
  }
  
  return [super brEventAction:action];
}

#ifdef DEBUG
-(void)_debugOptionsMenu {
  // stupid diagnostics thing, ONLY ENABLED IN DEBUG MODE
  BROptionDialog *dialog = [[BROptionDialog alloc] initWithScene:[self scene]];
  [dialog setTitle:@"Special Secret Sauce"];
  [dialog setIcon:[self listIcon] horizontalOffset:0 kerningFactor:0];
  [dialog setPrimaryInfoText:@"Special options, just for fun!"];
  [dialog setHasGoBackControl:YES];

  [dialog addOptionText:@"remove purple box"];
  [dialog addOptionText:@"overlay purple box"];
  [dialog addOptionText:@"display release/grab"];
  [dialog addOptionText:@"Option 3"];
  [dialog addOptionText:@"Option 4"];

  [dialog setActionSelector:@selector(optionDialogActionSelector:) target:self];

  [_stack pushController:dialog];
}

-(void)optionDialogActionSelector:(id)evt {
  int index = [evt selectedIndex];
  static BRQuadLayer *white;
  if(index == 0) {
    if(white) {
      [white removeFromSuperlayer];
      [white release];
      white = nil;
      [_scene renderScene];
    }
  } else if(index == 1) {
/*    BRLayerController *layer = [BRLayerController layerControllerWithScene:[self scene]];*/

/*    [[layer masterLayer] setAlphaValue:0.5];
    [[layer masterLayer] setFrame:NSMakeRect(0, 0, 900, 200)];
*/  
    if(!white) {
      white = [BRQuadLayer layerWithScene:[self scene]];
      [white retain];
      [[_scene root] insertSublayer:white above:[self masterLayer]];
    }
    
    [white setRedColor:1.0 greenColor:0.0 blueColor:1.0];
    [white setFrame:NSMakeRect(50, 50, 500, 500)];
    [white setAlphaValue:0.5];
    [_scene renderScene];

/*    [_stack pushController:layer];*/
  } else if(index == 2) {
	// display release/grab
	  [[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerStopRenderingNotification"
														  object:[BRDisplayManager sharedInstance]];
	  LOG(@"Releasing All Dsiplays");
	  [[BRDisplayManager sharedInstance] releaseAllDisplays];
	  
	  LOG(@"Sleeping for 5s");
	  CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5.0, FALSE);
	  //sleep(5);
	  
	  LOG(@"Capturing all displays");
	  [[BRDisplayManager sharedInstance] captureAllDisplays];
	  [[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerResumeRenderingNotification"
														  object:[BRDisplayManager sharedInstance]];
	  
//	  [_scene renderScene];
  }
}
#endif

// this is called before redrawing it after something else has been shown.
// refresh the directory here.
-(void)willBeExhumed {
  [[[self list] datasource] refreshContents];
  [[self list] reload];
  
  [self resetSampleRate];

#ifdef DEBUG
  [self _addDebugTag];
#endif
  [super willBeExhumed];
}

#ifdef DEBUG
// called before hiding the menu
// just remove our test overlay
-(void)willBeBuried {
  [self _removeDebugTag];
  [super willBeBuried];
}

-(void)willBePushed {
  [self _addDebugTag];
  [super willBePushed];
}

-(void)willBePopped {
  [self _removeDebugTag];
  [super willBePopped];
}

-(void)_addDebugTag {
  if(!_debugTag) {
    // create the tag
    _debugTag = [BRTextLayer layerWithScene:[self scene]];
    NSString *lblText = [[NSString stringWithString:@"DEBUG BUILD\n"] stringByAppendingString:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSAttributedString *lbl = [[NSAttributedString alloc] initWithString:lblText attributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    [_debugTag setAttributedString:lbl];
/*    LOG(@"DEBUG TAG: %@, size: %@, max: %@", _debugTag, NSStringFromSize([_debugTag renderedSize]), NSStringFromSize([_debugTag maxSize]));*/
    [_debugTag retain];
    
    // figure out where to put it
    NSRect displayFrame = [[self masterLayer] frame];
    NSSize labelSize = [_debugTag renderedSize];
    float height = labelSize.height;
    float width = labelSize.width;
    float x = (displayFrame.size.width * 0.05);
    float y = displayFrame.size.height - ((displayFrame.size.height * 0.05) + height);
    NSRect labelFrame = NSMakeRect(x, y, width, height);

    // and add it to the display
    [_debugTag setFrame:labelFrame];
    [[[self scene] root] insertSublayer:_debugTag above:[self masterLayer]];
  }
}

-(void)_removeDebugTag {
  if(_debugTag) {
    // rmeove it from the render scene
    [_debugTag removeFromSuperlayer];
    // and let go of it
    [_debugTag release];
    _debugTag = nil;
  }
}
#endif

@end
