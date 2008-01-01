//
// ATVFVideoPlayer.m
// ATVFiles
//
// Created by Eric Steil III on 7/27/07.
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

#import "ATVFVideoPlayer.h"
#import "ATVFPreferences.h"

@interface BRVideo (QTMovieAccessor)
-(QTMovie *)getMovie;
-(void)setMovie:(QTMovie *)movie;
@end

@implementation BRVideo (QTMovieAccessor)
-(QTMovie *)getMovie {
  return _movie;
}

-(void)setMovie:(QTMovie *)movie {
  [_movie release];
  _movie = movie;
  [_movie retain];
}
@end

@implementation ATVFVideoPlayer

-(ATVFVideoPlayer *)init {
  LOG(@"In -[ATVFVideoPlayer init]");
  [super init];
  playlist = nil;
  playlist_offset = -1;
  playlist_count = -1;
  _subtitlesEnabled = NO;
  return self;
}

-(void)dealloc {
  [playlist release];
  [_video release];
  [super dealloc];
}

-(int)currentPlaylistOffset {
  return playlist_offset;
}

-(int)currentPlaylistLength {
  return playlist_count;
}

-(ATVFMediaAsset *)playlistAssetAtOffset:(int)offset {
  return [[playlist playlistContents] objectAtIndex:offset];
}

-(void)_videoPlaybackHitEndHandler:(id)fp8 {
  LOG(@"In -[ATVFVideoPlayer _videoPlaybackHitEndHandler:], args: (%@)%@", [fp8 class], fp8);
  
  if(playlist) {
    playlist_offset++;
    if(playlist_offset < playlist_count) {
      LOG(@"Next playlist item: %d/%d -> %@", playlist_offset, playlist_count, [[[playlist playlistContents] objectAtIndex:playlist_offset] mediaURL]);
      [self switchToPlaylistOffset:playlist_offset];
    } else {
      LOG(@"All done playing");
      [self _postAction:12 playSound:NO];
    }
  } else {
    // no playlist
    LOG(@"All done playing");
    [self _postAction:12 playSound:NO];
  }
  
  // playlist_offset++;
  // if(playlist_offset >= playlist_count) {
  //   LOG(@"All done playing!");
  //   [self _postAction:12 playSound:NO];
  // } else {
  //   LOG(@"More in playlist!");
  //   [self setElapsedPlaybackTime:0];
  //   // [self _postAction:2 playSound:0];
  //   // [self _postAction:0 playSound:0];
  //   // [self pause];
  //   // [self play];
  // }
  // [super _videoPlaybackHitEndHandler:fp8];
}

// Switch the playlist to play at this offset.
-(BOOL)switchToPlaylistOffset:(int)offset {
  LOG(@"-switchToPlaylistOffset:%d", offset);
  if(playlist && offset < playlist_count && offset >= 0) {
    playlist_offset = offset;

    NSError *error = nil;
    [super setMedia:[[playlist playlistContents] objectAtIndex:playlist_offset] error:&error];
    if(error != nil) {
      [error postBRErrorNotificationFromObject:self];
      return NO;
    }

    [self initiatePlayback:&error];
    if(error != nil) {
      [error postBRErrorNotificationFromObject:self];
      return NO;
    }

    [self setElapsedPlaybackTime:0];
    
    return YES;
  } else {
    LOG(@"Conditions failed");
    return NO;
  }
}

-(BOOL)previousPlaylistEntry {
  LOG(@"previousPlaylistEntry");
  return [self switchToPlaylistOffset:playlist_offset - 1];  
}

-(BOOL)nextPlaylistEntry {
  LOG(@"nextPlaylistEntry");
  return [self switchToPlaylistOffset:playlist_offset + 1];
}

-(void)_postAction:(int)fp8 playSound:(BOOL)fp12 {
  LOG(@"In -[ATVFVideoPlayer _postAction:playSound:], args: %d %d", fp8, fp12);
  [super _postAction:fp8 playSound:fp12];
}

-(BOOL)setMedia:(id)asset error:(NSError **)error {
  LOG(@"In ATVFVideoPlayer -setMedia:(%@)%@ error:", [asset class], asset);
  BOOL result;
  
  if([asset isKindOfClass:[ATVFPlaylistAsset class]]) {
    LOG(@"We have a playlist, storing it and setting my asset to first entry");
    playlist = [asset retain];
    playlist_count = [[playlist playlistContents] count];
    playlist_offset = 0;
    [_video release];
    _video = nil;
    result = [super setMedia:[[playlist playlistContents] objectAtIndex:0] error:error];
  } else {
    LOG(@"Regular asset");
    playlist_offset = 0;
    playlist_count = 1;
    playlist = nil;
    result = [super setMedia:asset error:error];
  }
  return result;
}

-(BOOL)old_setMedia:(id)fp8 error:(id *)fp12 {
  LOG(@"In ATVFVideoPlayer -setMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, [*fp12 class], *fp12);
  BOOL result = [super setMedia:fp8 error:fp12];
  LOG(@"  -> %d", result);
  return result;
}

#ifdef ENABLE_1_0_COMPATABILITY
// initialize our own media asset here?
-(BOOL)old_prerollMedia:(id *)fp8 {
  LOG(@"In ATVFVideoPlayer -prerollMedia:(%@)%@", nil, nil);//, [*fp8 class], *fp8);
  LOG(@"  _video is: (%@)%@", [_video class], _video);
  // BOOL result = [super prerollMedia:fp8];
  BOOL result = YES;
  [super prerollMedia:fp8];
  _video = [[[ATVFVideo alloc] initWithMedia:[self media] error:fp8] retain];
  [_video setPlaybackContext:[self playbackContext]];
  LOG(@"  after super _video is: (%@)%@", [_video class], _video);
  // LOG(@"     fp8: (%@)%@", [*fp8 class], *fp8);
  LOG(@"  -> %d", result);
  return result;
}

-(BOOL)new_newprerollMedia:(id *)error {
  BOOL result = [super prerollMedia:error];
  LOG(@"In prerollMedia: Video movie is: (%@)%@", [[_video getMovie] class], [_video getMovie]);
  // QTMovie *movie = [QTMovie movieWithFile:@"/Users/steile/Desktop/iShowU-Capture.mov"];
  // [_video setMovie:movie];
  
  return result;
}
#endif

-(BOOL)prerollMedia:(id *)error {
  LOG(@"In ATVFVideoPlayer -prerollMedia");
  
  if(_video) return YES;
  
  [_video release];
  _video = [[[ATVFVideo alloc] initWithMedia:[self media] attributes:[self movieAttributes] error:error] retain];
  // _video = [[ATVFVideo alloc] initWithMedia:[self media] attributes:[self movieAttributes] error:error];
  // if(!error) {
    [_video setMuted:NO];
    [_video setLoops:[self movieLoops]];
    [_video setCaptionsEnabled:[self captionsEnabled]];
    [_video setGatherPlaybackStats:YES];
    [_video setContextSize:[self contextSizeHint]];
    [_video setPlaybackContext:[self playbackContext]];
    
    if([self respondsToSelector:@selector(resetPlayer)]) {
      // 1.1
      LOG(@"Calling 1.1 resetPlayer");
      [self resetPlayer];
#ifdef ENABLE_1_0_COMPATABILITY
    } else {
      // 1.0
      LOG(@"Want 1.1 resetPlayer kthx");
      [_stateMachine reset];
      int startTimeInSeconds = [[self media] startTimeInSeconds];
      int duration = [[self media] duration];
      [_video setElapsedTime:0];
      [self _updateAspectRatio];
      [self _postAction:1 playSound:YES];
#endif
    }
    
    // [self resetPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlayableHandler:) name:@"BRVideoPlayable" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoRateDroppedHandler:) name:@"BRVideoRateDropped" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackHitEndHandler:) name:@"BRVideoHitEnd" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackHitBeginningHandler:) name:@"BRVideoHitBeginning" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoLoadErrorNotification:) name:@"BRVideoLoadError" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoAspectRatioNotification:) name:@"BRVideoAspectRatioUpdate" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoTimeChangedNotification:) name:@"BRVideoTimeChangedNotification" object:_video];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoBufferingChangedNotification:) name:@"BRVideoBufferingProgressChangedNotification" object:_video];
    
    // enable/disable subtitles according to prefs
    [self setSubtitlesEnabled:[[ATVFPreferences preferences] boolForKey:kATVPrefEnableSubtitlesByDefault]];
    
    return YES;
  // } else {
  //   return NO;
  // }
}
#if 0
[BRQTKitVideoPlayer prerollMedia:fp8] {
  if(!_video) {
    NSError *error;
    _video = [[BRVideo alloc] initWithMedia:fp8 attributes:[fp8 movieAttributes] error:error];
    if(!error) {
      [_video setMuted:NO];
      [self setLoops:[_video movieLoops]];
      [self setCaptionsEnabled:[_video captionsEnabled]];
      [self setGatherPlaybackStats:NO];
      [self setContextSize:[_video contextSizeHint]];
      [self setPlaybackContext:[_video playbackContext]];
      [self resetPlayer];
      [NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlayableHandler:) name:BRVideoPlayable object:_video];
      [NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoRateDroppedHandler:) name:BRVideoRateDropped object:_video];
      [NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_videoPlaybackHitEndHandler:) name:BRVideoHitEnd object:_video];
      notificaton addObserver:self selector:@selector(_videoPlaybackHitBeginningHandler:) name:BRVideoHitBeginning object:_video;
      notification BRVideoLoadError -> _videoLoadErrorNotification:
      notification BRVideoAspectRatioUpdate -> _videoAspectRatioNotification:
      notification BRVideoTimeChangedNotification -> _videoTimeChangedNotification:
      notification BRVideoBufferingProgressChangedNotification -> _videoBufferingChangedNotification:
      if [_video movieLoops]; [self setLoops:YES];
      if [_video captionsEnabled]; [self setCaptionsEnabled:YES];
      []
    } else {
    }
  }
}
#endif
-(BOOL)initiatePlayback:(id *)fp8 {
  LOG(@"In ATVFVideoPlayer -initiatePlayback:(%@)%@", nil, nil);//, [*fp8 class], *fp8);
  LOG(@"  _video is: (%@)%@", [_video class], _video);
  BOOL result = [super initiatePlayback:fp8];
  LOG(@"  after super _video is: (%@)%@", [_video class], _video);
  // LOG(@"     fp8: (%@)%@", [*fp8 class], *fp8);
  LOG(@"  -> %d", result);
  return result;
}

-(BOOL)hasSubtitles {
  return [(ATVFVideo *)_video hasSubtitles];
}

-(void)setSubtitlesEnabled:(BOOL)enabled {
  _subtitlesEnabled = enabled;
  
  // toggle it in _video here
  [(ATVFVideo *)_video enableSubtitles:enabled];
}

-(BOOL)subtitlesEnabled {
  return _subtitlesEnabled;
}


@end
