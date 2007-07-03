//
//  BRMusicNowPlayingController+SetPlayer.m
//  ATVFiles
//
//  Created by Eric Steil III on 6/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BRMusicNowPlayingController+SetPlayer.h"


@implementation BRMusicNowPlayingController (ATVFSetPlayer)

-(BRMusicPlayer *)player {
	return _player;
}

-(void)setPlayer:(BRMusicPlayer *)player {
	_player = player;
}

@end

@implementation BRMusicNowPlayingMonitor (ATVFSetPlayer)

-(BRMusicPlayer *)player {
  return _player;
}

-(void)setPlayer:(BRMusicPlayer *)player {
  _player = player;
}

@end