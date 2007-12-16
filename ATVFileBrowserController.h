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
  BOOL _isPlacesMenu;
  
#ifdef DEBUG
  BRTextLayer *_debugTag;
#endif
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory;
-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory useNameForTitle:(BOOL)useFolderName;
-(ATVFileBrowserController *)initWithScene:(id)scene usePlacesTitle:(BOOL)usePlacesTitle;
-(void)playAsset:(ATVFMediaAsset *)asset;
-(void)playPlaylist:(ATVFPlaylistAsset *)asset;

-(void)refreshMenu;

#ifdef DEBUG
// -(void)_debugOptionsMenu;
-(void)_addDebugTag;
-(void)_removeDebugTag;
#endif
@end
