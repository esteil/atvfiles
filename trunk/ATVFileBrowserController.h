//
// ATVFileBrowserController.h
// ATVFiles
//  
// This is the primary menu controller for browsing files.
//
// Created by Eric Steil III on 3/29/07.
// Copyright (C) 2007-2008 Eric Steil III
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>

#import "ATVFDirectoryContents.h"
#import "ATVFilesAppliance.h"
#import <SapphireCompatClasses/SapphireMediaMenuController.h>

#define ATVFileBrowserControllerLabel @"net.ericiii.ATVFiles.FileBrowserController"

extern const double ATVFilesVersionNumber;
extern const unsigned char ATVFilesVersionString[];

@interface ATVFileBrowserController : SapphireMediaMenuController {
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
-(void)setInitialController:(BOOL)initial;

#ifdef DEBUG
// -(void)_debugOptionsMenu;
-(void)_addDebugTag;
-(void)_removeDebugTag;
#endif
@end
