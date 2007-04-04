//
//  ATVDirectoryContents.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVDirectoryContents.h"
#import "NSString+FileSizeFormatting.h"
/*#include <sys/types.h>
#include <dirent.h>
*/
@implementation ATVDirectoryContents

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory {
  _scene = [scene retain];
  _directory = [[directory stringByAppendingString:@"/"] retain];
  
  _menuItems = [[[NSMutableArray alloc] init] retain];
  _assets = [[[NSMutableArray alloc] init] retain];
  
  [self refreshContents];
  
  return self;
}

// Updates the index of files in this folder.
-(void)refreshContents {
  LOG(@"Refreshing %@", _directory);

/*  DIR *dirp;
  struct dirent dirc;
*/  
  // scan directory contents here
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_directory];
  
  [_menuItems removeAllObjects];
  [_assets removeAllObjects];
  
  // build up the array of assets
  NSString *pname;
/*  NSString *extension;*/
  NSDictionary *attributes;
  ATVMediaAsset *asset;
  NSURL *assetURL;
  NSNumber *filesize;
  while(pname = [enumerator nextObject]) {
    // skip over names starting with .
    if([pname hasPrefix:@"."]) {
      continue;
    }
    
    [pname retain];
    
    attributes = [enumerator fileAttributes];
    
    if(attributes == nil) {
      continue;
    }
    
    // is this a symlink?  if so, we want to use the link target for EVERYTHING except "filename"
    if([[attributes objectForKey:NSFileType] isEqual:NSFileTypeSymbolicLink]) {
      NSString *realPath = [[NSFileManager defaultManager] pathContentOfSymbolicLinkAtPath:[_directory stringByAppendingPathComponent:pname]];
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
      [enumerator skipDescendents];
      [asset setMediaType:[BRMediaType booklet]];
    } else {
      [asset setDirectory:NO];
      [asset setMediaType:[BRMediaType movie]];
    }

    [_assets addObject:asset];
  }
  
  // sort the assets
  _assets = [[_assets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy];
  
  // loop over each asset and build an appropriate menu item
  int count = [_assets count];
  int i = 0;
  for(i = 0; i < count; i++) {
    ATVMediaAsset *asset = [_assets objectAtIndex:i];
    
    // our menu item
    id item;
    
    // build the appropriate menu item
    if([asset isDirectory]) {
      // folderMenuItemWithScene does nothing special but create the > on the right side of the item
      item = [BRTextMenuItemLayer folderMenuItemWithScene:_scene];
    } else {
      item = [BRTextMenuItemLayer menuItemWithScene:_scene];

      // add a formatted file size to the right side of the menu (like XBMC)
      [item setRightJustifiedText:[NSString formattedFileSizeWithBytes:[asset filesize]]];
    }
    [item setTitle:[asset filename]];
/*    [item setLeftIcon:[[BRThemeInfo sharedTheme] wirelessImageForScene:_scene]];*/

    // add them to the arrays
    [_menuItems addObject:item];
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
