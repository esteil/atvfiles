//
// ATVFMusicPlayer.m
// ATVFiles
//
// Created by Eric Steil III on 6/29/07.
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

#import "ATVFMusicPlayer.h"

@interface ATVFMusicPlayer (PrivateMethods)
-(void)_playbackProgressChanged:(id)obj;
-(void)_notifyAssetChanged;
-(void)_seek;
-(void)_startSeeking;
-(void)_stopSeeking;
-(void)_qtNotification:(id)notification;
-(BOOL)_nextTrack;
-(BOOL)_previousTrack;
@end

@implementation ATVFMusicPlayer

-(void)dealloc {
  //LOG(@"ATVFMusicPlayer dealloc called");
  //return;
  [_player release];
  [_asset release];
  [_updateTimer invalidate];
  _updateTimer = nil;
  [_seekTimer invalidate];
  _seekTimer = nil;
  [_myTracklist release];
  [super dealloc];
}

-(void)init {
  _state = 0;
  _seeking = 0;
}

-(void)setPlaylist:(ATVFPlaylistAsset *)playlist {
  //LOG(@"In setPlaylist: %@", playlist);
  _myTracklist = [[playlist playlistContents] retain];
  //LOG(@"Tracklist: %@", _myTracklist);
  NSError *error;
  [self setMedia:[_myTracklist objectAtIndex:0] inTracklist:_myTracklist error:&error];
  if(error) LOG(@"Error setting playlist: %@", error);
}

-(void)setPlayerState:(enum kBRMusicPlayerState)state {
  // LOG(@"ATVFMusicPlayer setPlayerState:%d", state);
  _state = state;
  [[NSNotificationCenter defaultCenter] postNotificationName:kBRMediaPlayerStateChanged object:self];
}

- (BOOL)interruptsSyncingWhenPlaying {
  BOOL result = [super interruptsSyncingWhenPlaying];
  // LOG(@"ATVFMusicPlayer interruptsSyncingWhenPlaying -> %d", result);
  return result;
}

- (void)setMedia:(id)fp8 inTracklist:(id)fp12 error:(id *)fp16 {
  LOG_MARKER;
  
  ATV_23 [super setMediaAtIndex:[fp12 indexOfObject:fp8] inTrackList:fp12 error:fp16];
  else ATV_22 [super setMedia:fp8 inTrackList:fp12 error:fp16];
  else   [super setMedia:fp8 inTracklist:fp12 error:fp16];
  
  LOG_MARKER;
  
  _asset = fp8;
  [_asset retain];
  _myTracklist = fp12;
  [_myTracklist retain];
  
  // LOG(@"ATVFMusicPlayer setMedia:(%@)%@ inTrackList:(%@)%@", [fp8 class], fp8, [fp12 class], fp12);//, [*fp16 class], *fp16);
  [[NSNotificationCenter defaultCenter] postNotificationName:kBRMediaPlayerCurrentAssetChanged object:_asset];
}

- (id)tracklist {
  return _myTracklist;
}

- (void)setShufflePlayback:(BOOL)fp8 {
  // LOG(@"ATVFMusicPlayer setShufflePlayback:%d", fp8);
  [super setShufflePlayback:fp8];
}

- (void)fadeOutVolume {
  //LOG(@"ATVFMusicPlayer fadeOutVolume");
  [super fadeOutVolume];
}

- (void)restoreVolume {
  // LOG(@"ATVFMusicPlayer restoreVolume");
  [super restoreVolume];
}

- (BOOL)shufflePlayback {
  BOOL result = [super shufflePlayback];
  // LOG(@"ATVFMusicPlayer shufflePlayback -> %d", result);
  return result;
}

- (void)setRepeatMode:(int)fp8 {
  // LOG(@"ATVFMusicPlayer setRepeatMode:%d", fp8);
  [super setRepeatMode:fp8];
}

- (int)repeatMode {
  int result = [super repeatMode];
  // LOG(@"ATVFMusicPlayer repeatMode -> %d", result);
  return result;
}

// BRMediaPlayer
// 0 = stopped, 1 = paused, 3 = playing
- (int)playerState {
  // LOG(@"ATVFMusicPlayer playerState -> %d", _state);
  return _state;
}

- (BOOL)setMedia:(id)fp8 error:(id *)fp12 {
  //LOG(@"ATVFMusicPlayer setMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, [*fp12 class], *fp12);
  BOOL result = YES;
  [_asset release];
  _asset = fp8;
  [_asset retain];
  // LOG(@"ATVFMusicPlayer setMedia:(%@)%@ error:(%@)%@ -> %d", [fp8 class], fp8, [*fp12 class], *fp12, result);
  return result;
}

- (id)media {
  id result = _asset;
  //LOG(@"ATVFMusicPlayer media -> (%@)%@", [result class], result);
  return result;
}

// ATV22+
-(double)elapsedTime {
  return [self elapsedPlaybackTime];
}

// ATV21
- (float)elapsedPlaybackTime {
  float result;
  
  //LOG(@"In elapsedPlaybackTime");
  
  if(!_player) return 0;
  
  QTTime qt_duration = [_player currentTime];
  NSTimeInterval interval;
  QTGetTimeInterval(qt_duration, &interval);
  result = (float)interval;
  
  //LOG(@"ATVFMusicPlayer elapsedPlaybackTime -> %f", result);
  return result;
}

- (void)setElapsedPlaybackTime:(float)fp8 {
  //LOG(@"ATVFMusicPlayer setElapsedPlaybackTime:%f", fp8);
  QTTime newTime = QTMakeTimeWithTimeInterval(fp8);
  [_player setCurrentTime:newTime];
  [self _playbackProgressChanged:nil];
}

- (double)trackDuration {
  double result;

  if(!_player) return 0;
  
  QTTime qt_duration = [_player duration];
  NSTimeInterval interval;
  QTGetTimeInterval(qt_duration, &interval);
  result = (double)interval;

  //LOG(@"ATVFMUsicPlayer trackDuration -> %f", result);
  return result;
}

- (float)bufferingProgress {
  float result = [super bufferingProgress];
  // LOG(@"ATVFMusicPlayer bufferingProgress -> %f", result);
  return result;
}

- (id)currentChapterTitle {
  id result = [super currentChapterTitle];
  // LOG(@"ATVFMusicPlayer currentChapterTitle -> (%@)%@", [result class], result);
  return result;
}

- (void)setMuted:(BOOL)fp8 {
  // LOG(@"ATVFMusicPlayer setMuted:%d", fp8);
  [super setMuted:fp8];
}

- (BOOL)muted {
  BOOL result = [super muted];
  // LOG(@"ATVFMusicPlayer muted -> %d", result);
  return result;
}

-(void)_qtNotification:(id)notification {
  if([[notification name] isEqualTo:QTMovieDidEndNotification]) {
    // LOG(@"End of song!");
    // stop playing
    if(![self _nextTrack]) [self stop];
  };
}

-(BOOL)headless {
  return NO;
}

-(BOOL)initiatePlayback:(NSError **)error headless:(BOOL)headless {
  // LOG(@"-ATVFMusicPlayer initiatePlayback:headless:%d", headless);
  
  return [self initiatePlayback:error];
}

- (BOOL)initiatePlayback:(id *)fp8 {
  // LOG(@"ATVFMusicPlayer initiatePlayback");
  BOOL result = NO;
  
  if(_player) {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_player];
    [_player stop];
    //[self setPlayerState:kBRMusicPlayerStateStopped];
    [_player release];
    _player = nil;
  }
  
  LOG(@"Asset: %@, url: (%@)%@", _asset, [[_asset mediaURL] class], [_asset mediaURL]);
  _player = [QTMovie movieWithURL:[NSURL URLWithString:[_asset mediaURL]] error:fp8];
  if(!_player) {
    LOG(@"Unable to initiate playback.");
    result = NO;
    [self setPlayerState:kBRMusicPlayerStateStopped];
  } else {
    [_player retain];
    [_player gotoBeginning];
    
    // set the duration
    [_asset setDuration:[self trackDuration]];
    // LOG(@"** Duration: %f -> %d", [self trackDuration], [_asset duration]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_qtNotification:) name:QTMovieDidEndNotification object:_player];
    result = YES;
    [self _notifyAssetChanged];
    //[_asset setHasBeenPlayed:YES];
  }
  
  return result;
}

-(void)_playbackProgressChanged:(id)obj {
  //LOG(@"Notify progress changed");
  [[NSNotificationCenter defaultCenter] postNotificationName:kBRMediaPlayerPlaybackProgressChanged object:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"BRMPPlaybackProgressChanged" object:self];
}

-(void)_notifyAssetChanged {
  [[NSNotificationCenter defaultCenter] postNotificationName:kBRMediaPlayerCurrentAssetChanged object:_asset];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"BRMPCurrentAssetChanged" object:_asset];
}

- (void)play {
  LOG_MARKER;
  
  // LOG(@"ATVFMusicPlayer play");
  [self setPlayerState:kBRMusicPlayerStatePlaying];
  [_player play];
  [self _playbackProgressChanged:nil];
  
  [_asset setHasBeenPlayed:YES];
  
  // set timer
  [_updateTimer invalidate];
  _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(_playbackProgressChanged:) userInfo:nil repeats:YES];
}

-(void)_seek {
  // adjust if we're in seek mode
  if(_seeking != 0) {
    [self setElapsedPlaybackTime:[self elapsedPlaybackTime] + (5.0f * _seeking)];
  }
}

-(void)_startSeeking {
  [_seekTimer invalidate];
  _seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(_seek) userInfo:nil repeats:YES];
}

-(void)_stopSeeking {
  [_seekTimer invalidate];
  _seekTimer = nil;
  _seeking = 0;
}

- (void)pause {
  // LOG(@"ATVFMusicPlayer pause");
  [self setPlayerState:kBRMusicPlayerStatePaused];
  [_player stop];
  [self _playbackProgressChanged:nil];
  // invalidate timer
  [_updateTimer invalidate];
  _updateTimer = nil;
}

- (void)stop {
  // LOG(@"ATVFMusicPlayer stop");
  [self setPlayerState:kBRMusicPlayerStateStopped];
  [_player stop];
  [self _playbackProgressChanged:nil];
  [_updateTimer invalidate];
  _updateTimer = nil;
  [self _stopSeeking];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_player release];
  _player = nil;
  
  // notify delegates
  if(delegate) [delegate musicPlaybackStopped];
}

- (void)pressAndHoldLeftArrow {
  // LOG(@"ATVFMusicPlayer pressAndHoldLeftArrow");
  _seeking = -1; // seek backwards
  [self _startSeeking];
}

- (void)pressAndHoldRightArrow {
  // LOG(@"ATVFMusicPlayer pressAndHoldRightArrow");
  _seeking = 1; // seek forward
  [self _startSeeking];
}

- (void)resume {
  // LOG(@"ATVFMusicPlayer resume");
  _seeking = 0;
  [self _stopSeeking];
  [self play];
}

- (void)leftArrowClick {
  // LOG(@"ATVFMusicPlayer leftArrowClick");
  if(![self _previousTrack]) {
    [self stop];
  }
}

- (void)rightArrowClick {
  //LOG(@"ATVFMusicPlayer rightArrowClick");
  if(![self _nextTrack]) {
    [self stop];
  }
}

-(BOOL)_nextTrack {
  long index = [_myTracklist indexOfObject:_asset];
  LOG_MARKER;
  LOG(@"index: %d, tracklist: %@", index, _myTracklist);
  
  if(index < ([_myTracklist count] - 1)) {
    [self setMedia:[_myTracklist objectAtIndex:(index + 1)] inTracklist:_myTracklist error:nil];
    [self initiatePlayback:nil];
    [self play];
    return YES;
  } else {
    return NO;
  }
}

-(BOOL)_previousTrack {
  long index = [_myTracklist indexOfObject:_asset];
  if(index > 0) {
    [self setMedia:[_myTracklist objectAtIndex:(index - 1)] inTracklist:_myTracklist error:nil];
    [self initiatePlayback:nil];
    [self play];
    return YES;
  } else {
    return NO;
  }
}

// DELEGATE METHODS
-(id<ATVFMusicPlayerDelegate>)delegate {
  return delegate;
}

-(void)setDelegate:(id<ATVFMusicPlayerDelegate>)del {
  [delegate release];
  delegate = [del retain];
}

@end