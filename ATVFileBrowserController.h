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

#import "ATVDirectoryContents.h"
#import "ATVFilesAppliance.h"

extern const double ATVFilesVersionNumber;
extern const unsigned char ATVFilesVersionString[];

@interface ATVFileBrowserController : BRMediaMenuController {
  NSString *_directory;
  ATVDirectoryContents *_contents;
  BOOL _restoreSampleRate;
  float _previousSampleRate;
  CFTypeRef _previousPassthroughPreference;
  
#ifdef DEBUG
  BRTextLayer *_debugTag;
#endif
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory;
-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory useFolderNameForTitle:(BOOL)useFolderName;

#ifdef DEBUG
-(void)_debugOptionsMenu;
-(void)_addDebugTag;
-(void)_removeDebugTag;
#endif
@end
