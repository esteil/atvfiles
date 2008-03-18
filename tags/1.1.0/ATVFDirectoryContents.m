//
// ATVFDirectoryContents.m
// ATVFiles
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

#import "ATVFDirectoryContents.h"
#import "NSString+FileSizeFormatting.h"
#import "ATVFilesAppliance.h"
#include <sys/types.h>
#include <dirent.h>
#import <AGRegex/AGRegex.h>
#import "ATVFPreferences.h"
#import "ATVFDirectoryContents-Private.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>

@implementation ATVFDirectoryContents

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory {
  return [self initWithScene:scene forDirectory:directory includeDirectories:YES playlists:YES];
}

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory includeDirectories:(BOOL)includeDirectories playlists:(BOOL)includePlaylists {
  return [self initWithScene:scene forDirectory:directory includeDirectories:YES playlists:YES withSorting:YES];
}

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory includeDirectories:(BOOL)includeDirectories playlists:(BOOL)includePlaylists withSorting:(BOOL)withSorting {
  _scene = [scene retain];
  _directory = [[directory stringByAppendingString:@"/"] retain];
  
  _menuItems = [[NSMutableArray alloc] init];
  _assets = [[NSMutableArray alloc] init];
  
  _includeDirectories = includeDirectories;
  _includePlaylists = includePlaylists;
  _doSort = withSorting;
  
  _separatorIndex = -1;
  _defaultIndex = 0;
  [self refreshContents];
  
  return self;
}

// Returns the offset of the separator, or -1 for no separator.
-(long)separatorIndex {
  return _separatorIndex;
}

-(long)defaultIndex {
  return _defaultIndex;
}

// returns an array just like [[NSFileManager defaultManager] directoryContentsAtPath:] except
// implemented using BSD functions.  returns nil when can't open directory.
-(NSArray *)_directoryContents:(NSString *)path {
  NSArray *results = [[NSFileManager defaultManager] directoryContentsAtPath:path];
  results = [results sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  return results;
#if 0  
  DIR *dirp;
  struct dirent *dirc;
  NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
  dirp = opendir([path UTF8String]);
  if(dirp == NULL) {
    return nil;
  }
  
  NSString *name;
  // iterate over the contents
  while((dirc = readdir(dirp)) != NULL) {
    name = [NSString stringWithUTF8String:(dirc->d_name)];
    [result addObject:name];
  }
  
  closedir(dirp);
  
  return result;
#endif
}

-(BOOL)_isValidFilename:(NSString *)name {
  //LOG(@"In _isValidFilename:%@", name);
  // these are borrowed from XBMC
  static NSArray *videoExtensions = nil;
  if(!videoExtensions) videoExtensions = [[[ATVFPreferences preferences] arrayForKey:kATVPrefVideoExtensions] retain];
  static NSArray *audioExtensions = nil;
  if(!audioExtensions) audioExtensions = [[[ATVFPreferences preferences] arrayForKey:kATVPrefAudioExtensions] retain];
  static NSArray *playlistExtensions = nil;
  if(!playlistExtensions) playlistExtensions = [[[ATVFPreferences preferences] arrayForKey:kATVPrefPlaylistExtensions] retain];
  static NSArray *validExtensions = nil;
  if(!validExtensions) validExtensions = [[videoExtensions arrayByAddingObjectsFromArray:audioExtensions] retain];
  
  return ([validExtensions containsObject:[[name pathExtension] lowercaseString]] || (_includePlaylists ? [playlistExtensions containsObject:[[name pathExtension] lowercaseString]] : NO));
}

-(void)dealloc {
  LOG(@"In ATVFDirectoryContents -dealloc, %@", _directory);
  
  [_directory release];
  [_menuItems release];
  [_scene release];
  [_assets release];
  
  [super dealloc];
}

// Updates the index of files in this folder.
-(void)refreshContents {
  LOG(@" ***** START REFRESHING CONTENTS OF %@ ***** ", _directory);
  
  NSArray *contents = [self _directoryContents:_directory];
  LOG(@"Contents: %@", contents);
  
  // scan directory contents here
/*  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_directory];*/
  
  // [_menuItems removeAllObjects];
  [_assets removeAllObjects];
  
  NSArray *playlistExtensions = [[ATVFPreferences preferences] arrayForKey:kATVPrefPlaylistExtensions];
  
  // build up the array of assets
  NSString *pname;
/*  NSString *extension;*/
  NSDictionary *attributes;
  ATVFMediaAsset *asset;
  NSURL *assetURL;
  NSNumber *filesize;
  NSString *stackName = nil;
  ATVFMediaAsset *stackAsset = nil;
  
  int i = 0, c = [contents count];
  
  for(i = 0; i < c; i++) {
    pname = [contents objectAtIndex:i];
    
    LOG(@"Considering %@", pname);
    
    // skip over names starting with ., or "Desktop DB", "Desktop DF", or "Icon\r"
    if([pname hasPrefix:@"."] || 
      [pname isEqualToString:@"Desktop DB"] || 
      [pname isEqualToString:@"Desktop DF"] || 
      [pname isEqualToString:@"Icon\r"]) {
      LOG(@" -> starts with ., or is Desktop DB, Desktop DF, Icon\\r");
      continue;
    }
    
    attributes = [[NSFileManager defaultManager] fileAttributesAtPath:[_directory stringByAppendingPathComponent:pname] traverseLink:NO];
    
    if(attributes == nil) {
      LOG(@" -> No attributes, skipping");
      continue;
    }
    
    // is this a symlink?  if so, we want to use the link target for EVERYTHING except "filename"
    if([[attributes objectForKey:NSFileType] isEqual:NSFileTypeSymbolicLink]) {
      // have to deal with symlinks with relative and absolute targets differently, otherwise stuff breaks
      // assume absolute target starts wiht /
      NSString *realPath = [[NSFileManager defaultManager] pathContentOfSymbolicLinkAtPath:[_directory stringByAppendingPathComponent:pname]];
      if([realPath hasPrefix:@"/"]) {
        // absolute link, just standardize it
        realPath = [realPath stringByStandardizingPath];
      } else {
        // relative link, prefix with _directory and standardize
        realPath = [[_directory stringByAppendingPathComponent:realPath] stringByStandardizingPath];
      }
      // assetURL = [NSURL fileURLWithPath:realPath];
      assetURL = [NSURL fileURLWithPath:[_directory stringByAppendingPathComponent:pname]];
      attributes = [[NSFileManager defaultManager] fileAttributesAtPath:realPath traverseLink:YES];
    } else {
      assetURL = [NSURL fileURLWithPath:[_directory stringByAppendingPathComponent:pname]];
    }

    // filter out directories if not looking
    if(!_includeDirectories && [[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory]) {
      LOG(@" -> Is directory, skipping as requested");
      continue;
    }
    
    // filter out non-music non-video extensions
    if(![[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory] 
      && ![self _isValidFilename:pname]) {
      LOG(@" -> %@ not valid filename, skipping...", pname);
      continue;
    }

    LOG(@" == %@ -> %@", pname, assetURL);
    
    // get the appropriate metadata
/*    extension = [pname pathExtension];*/
    filesize = [attributes objectForKey:NSFileSize];
    
    // is it playlist or not?
    NSString *extension = [[[assetURL absoluteString] pathExtension] lowercaseString];
    if([playlistExtensions containsObject:extension]) {
      if(!_includePlaylists) {
        LOG(@" -> Skipping playlist as requested...");
        continue;
      }
      
      asset = [[[ATVFPlaylistAsset alloc] initWithMediaURL:assetURL] autorelease];
    } else {
      // create the asset
      asset = [[[ATVFMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
    }
    [asset setTitle:pname];
    [asset setFilename:pname];
    [asset setFilesize:filesize];
    
    // set directory flag
    if([[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory]) {
      [asset setDirectory:YES];
/*      [enumerator skipDescendents];*/
      [asset setMediaType:[BRMediaType booklet]];
    } else {
      [asset setDirectory:NO];
      [asset setMediaType:[BRMediaType movie]];

      // don't stack playlists
      if(![asset isPlaylist]) {
        // stack info
        int stackIndex = -1;
        NSString *stackInfo = [self _getStackInfo:pname index:&stackIndex];
        LOG(@" ++ Stack info: %@, index=%d", stackInfo, stackIndex);
    
        // is this part of the same stack?
        if([stackName isEqualToString:stackInfo]) {
          LOG(@"  ++ Adding to stack...");
          [stackAsset addURLToStack:assetURL];
          LOG(@"  ++ New contents: %@", [stackAsset stackContents]);
          continue;
        } else {
          // not part of stack
          LOG(@" ++ Not in stack");
          stackAsset = asset;
          stackName = stackInfo;
        }
      } // not playlist
    } // not directory

    LOG(@" ++ Adding to list: %@", asset);
    
    if(!_doSort) [asset setTemporary:YES];
      
    [_assets addObject:asset];
    // [asset release];
  }
  
  // sort the assets
  // NSMutableArray *sortedAssets = 
  // [_assets release];
  // _assets = sortedAssets;
  NSMutableArray *sortedAssets = [[_assets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy];
  [_assets release];
  _assets = sortedAssets;

  LOG(@"Final asset list: %@", _assets);
  
  LOG(@" ***** DONE REFRESHING CONTENTS OF %@ ***** ", _directory);
  
  return;
}

// returns a BRSimpleMediaAsset wrapping the URL of the file at index
-(id)mediaForIndex:(long)index {
  if(index < [_assets count]) {
    return [_assets objectAtIndex:index];
  } else {
    return nil;
  }
}

// private

// Return the appropriate stack info, including the base stack name and index in that stack
// Index is solely based on the numeric/character identifier part, and really should only be
// used for sorting.
// Returns null if not part of a stack, in which case index is undefined.
-(NSString *)_getStackInfo:(NSString *)filename index:(int *)index {
  // NSString *baseName = [filename stringByDeletingPathExtension];
  NSMutableString *stackName = nil;
  
  // don't stack if it's disabled
  if(![[ATVFPreferences preferences] boolForKey:kATVPrefEnableStacking]) {
    return filename;
  }

  NSArray *stackREs = [[ATVFPreferences preferences] arrayForKey:kATVPrefStackRegexps];
  
  //LOG(@"In -_getStackInfo:%@", filename);
  
  unsigned int reCount = [stackREs count];
  unsigned int i;
  for(i = 0; i < reCount; i++) {
    NSString *re_str = [stackREs objectAtIndex:i];
    //LOG(@" re: %@", re_str);
    AGRegex *re = [AGRegex regexWithPattern:re_str options:AGRegexCaseInsensitive];
    AGRegexMatch *match = [re findInString:filename];
    if(match) {
      //LOG(@" match: %@", match);
      if([match count] == 2) {
        // simple match, just the part number
        stackName = [[filename mutableCopy] autorelease];
        [stackName replaceOccurrencesOfString:[match group] withString:@"" options:nil range:NSMakeRange(0, [stackName length])];
        *index = [[match groupAtIndex:[match count] - 1] intValue];
      } else {
        // matches more than the part number, i.e. prefix-part-suffix
        stackName = [[filename mutableCopy] autorelease];
        [stackName replaceOccurrencesOfString:[match groupAtIndex:2] withString:@"" options:nil range:[match rangeAtIndex:2]];
        //NSMakeRange(0, [stackName length])];
        *index = [[match groupAtIndex:2] intValue];
      }

      //LOG(@"  -> %@, idx=%d", stackName, *index);
      break;
    }
  }
  
  return stackName;
}

// These are the methods that BRMenuController expects

// How many menu items?
- (long)itemCount {
  return (long)[_assets count];
}

// (10.5) The height of a row.
-(float)heightForRow:(long)row {
	return 0.0f;
}

// (10.5)
-(BOOL)rowSelectable:(long)row {
	return YES;
}

// the menu item for the row
-(id<BRMenuItemLayer>)itemForRow:(long)row {
  if(row < [_assets count]) {
    //BOOL showSize = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileSize];
    BOOL showUnplayedDot = [[ATVFPreferences preferences] boolForKey:kATVPrefShowUnplayedDot];
    BOOL showFileIcons = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileIcons];
    
    // our menu item
    ATVFMediaAsset *asset = [_assets objectAtIndex:row];
    BRAdornedMenuItemLayer *adornedItem;
    
    // build the appropriate menu item
    if([asset isVolume]) {
      adornedItem = [SapphireFrontRowCompat textMenuItemForScene:_scene folder:YES];
    } else if([asset isDirectory]) {
      // folderMenuItemWithScene does nothing special but create the > on the right side of the item
      adornedItem = [SapphireFrontRowCompat textMenuItemForScene:_scene folder:YES];
    } else {
      // item = [BRTextMenuItemLayer menuItemWithScene:[self scene]];
      adornedItem = [SapphireFrontRowCompat textMenuItemForScene:_scene folder:NO];
    }
    
    // set the title
    [SapphireFrontRowCompat setTitle:[asset title] forMenu:adornedItem];
    
    // add them to the arrays
    if(showUnplayedDot && ![asset isDirectory] && ![asset hasBeenPlayed])
      [SapphireFrontRowCompat setLeftIcon:[SapphireFrontRowCompat unplayedPodcastImageForScene:_scene] forMenu:adornedItem];
    
    if(showFileIcons) {
      if([asset isVolume]) {
        [SapphireFrontRowCompat setRightIcon:[self _volumeIcon] forMenu:adornedItem];
      } else if([asset isPlaylist]) {
        [SapphireFrontRowCompat setRightIcon:[self _playlistIcon] forMenu:adornedItem];
      } else if([asset isStack]) {
        [SapphireFrontRowCompat setRightIcon:[self _stackIcon] forMenu:adornedItem];
      }
    }
    
    return adornedItem;
  } else {
    return nil;
  }
}

// find a row based on the (menu) item
- (long)rowForTitle:(NSString *)title {
  // find it
  long i,
    count = [self itemCount];
  for(i = 0; i < count; i++) {
    if([title isEqualToString:[self titleForRow:i]])
      return i;
  }
  
  return -1;
}

// the title of a row
- (NSString *)titleForRow:(long)row {
  if(row < [_assets count]) {
    return [[_assets objectAtIndex:row] title];
  } else {
    return nil;
  }
}

-(NSArray *)assets {
  return _assets;
}

// private
-(BRBitmapTexture *)_playlistIcon {
  NSURL *playlistIconURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"playlist" ofType:@"png"]];
  return [self _textureFromURL:playlistIconURL];
}

-(BRBitmapTexture *)_stackIcon {
  NSURL *stackIconURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"stack-icon" ofType:@"png"]];
  return [self _textureFromURL:stackIconURL];
}

-(BRBitmapTexture *)_volumeIcon {
  NSURL *volumeIconURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"volume" ofType:@"png"]];
  return [self _textureFromURL:volumeIconURL];
}
-(BRBitmapTexture *)_textureFromURL:(NSURL *)url {
  return [SapphireFrontRowCompat imageAtPath:[url path] scene:_scene];
}
@end
