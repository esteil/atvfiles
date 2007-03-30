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
  
  [_menuItems removeAllObjects];
  [_assets removeAllObjects];
  
  // build up the array of assets
  NSString *pname, *extension;
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
    
    assetURL = [NSURL fileURLWithPath:[_directory stringByAppendingPathComponent:pname]];
    extension = [pname pathExtension];
    filesize = [attributes objectForKey:NSFileSize];
    
    // create the asset
    asset = [[[ATVMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
    [asset setTitle:pname];
    [asset setMediaType:[BRMediaType movie]];
    [asset setFilename:pname];
    [asset setFilesize:filesize];
    
    // set directory flag
    if([[attributes objectForKey:NSFileType] isEqual:NSFileTypeDirectory]) {
      [asset setDirectory:YES];
      [enumerator skipDescendents];
    } else {
      [asset setDirectory:NO];
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
    
    // are we a folder?
    if([asset isDirectory]) {
      item = [BRTextMenuItemLayer folderMenuItemWithScene:_scene];
    } else {
      item = [BRTextMenuItemLayer menuItemWithScene:_scene];

      // add a formatted file size to the right side of the menu (like XBMC)
      [item setRightJustifiedText:[NSString formattedFileSizeWithBytes:[asset filesize]]];
    }
    [item setTitle:[asset filename]];

    // add them to the arrays
    [_menuItems addObject:item];
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
