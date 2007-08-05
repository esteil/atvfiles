//
//  ATVFMusicPlayer.h
//  ATVFiles
//
//  Created by Eric Steil III on 6/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BRMusicPlayer.h>
#import <ATVFMediaAsset.h>
#import <ATVFPlaylistAsset.h>

enum kBRMusicPlayerState {
  kBRMusicPlayerStateStopped = 0,
  kBRMusicPlayerStatePaused = 1,
  kBRMusicPlayerStatePlaying = 3
};
  
@interface ATVFMusicPlayer : BRMusicPlayer {
  QTMovie *_player;
  ATVFMediaAsset *_asset;
  enum kBRMusicPlayerState _state;
  NSTimer *_updateTimer,
          *_seekTimer;
  // state variable for seeking when holding left/right
  // 0 = no seek, -1 = seek backwards, 1 = seek forward
  int _seeking;
}

-(void)setPlayerState:(enum kBRMusicPlayerState)state;

-(void)setPlaylist:(ATVFPlaylistAsset *)playlist;

// BRMusicPlayer
- (void)dealloc;
- (BOOL)interruptsSyncingWhenPlaying;
- (void)setMedia:(id)fp8 inTracklist:(id)fp12 error:(id *)fp16;
- (id)tracklist;
- (void)setShufflePlayback:(BOOL)fp8;
- (void)fadeOutVolume;
- (void)restoreVolume;
- (BOOL)shufflePlayback;
- (void)setRepeatMode:(int)fp8;
- (int)repeatMode;

// BRMediaPlayer
- (int)playerState;
- (BOOL)setMedia:(id)fp8 error:(id *)fp12;
- (id)media;
- (float)elapsedPlaybackTime;
- (void)setElapsedPlaybackTime:(float)fp8;
- (double)trackDuration;
- (float)bufferingProgress;
- (id)currentChapterTitle;
- (void)setMuted:(BOOL)fp8;
- (BOOL)interruptsSyncingWhenPlaying;
- (BOOL)muted;
- (BOOL)initiatePlayback:(id *)fp8;
- (void)play;
- (void)pause;
- (void)stop;
- (void)pressAndHoldLeftArrow;
- (void)pressAndHoldRightArrow;
- (void)resume;
- (void)leftArrowClick;
- (void)rightArrowClick;

@end
