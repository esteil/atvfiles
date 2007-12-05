//
//  ATVFPlaylistPlayer.h
//  ATVFiles
//
//  Created by Eric Steil III on 9/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFPlaylistAsset.h"

@interface ATVFPlaylistPlayer : BRLayerController {
  ATVFPlaylistAsset *_currentPlaylist;
  int _playlistPosition;
  BOOL _currentlyInPlaylist;
}

-(ATVFPlaylistPlayer *)initWithScene:(BRRenderScene *)scene playlist:(ATVFPlaylistAsset *)playlist;
-(void)playAsset:(ATVFMediaAsset *)asset;


@end
