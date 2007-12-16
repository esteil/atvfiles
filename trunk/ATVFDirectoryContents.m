//
//  ATVFDirectoryContents.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFDirectoryContents.h"
#import "NSString+FileSizeFormatting.h"
#import "ATVFilesAppliance.h"
#include <sys/types.h>
#include <dirent.h>
#import <AGRegex/AGRegex.h>
#import "ATVFPreferences.h"
#import "ATVFDirectoryContents-Private.h"

@implementation ATVFDirectoryContents

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory {
  return [self initWithScene:scene forDirectory:directory includeDirectories:YES playlists:YES];
}

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory includeDirectories:(BOOL)includeDirectories playlists:(BOOL)includePlaylists {
  _scene = [scene retain];
  _directory = [[directory stringByAppendingString:@"/"] retain];
  
  _menuItems = [[NSMutableArray alloc] init];
  _assets = [[NSMutableArray alloc] init];
  
  _includeDirectories = includeDirectories;
  _includePlaylists = includePlaylists;
  
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
  //LOG(@"In ATVFDirectoryContents -dealloc, %@", _directory);
  
  [_directory release];
  [_menuItems release];
  [_scene release];
  [_assets release];
  
  [super dealloc];
}

// Updates the index of files in this folder.
-(void)refreshContents {
  //LOG(@"Refreshing %@", _directory);
  
  NSArray *contents = [self _directoryContents:_directory];
  //LOG(@"Contents: %@", contents);
  
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
    
    // skip over names starting with ., or "Desktop DB", "Desktop DF", or "Icon\r"
    if([pname hasPrefix:@"."] || 
      [pname isEqualToString:@"Desktop DB"] || 
      [pname isEqualToString:@"Desktop DF"] || 
      [pname isEqualToString:@"Icon\r"]) {
      continue;
    }
    
    attributes = [[NSFileManager defaultManager] fileAttributesAtPath:[_directory stringByAppendingPathComponent:pname] traverseLink:NO];
    
    if(attributes == nil) {
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
    if(!_includeDirectories && [[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory])
      continue;
    
    // filter out non-music non-video extensions
    if(![[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory] 
      && ![self _isValidFilename:pname]) {
      //LOG(@"%@ not valid, skipping...", pname);
      continue;
    }

    //LOG(@"%@ -> %@", pname, assetURL);
    
    // get the appropriate metadata
/*    extension = [pname pathExtension];*/
    filesize = [attributes objectForKey:NSFileSize];
    
    // is it playlist or not?
    NSString *extension = [[[assetURL absoluteString] pathExtension] lowercaseString];
    if([playlistExtensions containsObject:extension]) {
      if(!_includePlaylists) continue;
      
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
        //LOG(@" Stack info: %@, index=%d", stackInfo, stackIndex);
    
        // is this part of the same stack?
        if([stackName isEqualToString:stackInfo]) {
          //LOG(@"Adding to stack...");
          [stackAsset addURLToStack:assetURL];
          //LOG(@"New contents: %@", [stackAsset stackContents]);
          continue;
        } else {
          // not part of stack
          //LOG(@"Not in stack");
          stackAsset = asset;
          stackName = stackInfo;
        }
      } // not playlist
    } // not directory

    [_assets addObject:asset];
    // [asset release];
  }
  
  // sort the assets
  // NSMutableArray *sortedAssets = 
  // [_assets release];
  // _assets = sortedAssets;
  _assets = [[[_assets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy] retain];
  
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
        stackName = [filename mutableCopy];
        [stackName replaceOccurrencesOfString:[match group] withString:@"" options:nil range:NSMakeRange(0, [stackName length])];
        *index = [[match groupAtIndex:[match count] - 1] intValue];
      } else {
        // matches more than the part number, i.e. prefix-part-suffix
        stackName = [filename mutableCopy];
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

// the menu item for the row
- (BRRenderLayer *)itemForRow:(long)row {
  if(row < [_assets count]) {
    BOOL showSize = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileSize];
    BOOL showUnplayedDot = [[ATVFPreferences preferences] boolForKey:kATVPrefShowUnplayedDot];
    BOOL showFileIcons = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileIcons];
    
    // our menu item
    ATVFMediaAsset *asset = [_assets objectAtIndex:row];
    BRTextMenuItemLayer *item;
    BRAdornedMenuItemLayer *adornedItem;
    
    // build the appropriate menu item
    if([asset isVolume]) {
      adornedItem = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:_scene];
      item = [adornedItem textItem];
      [item setRightJustifiedText:@"VOL"];
    } else if([asset isDirectory]) {
      // folderMenuItemWithScene does nothing special but create the > on the right side of the item
      adornedItem = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:_scene];
      item = [adornedItem textItem];
    } else {
      // item = [BRTextMenuItemLayer menuItemWithScene:[self scene]];
      adornedItem = [BRAdornedMenuItemLayer adornedMenuItemWithScene:_scene];
      item = [adornedItem textItem];

      // add a formatted file size to the right side of the menu (like XBMC)
      // this is in ATVFMetadataPreviewController
      // if(showSize) {
      //   [item setRightJustifiedText:[NSString formattedFileSizeWithBytes:[asset filesize]]];
      // }
    }
    
    // set the title
    [item setTitle:[asset title]];
    
    // add them to the arrays
    if(showUnplayedDot && ![asset isDirectory] && ![asset hasBeenPlayed])
      [adornedItem setLeftIcon:[[BRThemeInfo sharedTheme] unplayedPodcastImageForScene:_scene]];
    
    if(showFileIcons) {
      if([asset isPlaylist]) {
        // [adornedItem setRightIcon:[[BRThemeInfo sharedTheme] gearImageForScene:_scene]];
        [adornedItem setRightIcon:[self _playlistIcon]];
      } else if([asset isStack]) {
        [adornedItem setRightIcon:[self _stackIcon]];
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

-(BRBitmapTexture *)_textureFromURL:(NSURL *)url {

  CGImageRef imageref = CreateImageForURL((CFURLRef)url);
  
  struct BRBitmapDataInfo info;
  info.internalFormat = GL_RGBA;
  info.dataFormat = GL_BGRA;
  info.dataType = GL_UNSIGNED_INT_8_8_8_8_REV;
  info.width = 512;
  info.height = 512;

  BRRenderContext *context = [_scene resourceContext];

  NSData *data = CreateBitmapDataFromImage( imageref, info.width, info.height );
  BRBitmapTexture *image = [[BRBitmapTexture alloc] initWithBitmapData: data
                             bitmapInfo: &info context: context mipmap: YES];

  [data release];
  return [image autorelease];  
}
@end
