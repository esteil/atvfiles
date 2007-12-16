//
//  ATVFPlacesContents.m
//  ATVFiles
//
//  Created by Eric Steil III on 12/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFPlacesContents.h"
#import "ATVFPreferences.h"
#import "ATVFDirectoryContents-Private.h"

@implementation ATVFPlacesContents

-(ATVFPlacesContents *)initWithScene:(BRRenderScene *)scene mode:(enum kATVFPlacesMode)mode {
  _mode = mode;
  
  [super initWithScene:scene forDirectory:[[ATVFPreferences preferences] objectForKey:kATVPrefRootDirectory]];
  
  return self;
}

// Updates the index of files in this folder.
-(void)refreshContents {
  LOG(@"Refreshing places contents");
  NSFileManager *manager = [NSFileManager defaultManager];
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
  
  BOOL addVolumesToTop = NO;
  
  if(_mode == kATVFPlacesModeFull) {
    // full new-style places, so just volumes + bookmarks
    
    [_assets removeAllObjects];
    // build up bookmarks
    
    NSArray *bookmarks = [[ATVFPreferences preferences] arrayForKey:kATVPrefPlaces];
    NSMutableArray *bookmarkAssets = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *bookmarkEnum = [bookmarks objectEnumerator];
    NSString *bookmark;
    while((bookmark = [bookmarkEnum nextObject]) != NULL) {
      BOOL isDir = NO;
      if([manager fileExistsAtPath:bookmark isDirectory:&isDir] && isDir) {
        NSURL *assetURL = [NSURL fileURLWithPath:bookmark];
        NSDictionary *attributes = [manager fileAttributesAtPath:bookmark traverseLink:YES];
        ATVFMediaAsset *asset;
        
        // store it
        asset = [[[ATVFMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
        [asset setTitle:[manager displayNameAtPath:bookmark]];
        [asset setFilename:[bookmark lastPathComponent]];
        [asset setFilesize:[attributes objectForKey:NSFileSize]];
        [asset setDirectory:YES];
        [asset setMediaType:[BRMediaType booklet]];
        
        [bookmarkAssets addObject:asset];
      }
    }
    
    // sort them, and store them in the main asset array
    _assets = [[[bookmarkAssets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy] retain];
  } else if(_mode == kATVFPlacesModeVolumesOnly) {
    // transitional style, just volumes + RootDirectory contents
    
    // so, to make it easier, first build the current listing of RootDirectory
    [super refreshContents];
    
    addVolumesToTop = YES;
  }

  // append volumes to the top
  // do this here after, so it isn't duplicated code.
  NSMutableArray *volumes = [[NSMutableArray alloc] init];
  
  NSArray *local = [workspace mountedLocalVolumePaths];
  NSArray *removable = [workspace mountedRemovableMedia];
  
  LOG(@"Local paths: %@, removable: %@", local, removable);
  
  [volumes addObjectsFromArray:local];
  [volumes addObjectsFromArray:removable];
  
  // build the appropriate assets
  NSMutableArray *volumeAssets = [[[NSMutableArray alloc] init] autorelease];
  NSEnumerator *volumeEnum = [volumes objectEnumerator];
  NSString *volume;
  while((volume = [volumeEnum nextObject]) != NULL) {
    // don't show root
    if([volume isEqual:@"/"]) continue;
    
    NSURL *assetURL = [NSURL fileURLWithPath:volume];
    NSDictionary *attributes = [manager fileAttributesAtPath:volume traverseLink:YES];
    ATVFMediaAsset *asset;
    
    asset = [[[ATVFMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
    [asset setTitle:[manager displayNameAtPath:volume]];
    [asset setFilename:[volume lastPathComponent]];
    [asset setFilesize:[attributes objectForKey:NSFileSize]];
    [asset setDirectory:YES];
    [asset setVolume:YES];
    
    [volumeAssets addObject:asset];
  }
  
  // sort the volumes
  volumeAssets = [[[volumeAssets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy] autorelease];
  
  // append to the beginning
  if(addVolumesToTop) {
    volumeEnum = [volumeAssets reverseObjectEnumerator];
    id asset;
    while((asset = [volumeEnum nextObject]) != NULL) 
      [_assets insertObject:asset atIndex:0];
    
    _defaultIndex = [volumeAssets count];
    _separatorIndex = [volumeAssets count];
  } else {
    _defaultIndex = 0;
    _separatorIndex = [_assets count];
    [_assets addObjectsFromArray:volumeAssets];
  }
  
  LOG(@"Places menu assets: %@", _assets);
  
  return;
}

@end
