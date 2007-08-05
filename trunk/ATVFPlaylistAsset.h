//
//  ATVFPlaylistAsset.h
//  ATVFiles asset for playlists
//
//  Essentially is ATVFMediaAsset, except the stack array is used for playlists
//  contents instead, and the assets are stored.
//
//  This essentially turns it into an asset that contains other assets.  Enjoy!
//
//  The primary difference is that mediaURL returns the url of the PLAYLIST FILE
//  if one exists, otherwise it returns an internal URL.
//
//  Created by Eric Steil III on 8/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATVFMediaAsset.h"

#define kATVFAssetTypePlaylist @"playlist"

@interface ATVFPlaylistAsset : ATVFMediaAsset {

}

-(BOOL)isStack;
-(BOOL)isPlaylist;
-(NSArray *)playlistContents;
-(BOOL)appendToPlaylist:(ATVFMediaAsset *)asset;
-(BOOL)insertAsset:(ATVFMediaAsset *)asset atPosition:(long)index;
-(BOOL)removeFromPlaylist:(ATVFMediaAsset *)asset;
-(BOOL)removePositionFromPlaylist:(long)index;

@end
