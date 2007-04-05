//
//  ATVFileBrowserController.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFileBrowserController.h"
#import <BackRow/BRAlertController.h>

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
    [self setListTitle:BRLocalizedString(@"Files", "ATVFiles app name")];
  }
  
  _contents = [[ATVDirectoryContents alloc] initWithScene:scene forDirectory:directory];
  [[self list] setDatasource:_contents];
  
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
    
    [_stack pushController:folder];

  } else {
    // play it here
    NSError *error = nil;

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

// method to display a preview controller
-(id)previewControllerForItem:(long)index {
  id result = [[[BRMetadataPreviewController alloc] initWithScene: [self scene]] autorelease];
  [result setAsset:[[[self list] datasource] mediaForIndex:index]];
/*  [result setShowsMetadataImmediately:YES];*/
  
  LOG(@"In -previewControllerForItem:%d, returning: (%@)%@", index, [result class], result);
  
  return result;
}

// easter egg!
// up up down down left right left right
// 140 140 141 141 139 138 139 138
-(BOOL)brEventAction:(BREvent *)action {
  static int step = 0;
  
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
        step = ([action usage] == 138) ? step + 1 : 0;
        break;
      default:
        step = 0;
        break;
    }
    
    // display it here!
    if(step == 8) {
      NSString *shortVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
      BRAlertController *alert = [BRAlertController alertOfType:0
                 titled:BRLocalizedString(@"ATVFiles Important Information", "")
            primaryText:[NSString stringWithFormat:BRLocalizedString(@"Version: %@ (%@)", @"Version tag, param 1 is version, param 2 is build"), shortVersion, [NSNumber numberWithFloat:ATVFilesVersionNumber]]
          secondaryText:[NSString stringWithFormat:BRLocalizedString(@"Copyright (C) 2007 Eric Steil III (ericiii.net)\n\nSpecial Thanks: alan_quatermain\n\n%s", @"Copyright stuff"), ATVFilesVersionString]
              withScene:[self scene]];
      [alert setHasGoBackControl:YES];
  
      [_stack pushController:alert];

      step = 0;
    }
  }
  
  return [super brEventAction:action];
}

// this is called before redrawing it after something else has been shown.
// refresh the directory here.
-(void)willBeExhumed {
  [[[self list] datasource] refreshContents];
  [[self list] reload];
  [super willBeExhumed];
}
@end
