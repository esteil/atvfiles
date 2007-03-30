//
//  ATVDirectoryContents.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVDirectoryContents.h"
#import "NSString+FileSizeFormatting.h"

@implementation ATVDirectoryContents

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory {
  _scene = [scene retain];
  _directory = [directory retain];
  
  _files = [[[NSMutableArray alloc] init] retain];
  _menuItems = [[[NSMutableArray alloc] init] retain];
  _assets = [[[NSMutableArray alloc] init] retain];
  
  [self refreshContents];
  
  return self;
}

// Updates the index of files in this folder.
-(void)refreshContents {
  NSLog(@"Refreshing %@", _directory);
  // scan directory contents here
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_directory];
  
  [_files removeAllObjects];
  [_menuItems removeAllObjects];
  [_assets removeAllObjects];
  
  // build up the array of assets
  NSString *pname, *extension;
  NSDictionary *attributes;
  ATVMediaAsset *asset;
  NSURL *assetURL;
  NSNumber *filesize;
  while(pname = [enumerator nextObject]) {
    [pname retain];
    attributes = [enumerator fileAttributes];
    
    assetURL = [NSURL fileURLWithPath:[_directory stringByAppendingPathComponent:pname]];
    extension = [pname pathExtension];
    asset = [[[ATVMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
    [asset setTitle:pname];
    [asset setMediaType:[BRMediaType movie]];
/*  }*/
  
  // loop over each asset and build an appropriate menu item
  
    // build the menu item
    id item;
    // are we a folder?
    if([[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory]) {
      item = [BRTextMenuItemLayer folderMenuItemWithScene:_scene];
      [asset setDirectory:YES];
      [enumerator skipDescendents];
    } else {
      item = [BRTextMenuItemLayer menuItemWithScene:_scene];
      [asset setDirectory:NO];

      // add a formatted file size to the right side of the menu (like XBMC)
      filesize = [attributes objectForKey:NSFileSize];
      [item setRightJustifiedText:[NSString formattedFileSizeWithBytes:filesize]];
    }
    [item setTitle:pname];

    // add them to the arrays
    [_menuItems addObject:item];
    [_files addObject:pname];
    [_assets addObject:asset];
  }
}

// returns a BRSimpleMediaAsset wrapping the URL of the file at index
-(id)mediaForIndex:(long)index {
  return [_assets objectAtIndex:index];
}

// These are the methods that menu controllers expect

// How many menu items?
- (long)itemCount {
  return (long)[_menuItems count];
}

// the menu item for the row
- (id)itemForRow:(long)row {
  return [_menuItems objectAtIndex:row];
}

// find a row based on the (menu) item
- (long)rowForTitle:(id)title {
  // find it
  return (long)[_menuItems indexOfObject:title];
}

// the title of a row
- (id)titleForRow:(long)row {
  return [[_menuItems objectAtIndex:row] title];
}


@end
