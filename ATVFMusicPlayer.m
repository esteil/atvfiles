//
//  ATVFMusicPlayer.m
//  ATVFiles
//
//  Created by Eric Steil III on 6/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFMusicPlayer.h"


@implementation ATVFMusicPlayer

-(void)dealloc {
  LOG(@"ATVFMusicPlayer dealloc called");
  [super dealloc];
  [_player release];
  [_asset release];
}

-(void)init {
  _state = 0;
}

- (BOOL)interruptsSyncingWhenPlaying {
  BOOL result = [super interruptsSyncingWhenPlaying];
  LOG(@"ATVFMusicPlayer interruptsSyncingWhenPlaying -> %d", result);
  return result;
}

- (void)setMedia:(id)fp8 inTracklist:(id)fp12 error:(id *)fp16 {
  [super setMedia:fp8 inTracklist:fp12 error:fp16];
  _asset = fp8;
  [_asset retain];
  LOG(@"ATVFMusicPlayer setMedia:(%@)%@ inTrackList:(%@)%@ error:(%@)%@", [fp8 class], fp8, [fp12 class], fp12, [*fp16 class], *fp16);
}

- (id)tracklist {
  id result = [super tracklist];
  LOG(@"ATVFMusiCPlayer tracklist -> (%@)%@", [result class], result);
  return result;
}

- (void)setShufflePlayback:(BOOL)fp8 {
  LOG(@"ATVFMusicPlayer setShufflePlayback:%d", fp8);
  [super setShufflePlayback:fp8];
}

- (void)fadeOutVolume {
  LOG(@"ATVFMusicPlayer fadeOutVolume");
  [super fadeOutVolume];
}

- (void)restoreVolume {
  LOG(@"ATVFMusicPlayer restoreVolume");
  [super restoreVolume];
}

- (BOOL)shufflePlayback {
  BOOL result = [super shufflePlayback];
  LOG(@"ATVFMusicPlayer shufflePlayback -> %d", result);
  return result;
}

- (void)setRepeatMode:(int)fp8 {
  LOG(@"ATVFMusicPlayer setRepeatMode:%d", fp8);
  [super setRepeatMode:fp8];
}

- (int)repeatMode {
  int result = [super repeatMode];
  LOG(@"ATVFMusicPlayer repeatMode -> %d", result);
  return result;
}

// BRMediaPlayer
// 0 = stopped, 1 = paused, 3 = playing
- (int)playerState {
  LOG(@"ATVFMusicPlayer playerState -> %d", _state);
  return _state;
}

- (BOOL)setMedia:(id)fp8 error:(id *)fp12 {
  LOG(@"ATVFMusicPlayer setMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, [*fp12 class], *fp12);
  BOOL result = YES;
  [_asset release];
  _asset = fp8;
  [_asset retain];
  LOG(@"ATVFMusicPlayer setMedia:(%@)%@ error:(%@)%@ -> %d", [fp8 class], fp8, [*fp12 class], *fp12, result);
  return result;
}

- (id)media {
  id result = _asset;
  LOG(@"ATVFMusicPlayer media -> (%@)%@", [result class], result);
  return result;
}

- (float)elapsedPlaybackTime {
  float result;
  
  QTTime qt_duration = [_player duration];
  NSTimeInterval interval = QTGetTimeInterval(qt_duration, &interval);
  result = (float)interval;
  
  LOG(@"ATVFMusicPlayer elapsedPlaybackTime -> %f", result);
  return result;
}

- (void)setElapsedPlaybackTime:(float)fp8 {
  LOG(@"ATVFMusicPlayer setElapsedPlaybackTime:%f", fp8);
  [super setElapsedPlaybackTime:fp8];
}

- (double)trackDuration {
  double result;
  
  QTTime qt_duration = [_player duration];
  NSTimeInterval interval;
  QTGetTimeInterval(qt_duration, &interval);
  result = (double)interval;

  LOG(@"ATVFMUsicPlayer trackDuration -> %f", result);
  return result;
}

- (float)bufferingProgress {
  float result = [super bufferingProgress];
  LOG(@"ATVFMusicPlayer bufferingProgress -> %f", result);
  return result;
}

- (id)currentChapterTitle {
  id result = [super currentChapterTitle];
  LOG(@"ATVFMusicPlayer currentChapterTitle -> (%@)%@", [result class], result);
  return result;
}

- (void)setMuted:(BOOL)fp8 {
  LOG(@"ATVFMusicPlayer setMuted:%d", fp8);
  [super setMuted:fp8];
}

- (BOOL)muted {
  BOOL result = [super muted];
  LOG(@"ATVFMusicPlayer muted -> %d", result);
  return result;
}

- (BOOL)initiatePlayback:(id *)fp8 {
  LOG(@"ATVFMusicPlayer initiatePlayback");
  BOOL result = NO;
  
  _player = [QTMovie movieWithURL:[NSURL URLWithString:[_asset mediaURL]] error:fp8];
  if(!_player) {
    LOG(@"Unable to initiate playback: %@", *fp8);
    result = NO;
    _state = kBRMusicPlayerStateStopped;
  } else {
    [_player retain];
    [_player play];
    _state = kBRMusicPlayerStatePlaying;
    result = YES;
  }
  
  return result;
}

- (void)play {
  LOG(@"ATVFMusicPlayer play");
  _state = kBRMusicPlayerStatePlaying;
  [_player play];
}

- (void)pause {
  LOG(@"ATVFMusicPlayer pause");
  _state = kBRMusicPlayerStatePaused;
  [_player stop];
}

- (void)stop {
  LOG(@"ATVFMusicPlayer stop");
  _state = kBRMusicPlayerStateStopped;
  [_player stop];
}

- (void)pressAndHoldLeftArrow {
  LOG(@"ATVFMusicPlayer pressAndHoldLeftArrow");
  [super pressAndHoldLeftArrow];
}

- (void)pressAndHoldRightArrow {
  LOG(@"ATVFMusicPlayer pressAndHoldRightArrow");
  [super pressAndHoldRightArrow];
}

- (void)resume {
  LOG(@"ATVFMusicPlayer resume");
  _state = kBRMusicPlayerStatePlaying;
  [_player play];
}

- (void)leftArrowClick {
  LOG(@"ATVFMusicPlayer leftArrowClick");
  [super leftArrowClick];
}

- (void)rightArrowClick {
  LOG(@"ATVFMusicPlayer rightArrowClick");
  [super rightArrowClick];
}

-(void)setPlaybackContext:(id)fp8 {
  LOG(@"ATVFMusicPlayer setPlaybackContext:(%@)%@", [fp8 class], fp8);
  // [super setPlaybackContext:fp8];
}

-(float)aspectRatio {
  LOG(@"ATVFMusicPlayer aspectRatio -> 1.0");
  return 1.0f;
}

@end
