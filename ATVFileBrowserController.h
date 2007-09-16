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
#import <BackRow/BackRow.h>

#import "ATVFDirectoryContents.h"
#import "ATVFilesAppliance.h"

#define ATVFileBrowserControllerLabel @"net.ericiii.ATVFiles.FileBrowserController"

extern const double ATVFilesVersionNumber;
extern const unsigned char ATVFilesVersionString[];

@interface ATVFileBrowserController : BRMediaMenuController {
  NSString *_directory;
  ATVFDirectoryContents *_contents;
  BOOL _restoreSampleRate;
  float _previousSampleRate;
  CFTypeRef _previousPassthroughPreference;
  BOOL _previousSoundEnabled;
  BOOL _initialController;
  
#ifdef DEBUG
  BRTextLayer *_debugTag;
#endif
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory;
-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory useFolderNameForTitle:(BOOL)useFolderName;
-(void)playAsset:(ATVFMediaAsset *)asset;
-(void)playPlaylist:(ATVFPlaylistAsset *)asset;

#ifdef DEBUG
-(void)_debugOptionsMenu;
-(void)_addDebugTag;
-(void)_removeDebugTag;
#endif
@end
