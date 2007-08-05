//
//  ATVFPlaylistAsset.h
//  ATVFiles asset for playlists
//
//  Essentially is ATVFMediaAsset, except the stack array is used for playlists
//  contents instead, and the assets are stored.
//
//  This essentially turns it into an asset that contains other assets.  Enjoy!
//
//  Created by Eric Steil III on 8/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATVFMediaAsset.h"

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
