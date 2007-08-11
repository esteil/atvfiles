//
//  ATVFVideoPlayer.h
//  ATVFiles
//
//  Created by Eric Steil III on 7/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFVideo.h"
#import "ATVFPlaylistAsset.h"

@interface ATVFVideoPlayer : BRQTKitVideoPlayer {
  int playlist_count, playlist_offset;
  ATVFPlaylistAsset *playlist;
}

@end
