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
#import "ATVFMusicPlayer.h"
#import "ATVFPlayerManager.h"
#import "BRMusicNowPlayingController+SetPlayer.h"
#import "ATVFMediaAsset.h"
#import "ATVFPlaylistAsset.h"
#import "config.h"
#import <BackRow/BREvent.h>
#import "ATVFContextMenu.h"
#import "ATVFPreferences.h"
#import "ATVFPlaylistPlayer.h"
#import "ATVFVideoPlayerController.h"
#import "ATVFMetadataPreviewController.h"
#import "ATVFPlacesContents.h"

@interface ATVFileBrowserController (Private)
-(BOOL)getUISounds;
-(void)setUISounds:(BOOL)sounds;
-(void)_resetDividers;
@end

// compatilbility
@interface BRSettingsFacade (AppleTV11Compatibility)
-(BOOL)UISoundsEnabled;
-(void)setUISoundsEnabled:(BOOL)fp8;
+(id)sharedInstance;
@end

@implementation ATVFileBrowserController

// create our menu!
-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory {
  return [self initWithScene:scene forDirectory:directory useNameForTitle:YES];
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory useNameForTitle:(BOOL)useFolderName {
  //LOG(@"In ATVFileBrowserController for Directory: %@", directory);
  [super initWithScene:scene];
  
  [self addLabel:ATVFileBrowserControllerLabel];
  
  if(useFolderName) {
    NSString *title = [directory lastPathComponent];
    [self setListTitle:title];
    _initialController = NO;
  } else {
    [self setListTitle:BRLocalizedString(@"Files", "ATVFiles app name (should match CFBundleName)")];
    _initialController = YES;
  }
  
  _directory = directory;
  [_directory retain];
  _contents = [[ATVFDirectoryContents alloc] initWithScene:scene forDirectory:directory];
  [[self list] setDatasource:_contents];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMountsDidChangeNotification:) name:ATVFMountsDidChangeNotification object:[[self list] datasource]];

  // reset the dividers
  [self _resetDividers];
  
  _restoreSampleRate = NO;
  return self;
}

// Initialize with places menu
-(ATVFileBrowserController *)initWithScene:(id)scene usePlacesTitle:(BOOL)usePlacesTitle {
  [super initWithScene:scene];
  [self addLabel:ATVFileBrowserControllerLabel];
  
  NSString *title;
  enum kATVFPlacesMode mode;
  
  if(usePlacesTitle) {
    title = BRLocalizedString(@"Places", "Places menu title and option");
    mode = kATVFPlacesModeFull;
  } else {
    title = BRLocalizedString(@"Files", "ATVFiles app name (should match CFBundleName)");
    
    NSString *modePref = [[ATVFPreferences preferences] stringForKey:kATVPrefPlacesMode];
    if([modePref isEqual:kATVPrefPlacesModeVolumes]) {
      mode = kATVFPlacesModeVolumesOnly;
    } else if([modePref isEqual:kATVPrefPlacesModeEnabled]) {
      mode = kATVFPlacesModeFull;
    }
  }
  
  [self setListTitle:title];
  
  _directory = @"x-atvfiles-places://";
  [_directory retain];
  _contents = [[ATVFPlacesContents alloc] initWithScene:scene mode:mode];
  [[self list] setDatasource:_contents];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMountsDidChangeNotification:) name:ATVFMountsDidChangeNotification object:[[self list] datasource]];

  // reset the dividers
  [self _resetDividers];
  
  _restoreSampleRate = NO;
  return self;
}

// -(BOOL)isVolatile {
//   LOG(@"In -ATVFileBrowserController isVolatile");
//   return YES;
// }

-(void)dealloc {
  //LOG(@"In ATVFileBrowserController -dealloc, %@", _directory);
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  //LOG(@"Contents release");
  [_contents release];
  //LOG(@"Directory release");
  [_directory release];
  //LOG(@"Super release");
  
  [super dealloc];  
}

-(long)defaultIndex {
  return [[[self list] datasource] defaultIndex];
}

// handler when a menu item is clicked
- (void)itemSelected:(long)index {
  // get the ATVFMediaAsset for the index
  id asset = [[[self list] datasource] mediaForIndex:index];
  
  LOG(@"Asset item selected: %@", [asset mediaURL]);

  // either go to a folder or play
  if([asset isDirectory]) { // asset is folder
    // load the next controller
    NSString *theDirectory = [[NSURL URLWithString:[asset mediaURL]] path];
    ATVFileBrowserController *folder = [[[ATVFileBrowserController alloc] initWithScene:[self scene] forDirectory:theDirectory] autorelease];
    [folder setListIcon:[self listIcon]];
    [[self stack] pushController:folder];
  } else if([asset isPlaylist]) {
    [self playPlaylist:asset];
  } else {
    [self playAsset:asset];
  }
}

-(void)playPlaylist:(ATVFPlaylistAsset *)asset {
  ATVFPlayerType playerType = [ATVFPlayerManager playerTypeForAsset:[[asset playlistContents] objectAtIndex:0]];
  if(playerType == kATVFPlayerMusic) {
    // just tell the player it's a playlist
    id player = [ATVFPlayerManager playerForType:kATVFPlayerMusic];
    [player setPlaylist:asset];
    id controller = [[[BRMusicNowPlayingController alloc] initWithScene:[self scene]] autorelease];
    [controller setPlayer:player];
    [[self stack] pushController:controller];
    [player initiatePlayback:nil];
  } else {
#ifdef USE_NEW_PLAYLIST_THING
    // play in the new ATVFPlaylistPlayer thing
    ATVFPlaylistPlayer *controller = [[[ATVFPlaylistPlayer alloc] initWithScene:[self scene] playlist:asset] autorelease];
    [[ATVFPlayerManager musicPlayer] stop];
#else
    // set up video player here
    id player = [ATVFPlayerManager playerForType:kATVFPlayerVideo];
    [player setMedia:asset error:nil];
    id controller = [[[ATVFVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    [controller setAllowsResume:YES];
    [controller setVideoPlayer:player];
#endif
    [[self stack] pushController:controller];
  }
}

// handle playback of an asset
-(void)playAsset:(ATVFMediaAsset *)asset {
  // play it here
  NSError *error = nil;
  
  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) {
    //LOG(@"Enabling AC3 Passthrough...");
    // set the audio output sample rate as appropriate
    // _previousPassthroughPreference = [ATVFCoreAudioHelper getPassthroughPreference];
    _previousSoundEnabled = [self getUISounds];
    [self setUISounds:NO];
    // [ATVFCoreAudioHelper setPassthroughPreference:kCFBooleanTrue];
  } // ac3 passthrough setup
  
  // get the player for this asset
  ATVFPlayerType playerType = [ATVFPlayerManager playerTypeForAsset:asset];
  id player = [ATVFPlayerManager playerForType:playerType];
  //LOG(@"Player type: %d, player: (%@)%@", playerType, [player class], player);
  
  id controller;
  if(playerType == kATVFPlayerMusic) {
    // set up music player here
    controller = [[[BRMusicNowPlayingController alloc] initWithScene:[self scene]] autorelease];
    [player setMedia:asset inTracklist:[NSMutableArray arrayWithObject:asset] error:&error];
    if(error) {
      ELOG(@"Unable to set player with error: %@", error);
      return;
    } else {
      [controller setPlayer:player];
      if(error) ELOG(@"Error initiating playback: %@", error);
    }
  } else if(playerType == kATVFPlayerVideo) {
    // set up video player here
    [player setMedia:asset error:&error];
    controller = [[[ATVFVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    [controller setAllowsResume:YES];
    [controller setVideoPlayer:player];
    
    // stop audio playback
    [[ATVFPlayerManager musicPlayer] stop];
  }
  
  [[self stack] pushController:controller];
  
  // id result = [controller blurredVideoFrame];
  // LOG(@"Blurred Video Frame: (%@)%@", [result class], result);
  
  if(playerType == kATVFPlayerMusic) 
    [player initiatePlayback:&error];
}

// this just restores the sample rate and passthrough preference
-(void)resetSampleRate {
  if(_restoreSampleRate) {
    //LOG(@"Restoring sample rate to %f", _previousSampleRate);
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
  ATVFMediaAsset *asset = [[[self list] datasource] mediaForIndex:index];
  
  if([asset isDirectory] || [asset isPlaylist]) {
    //LOG(@"Directory or playlist asset, getting asset list for parade...");
    // asset parade
    NSArray *contents = nil;
    
    if([asset isPlaylist]) {
      contents = [(ATVFPlaylistAsset *)asset playlistContents];
    } else if([asset isDirectory]) {
      NSString *theDirectory = [[NSURL URLWithString:[asset mediaURL]] path];
      contents = [[[[ATVFDirectoryContents alloc] initWithScene:[self scene] forDirectory:theDirectory] autorelease] assets];
    }
    
    if(contents) {
      //LOG(@"Contents: %@", contents);
      
      id result = nil;
      
      NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hasCoverArt == YES"]];
      //LOG(@"Filtered contents: %@", filteredContents);
      
      // Only show if it's not an empty folder
      if([filteredContents count] > 0) {
        result = [BRMediaPreviewControllerFactory previewControllerForAssets:filteredContents withDelegate:self scene:[self scene]];
        // result = [BRMediaPreviewControllerFactory _paradeControllerForAssets:contents delegate:self scene:[self scene]];
        
        if([result isKindOfClass:[BRCoverArtPreviewController class]]) {
          // NOTE: BUG WORKAROUND
          // This is a workaround for the ATV 1.1 BackRow bug(?) that will not refresh images in the
          // asset list of this controller, but instead just duplicate the list.  This basically
          // forces a refresh of the preview controller on an appropriate notification.
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePreviewController) name:@"BRAssetImageUpdated" object:nil];
        } else {
          [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BRAssetImageUpdated" object:nil];
        }
      }
      
      return result;
    } else {
      return nil;
    }
  } else {
    //LOG(@"Normal asset without parade...");
    // traditional display
    ATVFMetadataPreviewController *result = [[[ATVFMetadataPreviewController alloc] initWithScene:[self scene]] autorelease];
    [result setAsset:[[[self list] datasource] mediaForIndex:index]];
    [result activate];
    
    return result;
  }
}

// Hook for right menu click
-(BOOL)brEventAction:(BREvent *)action {
  // LOG(@"in -brEventAction:%@", action);
  
  switch([action pageUsageHash]) {
    BREVENT_RIGHT:; 
      if([[self stack] peekController] != self)
        return NO;
      
      // context menu
      BRListControl *list = [self list];
      ATVFMediaAsset *asset = [_contents mediaForIndex:[list selection]];

      //LOG(@"Context menu button pressed!");
      //LOG(@" List: (%@)%@", [list class], list);
      //LOG(@"  Selected: %d", [list selection]);
      
      //LOG(@" Selected asset: (%@)%@ <%@>", [asset class], asset, [asset mediaURL]);
      
      ATVFContextMenu *contextMenu = [[[ATVFContextMenu alloc] initWithScene:[self scene] forAsset:asset] autorelease];
      [contextMenu setListIcon:[self listIcon]];
      [[self stack] pushController:contextMenu];
      
      return YES;
      break;
  }
  
  
  return [super brEventAction:action];
}

// this is called before redrawing it after something else has been shown.
// the other controller is still on top of the stack now
// refresh the directory here.
-(void)willBeExhumed {
  [self refreshMenu];
    
  [self resetSampleRate];

  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) {
    [self setUISounds:_previousSoundEnabled];
    // [ATVFCoreAudioHelper setPassthroughPreference:_previousPassthroughPreference];
  } // ac3 passthrough setup
  
# ifdef DEBUG
  [self _addDebugTag];
# endif
  [super willBeExhumed];

}

#ifdef DEBUG
// called before hiding the menu
// just remove our test overlay
-(void)willBeBuried {
  [self _removeDebugTag];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[[self list] datasource]];
  
  [super willBeBuried];
}

-(void)willBePushed {
  [self _addDebugTag];
  [super willBePushed];
}

-(void)willBePopped {
  if(_initialController) {
    //LOG(@"In willBePopped");
    
    // stop playing
    [[ATVFPlayerManager musicPlayer] stop];
  }
  [self _removeDebugTag];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[[self list] datasource]];
  
  [super willBePopped];
}

-(void)_addDebugTag {
  if(!_debugTag) {
    // create the tag
    _debugTag = [BRTextLayer layerWithScene:[self scene]];
    NSString *lblText = [[NSString stringWithString:@"DEBUG BUILD\n"] stringByAppendingString:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSAttributedString *lbl = [[[NSAttributedString alloc] initWithString:lblText attributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]] autorelease];
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

// helpers for toggling ui sounds.
// these changed in 1.0 to 1.1, from
//  [BRSettingsFacade settingsFacade] soundEnabled]
// to
//  [BRSettingsFacade sharedInstance] UISoundsEnabled]
-(BOOL)getUISounds {
#ifdef ENABLE_1_0_COMPATABILITY
  if([BRSettingsFacade respondsToSelector:@selector(settingsFacade)]) {
    // 1.0
    return [[BRSettingsFacade settingsFacade] soundEnabled];
    
  } else if([BRSettingsFacade instancesRespondToSelector:@selector(UISoundsEnabled)]) {
    // 1.1
#endif
    return [[BRSettingsFacade sharedInstance] UISoundsEnabled];
#ifdef ENABLE_1_0_COMPATABILITY
  } else {
    ELOG(@"Running on unknown Apple TV OS, can't get UI sound settings!");
    return YES;
  }
#endif
}

-(void)setUISounds:(BOOL)sounds {
#ifdef ENABLE_1_0_COMPATABILITY
  if([BRSettingsFacade respondsToSelector:@selector(settingsFacade)]) {
    // 1.0
    [[BRSettingsFacade settingsFacade] setSoundEnabled:sounds];
  } else if([BRSettingsFacade instancesRespondToSelector:@selector(UISoundsEnabled)]) {
#endif
    // 1.1
    [[BRSettingsFacade sharedInstance] setUISoundsEnabled:sounds];
#ifdef ENABLE_1_0_COMPATABILITY
  } else {
    ELOG(@"Running on unknown Apple TV OS, can't set UI sound settings!");
  }
#endif
}

-(void)refreshMenu {
  //id selectedObject = [self selectedObject];
  [[[self list] datasource] refreshContents];
  //[[self list] reload];
  [self _resetDividers];
  //[[self scene] renderScene];
  [self refreshControllerForModelUpdate];
  
  //[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[[self list] datasource]];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMountsDidChangeNotification:) name:ATVFMountsDidChangeNotification object:[[self list] datasource]];
  
  // reset the dividers

  // force a redraw
  //[self setSelectedObject:selectedObject];
  //[[self list] setRenderSelection:[[self list] renderSelection]];
  //[[self scene] renderScene];
}

-(void)_handleMountsDidChangeNotification:(NSNotification *)notification {
  LOG(@"In -_handleMountsDidChangeNotification: %@", notification);
  
  [self refreshMenu];
}

-(void)_resetDividers {
  [[self list] removeDividers];
  long separatorIndex = [[[self list] datasource] separatorIndex];
  if(separatorIndex != -1) [[self list] addDividerAtIndex:separatorIndex];  
}
@end
