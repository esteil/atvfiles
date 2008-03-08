//
// ATVFPlacesContents.m
// ATVFiles
//
// Created by Eric Steil III on 12/15/07.
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

#import "ATVFPlacesContents.h"
#import "ATVFPreferences.h"
#import "ATVFDirectoryContents-Private.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>

#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>

@interface ATVFPlacesContents (Private)
-(NSArray *)_mountedVolumes;
@end

@implementation ATVFPlacesContents

-(ATVFPlacesContents *)initWithScene:(BRRenderScene *)scene mode:(enum kATVFPlacesMode)mode {
  _mode = mode;
  
  if([SapphireFrontRowCompat usingTakeTwo]) {
    if(_mode != kATVFPlacesModePlacesOnly && _mode != kATVFPlacesModeFull)
    _mode = kATVFPlacesModeFull;
  }
  
  [super initWithScene:scene forDirectory:[[ATVFPreferences preferences] objectForKey:kATVPrefRootDirectory]];
  
  NSNotificationCenter *workspaceNoteCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
  
  [workspaceNoteCenter addObserver:self selector:@selector(_mountsDidChange:) name:NSWorkspaceDidMountNotification object:nil];
  [workspaceNoteCenter addObserver:self selector:@selector(_mountsDidChange:) name:NSWorkspaceDidUnmountNotification object:nil];
  
  return self;
}

-(void)dealloc {
  LOG(@"In ATVFPlacesContents dealloc");
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  
  [super dealloc];
}

// Updates the index of files in this folder.
-(void)refreshContents {
  LOG(@"Refreshing places contents");
  NSFileManager *manager = [NSFileManager defaultManager];
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
  
  BOOL addVolumesToTop = NO;
  
  [_assets removeAllObjects];

  if(_mode == kATVFPlacesModeFull || _mode == kATVFPlacesModePlacesOnly) {
    // full new-style places, so just volumes + bookmarks
    
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
    [_assets release];
    _assets = [[bookmarkAssets sortedArrayUsingSelector:@selector(compareTitleWith:)] mutableCopy];
  } else if(_mode == kATVFPlacesModeVolumesOnly) {
    // transitional style, just volumes + RootDirectory contents
    
    // so, to make it easier, first build the current listing of RootDirectory
    [super refreshContents];
    
    addVolumesToTop = YES;
  }

  if(_mode != kATVFPlacesModePlacesOnly) {
    // append volumes to the top
    // do this here after, so it isn't duplicated code.
    NSMutableArray *volumes = [[[NSMutableArray alloc] init] autorelease];
    
    //NSArray *workspaceLocal = [workspace mountedLocalVolumePaths];
    NSArray *local = [self _mountedVolumes];
    
    //LOG(@"Local paths: %@, removable: %@", local);
    
    [volumes addObjectsFromArray:local];
    //[volumes addObjectsFromArray:removable];
    
    // build the appropriate assets
    NSMutableArray *volumeAssets = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *volumeEnum = [volumes objectEnumerator];
    NSString *volume;
    NSArray *blacklistedMounts = [[ATVFPreferences preferences] arrayForKey:kATVPrefMountBlacklist];
    while((volume = [volumeEnum nextObject]) != NULL) {
      // don't show root
      if([blacklistedMounts containsObject:volume]) continue;
      
      NSURL *assetURL = [NSURL fileURLWithPath:volume];
      NSDictionary *attributes = [manager fileAttributesAtPath:volume traverseLink:YES];
      ATVFMediaAsset *asset;
      
      asset = [[[ATVFMediaAsset alloc] initWithMediaURL:assetURL] autorelease];
      [asset setTitle:[manager displayNameAtPath:volume]];
      [asset setFilename:[volume lastPathComponent]];
      [asset setFilesize:[attributes objectForKey:NSFileSize]];
      [asset setDirectory:YES];
      [asset setVolume:YES];
      
      // set other flags
      BOOL removable = NO;
      BOOL writable = NO;
      BOOL unmountable = NO;
      NSString *description = nil;
      NSString *type = nil;
      
      BOOL result = [workspace getFileSystemInfoForPath:volume 
                                            isRemovable:&removable 
                                             isWritable:&writable 
                                          isUnmountable:&unmountable 
                                            description:&description
                                                   type:&type];
      
      if(result) {
        LOG(@"Info for %@: Desc: %@, Type: %@, removable: %d, writable: %d, unmountable: %d",
            volume, description, type, removable, writable, unmountable);
        if(removable) [asset setRemovable:removable];
        if(unmountable) [asset setEjectable:unmountable];
      } else {
        LOG(@"No info for %@", volume);
      }
      
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
  }
  
  LOG(@"Places menu assets: %@", _assets);
  
  return;
}

// notification handler
-(void)_mountsDidChange:(NSNotification *)notification {
  LOG(@"Notification: %@", notification);
  
  // refresh it
  //[self refreshContents];
  
  // broadcast our own indicating it did change
  [[NSNotificationCenter defaultCenter] postNotificationName:ATVFMountsDidChangeNotification object:self];
}

// NSWorkspace is broked on the ATV, so this is a POSIX
// implementation of -[NSWorkspace mountedLocalVolumePaths];
-(NSArray *)_mountedVolumes {
  struct statfs *mounts;
  int num_mounts = getmntinfo(&mounts, MNT_NOWAIT);
  NSMutableArray *volumes = [[[NSMutableArray alloc] initWithCapacity:num_mounts] autorelease];
  int i = 0;
  
  // add the mount points to the array, filtering out types of devfs, fdesc, volfs
  // also filters automounter
  for(i = 0; i < num_mounts; i++) {
    LOG("Mount: %s -- %s -- %s, %x",
        mounts[i].f_fstypename, mounts[i].f_mntonname, mounts[i].f_mntfromname, mounts[i].f_flags);
    if(strncmp(mounts[i].f_fstypename, "devfs", 5) != 0 &&
       strncmp(mounts[i].f_fstypename, "fdesc", 5) != 0 &&
       strncmp(mounts[i].f_fstypename, "volfs", 5) != 0 &&
       strncmp(mounts[i].f_mntfromname, "automount", 9) != 0 &&
       strncmp(mounts[i].f_mntfromname, "map ", 4) != 0 
      ) {
      [volumes addObject:[NSString stringWithUTF8String:mounts[i].f_mntonname]];
    }
  }
  
  return volumes;
#if 0
  LOG(@" BSD SAYS WE HAVE MOUNTS: ");
  struct statfs *mounts;
  
  int result = getmntinfo(&mounts, MNT_NOWAIT);
  
  LOG("Mounted: %d", result);
  
  int i = 0;
  
  for(i = 0; i < result; i++) {
    // printf("Statfs:\nType:\t%s\nMounted:\t%s\nFrom:\t%s\n\n",
    LOG("Mount: %s -- %s -- %s, %x",
        mounts[i].f_fstypename, mounts[i].f_mntonname, mounts[i].f_mntfromname, mounts[i].f_flags);
  }
#endif

}
@end
