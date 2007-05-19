//
//  ATVDirectoryContents.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVDirectoryContents.h"
#import "NSString+FileSizeFormatting.h"
#import "ATVFilesAppliance.h"
#include <sys/types.h>
#include <dirent.h>

@implementation ATVDirectoryContents

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory {
  _scene = [scene retain];
  _directory = [[directory stringByAppendingString:@"/"] retain];
  
  _menuItems = [[[NSMutableArray alloc] init] retain];
  _assets = [[[NSMutableArray alloc] init] retain];
  
  [self refreshContents];
  
  return self;
}

// returns an array just like [[NSFileManager defaultManager] directoryContentsAtPath:] except
// implemented using BSD functions.  returns nil when can't open directory.
-(NSArray *)_directoryContents:(NSString *)path {
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
}

-(BOOL)_isValidFilename:(NSString *)name {
  // these are borrowed from XBMC
  // TODO: make pref
  NSArray *videoExtensions = [[NSUserDefaults standardUserDefaults] arrayForKey:kATVPrefVideoExtensions];
  NSArray *audioExtensions = [[NSUserDefaults standardUserDefaults] arrayForKey:kATVPrefAudioExtensions];
  
  return [[videoExtensions arrayByAddingObjectsFromArray:audioExtensions] containsObject:[[name pathExtension] lowercaseString]];
}

// Updates the index of files in this folder.
-(void)refreshContents {
  LOG(@"Refreshing %@", _directory);
  
  NSArray *contents = [self _directoryContents:_directory];
  LOG(@"Contents: %@", contents);
  
  // scan directory contents here
/*  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_directory];*/
  
  [_menuItems removeAllObjects];
  [_assets removeAllObjects];
  
  BOOL showExtensions = [[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefShowFileExtensions];
  BOOL showSize = [[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefShowFileSize];
  BOOL showUnplayedDot = [[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefShowUnplayedDot];
  
  // build up the array of assets
  NSString *pname;
/*  NSString *extension;*/
  NSDictionary *attributes;
  ATVMediaAsset *asset;
  NSURL *assetURL;
  NSNumber *filesize;
  
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
    
    [pname retain];
    
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
      assetURL = [NSURL fileURLWithPath:realPath];
      attributes = [[NSFileManager defaultManager] fileAttributesAtPath:realPath traverseLink:YES];
    } else {
      assetURL = [NSURL fileURLWithPath:[_directory stringByAppendingPathComponent:pname]];
    }
    
    LOG(@"%@ -> %@", pname, assetURL);
    
    // get the appropriate metadata
/*    extension = [pname pathExtension];*/
    filesize = [attributes objectForKey:NSFileSize];
    
    // create the asset
    asset = [[[ATVMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
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

      // filter out non-music non-video extensions
      if(![self _isValidFilename:pname]) {
        continue;
      }
    }

    [_assets addObject:asset];
  }
  
  // sort the assets
  _assets = [[_assets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy];
  
  // loop over each asset and build an appropriate menu item
  c = [_assets count];
  for(i = 0; i < c; i++) {
    ATVMediaAsset *asset = [_assets objectAtIndex:i];
    
    // our menu item
    id item;
    id adornedItem;
    
    // build the appropriate menu item
    if([asset isDirectory]) {
      // folderMenuItemWithScene does nothing special but create the > on the right side of the item
      item = [BRTextMenuItemLayer folderMenuItemWithScene:_scene];
      adornedItem = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:_scene];
    } else {
      item = [BRTextMenuItemLayer menuItemWithScene:_scene];
      adornedItem = [BRAdornedMenuItemLayer adornedMenuItemWithScene:_scene];

      // add a formatted file size to the right side of the menu (like XBMC)
      if(showSize) {
        [item setRightJustifiedText:[NSString formattedFileSizeWithBytes:[asset filesize]]];
      }
    }
    
    if(showExtensions || [asset isDirectory]) {
      [item setTitle:[asset title]];
    } else {
      [item setTitle:[[asset title] stringByDeletingPathExtension]];
    }

    // add them to the arrays
    [adornedItem setTextItem:item];
    if(showUnplayedDot && ![asset isDirectory] && ![asset hasBeenPlayed])
      [adornedItem setLeftIcon:[[BRThemeInfo sharedTheme] unplayedPodcastImageForScene:_scene]];

    [_menuItems addObject:adornedItem];
  }
}

// returns a BRSimpleMediaAsset wrapping the URL of the file at index
-(id)mediaForIndex:(long)index {
  if(index < [_assets count]) {
    return [_assets objectAtIndex:index];
  } else {
    return nil;
  }
}

// These are the methods that BRMenuController expects

// How many menu items?
- (long)itemCount {
  return (long)[_menuItems count];
}

// the menu item for the row
- (id)itemForRow:(long)row {
  if(row < [_menuItems count]) {
    return [_menuItems objectAtIndex:row];
  } else {
    return nil;
  }
}

// find a row based on the (menu) item
- (long)rowForTitle:(id)title {
  // find it
  return (long)[_menuItems indexOfObject:title];
}

// the title of a row
- (id)titleForRow:(long)row {
  if(row < [_menuItems count]) {
    return [[_menuItems objectAtIndex:row] title];
  } else {
    return nil;
  }
}


@end
