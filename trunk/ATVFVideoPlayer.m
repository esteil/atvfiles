//
//  ATVFVideoPlayer.m
//  ATVFiles
//
//  Created by Eric Steil III on 7/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideoPlayer.h"

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

-(BOOL)setMedia:(id)fp8 error:(id *)fp12 {
  LOG(@"In ATVFVideoPlayer -setMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, [*fp12 class], *fp12);
  LOG(@"  _video is: (%@)%@", [_video class], _video);
  BOOL result = [super setMedia:fp8 error:fp12];
  LOG(@"  after super _video is: (%@)%@", [_video class], _video);
  LOG(@"     fp12: (%@)%@", [*fp12 class], *fp12);
  LOG(@"  -> %d", result);
  return result;
}

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
-(BOOL)prerollMedia:(id *)error {
  LOG(@"In ATVFVideoPlayer -prerollMedia");
  
  if(_video) return YES;
  
  _video = [[[ATVFVideo alloc] initWithMedia:[self media] attributes:[self movieAttributes] error:error] retain];
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
    } else {
      // 1.0
      LOG(@"Want 1.1 resetPlayer kthx");
      [_stateMachine reset];
      int startTimeInSeconds = [[self media] startTimeInSeconds];
      int duration = [[self media] duration];
      [_video setElapsedTime:0];
      [self _updateAspectRatio];
      [self _postAction:1 playSound:YES];
      
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

@end
