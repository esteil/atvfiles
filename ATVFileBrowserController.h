//
//  ATVFileBrowserController.h
//  ATVFiles
//  
//  This is the primary menu controller for browsing files.
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BRMenuController.h>
#import <BRQTKitVideoPlayer.h>
#import <BRVideoPlayerController.h>
#import <BRMediaPlayerManager.h>

#import "ATVDirectoryContents.h"

@interface ATVFileBrowserController : BRMenuController {
  NSString *_directory;
  ATVDirectoryContents *_contents;
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory;

@end
