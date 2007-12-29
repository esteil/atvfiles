//
// ATVFMusicPlayer.h
// ATVFiles
//
// Created by Eric Steil III on 6/29/07.
// Copyright (C) 2007 Eric Steil III
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
