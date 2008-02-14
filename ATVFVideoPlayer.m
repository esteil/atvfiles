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
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>
#import <objc/objc-class.h>

@interface BRQTKitVideoPlayer (ATVFQTMovieAccessor)
-(BRVideo *)ATVF_getVideo;
@end

@implementation BRQTKitVideoPlayer (ATVFQTMovieAccessor)
-(BRVideo *)ATVF_getVideo {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_video");
  
  return *(BRVideo * *)(((char *)self)+ret->ivar_offset);
}
@end

@interface BRVideo (ATVFQTMovieAccessor)
-(QTMovie *)ATVF_getMovie;
@end

@implementation BRVideo (ATVFQTMovieAccessor)
-(QTMovie *)ATVF_getMovie {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_movie");
  
  return *(QTMovie * *)(((char *)self)+ret->ivar_offset);
}
@end

@class BRVideoTasker;

@implementation ATVFVideoPlayer

-(ATVFVideoPlayer *)init {
  LOG(@"In -[ATVFVideoPlayer init]");
  [super init];
  playlist = nil;
  playlist_offset = -1;
  playlist_count = -1;
  _subtitlesEnabled = NO;
  _needToStack = YES;
  return self;
}

-(void)dealloc {
  [playlist release];
  playlist = nil;
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
    _needToStack = YES;
    result = [super setMedia:[[playlist playlistContents] objectAtIndex:0] error:error];
  } else {
    LOG(@"Regular asset");
    playlist_offset = 0;
    playlist_count = 1;
    playlist = nil;
    _needToStack = YES;
    result = [super setMedia:asset error:error];
  }
  return result;
}

-(BOOL)prerollMedia:(id *)error {
  // ATV2 debugging
  BOOL ret;
  NSError *theError = nil;
  
  ret = [super prerollMedia:error];

  if(!ret) return ret;

  if(_needToStack) {
    QTMovie *theMovie = [[self ATVF_getVideo] ATVF_getMovie];
    ATVFMediaAsset *asset = [self media];
    
    // deal with stacking HERE, instead of in the now-dead BRVideo subclass.
    
    // on ATV2, theMovie is actually a Movie, so we need a QTMovie from it.
    if(NSClassFromString(@"BRBaseAppliance")) {
      theMovie = [QTMovie movieWithQuickTimeMovie:(Movie)theMovie disposeWhenDone:NO error:&theError];
      if(theError) {
        LOG(@"Error getting QTMovie from Movie, skipping stacking: %@", *error);
        return ret;
      }
    }
    
    LOG(@"Movie: (%@)%@", [theMovie class], theMovie);
    
    // stack here
    [theMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
    
    // Is this a stack where we have to append to the video?
    if([asset isStack]) {
      LOG(@"Asset %@ is stack: %@", asset, [asset stackContents]);
      int i;
      int count = [[asset stackContents] count];
      
      LOG(@" Movie duration is now: %@", QTStringFromTime([theMovie duration]));
      
      for(i = 1; i < count; i++) {
        NSURL *segmentURL = [[asset stackContents] objectAtIndex:i];
        LOG(@" Adding %@ to playback", segmentURL);
        
        QTDataReference *segmentRef = [QTDataReference dataReferenceWithReferenceToURL:segmentURL];
        LOG(@"Ref: %@", segmentRef);
        QTMovie *segment = [QTMovie movieWithDataReference:segmentRef error:&theError];
        if(theError) {
          LOG(@"Error adding segment: %@", theError);
          break;
        }
        
        // add it
        [theMovie insertSegmentOfMovie:segment timeRange:QTMakeTimeRange(QTZeroTime, [segment duration]) atTime:[theMovie duration]];
        
        LOG(@" Movie duration is now: %@", QTStringFromTime([theMovie duration]));
      }
    }
    LOG(@"_video: (%@)%@", [theMovie class], theMovie);
    
    _needToStack = NO;

    // update the asset duration
    NSTimeInterval duration;
    if(QTGetTimeInterval([theMovie duration], &duration)) {
      [asset setDuration:duration];
    } else {
      LOG(@"Unable to get duration!");
      return ret;
    }
    
    LOG(@"Going to updateTrackInfo");
    [[self ATVF_getVideo] _updateTrackInfoWithError:&theError];
    LOG(@"Error updateTrackInfo: %@", theError);
  } // need to stack
  
  return ret;
}

-(BOOL)hasSubtitles {
  return NO;
  // FIXME: integrate hasSubtitles from ATVFVideo
  
  //return [(ATVFVideoPlayer *)[self ATVF_getMovie] hasSubtitles];
}

-(void)setSubtitlesEnabled:(BOOL)enabled {
  return;
  
  // FIXME: integrate enableSubtitles: from ATVFVideo
  //_subtitlesEnabled = enabled;
  
  // toggle it in _video here
  //[(ATVFVideo *)_video enableSubtitles:enabled];
}

-(BOOL)subtitlesEnabled {
  return _subtitlesEnabled;
}


@end
