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
#import <AudioUnit/AudioUnit.h>
#import "ATVFCoreAudioHelper.h"

// passthrough stuff
#define A52_DOMAIN (CFStringRef)@"com.cod3r.a52codec"
#define PASSTHROUGH_KEY (CFStringRef)@"attemptPassthrough"

// compatibility interfaces
@interface BRQTKitVideoPlayer (ATV22Compat)
-(BOOL)setMedia:(id)media inCollection:(id)collection error:(NSError **)error;
-(BOOL)setMedia:(id)media inTrackList:(id)trackList error:(NSError **)error;
-(BOOL)setMediaAtIndex:(long)index inTrackList:(id)trackList error:(NSError **)error;
-(BOOL)cueMediaWithError:(NSError **)error;
-(void)nextMedia;
-(void)previousMedia;
@end

@interface BRMediaPlayer (ATV22Compat)
-(BOOL)setState:(int)state error:(NSError **)error;
-(double)duration;
-(double)elapsedTime;
-(void)setElapsedTime:(double)time;
@end

// other custom accessors
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
-(Track)ATVF_getMovieTrack;
@end

@implementation BRVideo (ATVFQTMovieAccessor)
-(QTMovie *)ATVF_getMovie {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_movie");
  
  return *(QTMovie * *)(((char *)self)+ret->ivar_offset);
}

-(Track)ATVF_getMovieTrack {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_movieTrack");
  
  return *(Track *)(((char *)self)+ret->ivar_offset);
}
@end


@class BRVideoTasker;

@interface ATVFVideoPlayer (Private)
-(QTMovie *)_getMovie:(NSError **)error;
-(void)_setupPassthrough:(QTMovie *)movie;
-(void)_resetPassthrough;
@end

@implementation ATVFVideoPlayer

-(ATVFVideoPlayer *)init {
  LOG(@"In -[ATVFVideoPlayer init]");
  [super init];
  LOG_MARKER;
  
  playlist = nil;
  playlist_offset = -1;
  playlist_count = -1;
  
  LOG_MARKER;
  
  _subtitlesEnabled = NO;
  _needToStack = YES;
  //_myQTMovie = nil;
  
  LOG_MARKER;
  
  return self;
}

-(void)dealloc {
  LOG_MARKER;
  [super dealloc];

  [playlist release];
  //[_myQTMovie release];
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

-(void)nextMedia {
  LOG_MARKER;
  [super nextMedia];
}

-(void)previousMedia {
  LOG_MARKER;
  [super previousMedia];
}

-(void)_videoPlaybackHitEndHandler:(id)fp8 {
  LOG(@"In -[ATVFVideoPlayer _videoPlaybackHitEndHandler:], args: (%@)%@", [fp8 class], fp8);
  
  [self _resetPassthrough];
  
  /*ATV_22 {
    [super _videoPlaybackHitEndHandler:fp8];
    return;
  }*/
  
  if(playlist) {
    playlist_offset++;
    if(playlist_offset < playlist_count) {
      LOG(@"Next playlist item: %d/%d -> %@", playlist_offset, playlist_count, [[[playlist playlistContents] objectAtIndex:playlist_offset] mediaURL]);
      [self switchToPlaylistOffset:playlist_offset];
    } else {
      LOG(@"All done playing playlist");
      [super _videoPlaybackHitEndHandler:fp8];
    }
  } else {
    // no playlist
    LOG(@"All done playing");
    [super _videoPlaybackHitEndHandler:fp8];
  }
}

// Switch the playlist to play at this offset.
-(BOOL)switchToPlaylistOffset:(int)offset {
  LOG(@"-switchToPlaylistOffset:%d", offset);
  LOG_ARGS("playlist: %@, offset: %d, playlist_count: %d", playlist, offset, playlist_count);
  
  if(playlist && offset < playlist_count && offset >= 0) {
    playlist_offset = offset;

    LOG(@" Asset -> %@", [[playlist playlistContents] objectAtIndex:playlist_offset]);
    
    //[_myQTMovie release];
    //_myQTMovie = nil;
    
    NSError *error = nil;
    
    LOG_MARKER;
    
    ATV_22 {
      LOG_MARKER;
      [super setMedia:[[playlist playlistContents] objectAtIndex:playlist_offset] inTrackList:[playlist playlistContents] error:&error];
    } else {
      LOG_MARKER;
      [super setMedia:[[playlist playlistContents] objectAtIndex:playlist_offset] error:&error];
    }

    LOG_MARKER;
    
    if(error != nil) {
      LOG_ARGS(@"Error: %@", error);
      [error postBRErrorNotificationFromObject:self];
      return NO;
    }
    
    LOG_MARKER;

    NOT_ATV_22 [self initiatePlayback:&error];
    
    LOG_MARKER;
    
    if(error != nil) {
      [error postBRErrorNotificationFromObject:self];
      return NO;
    }

    LOG_MARKER;
    
    ATV_22 [self setElapsedTime:0];
    else   [self setElapsedPlaybackTime:0];
    
    ATV_22 [self play];
    
    LOG_MARKER;
    
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
  LOG_MARKER;
  return [self setMedia:asset inTrackList:[NSArray arrayWithObject:asset] error:error];
}

-(BOOL)setMedia:(id)asset inTrackList:(id)trackList error:(NSError **)error {
  LOG_MARKER;
  LOG(@"In ATVFVideoPlayer -setMedia:(%@)%@ error:", [asset class], asset);
  BOOL result;
  
  //[_myQTMovie release];
  //_myQTMovie = nil;
  
  if([asset isKindOfClass:[ATVFPlaylistAsset class]]) {
    LOG(@"We have a playlist, storing it and setting my asset to first entry");
    playlist = [asset retain];
    playlist_count = [[playlist playlistContents] count];
    playlist_offset = 0;
    [_video release];
    _video = nil;
    _needToStack = YES;
    
    ATV_23      result = [super setMediaAtIndex:0 inTrackList:[playlist playlistContents] error:error];
    else ATV_22 result = [super setMedia:[[playlist playlistContents] objectAtIndex:0] inTrackList:[playlist playlistContents] error:error];
    else        result = [super setMedia:[[playlist playlistContents] objectAtIndex:0] error:error];
  } else {
    LOG(@"Regular asset");
    playlist_offset = 0;
    playlist_count = 1;
    playlist = nil;
    _needToStack = YES;
    ATV_23      result = [super setMediaAtIndex:0 inTrackList:trackList error:error];
    else ATV_22 result = [super setMedia:asset inTrackList:trackList error:error];
    else        result = [super setMedia:asset error:error];
  }
  
  return result;
}

-(BOOL)setState:(long)state error:(id*)error {
  LOG_ARGS("State: %d", state);
  
  if(state == kBRMediaPlayerStatePlaying) {
    [self _setupPassthrough:nil];
  } else if(state == kBRMediaPlayerStateStopped) {
    //[self updateBookmarkTime];
  }

  BOOL ret = [super setState:state error:error];
  return ret;
}

// ATV 2.1 passthrough setup
-(BOOL)prerollMedia:(id *)error {
  BOOL ret = [super prerollMedia:error];
  
  QTMovie *theMovie = [self _getMovie:error];
  [self _setupPassthrough:theMovie];
  
  // save the duration
  NSTimeInterval theDuration;
  if(QTGetTimeInterval([theMovie duration], &theDuration)) {
    [(ATVFMediaAsset *)[self media] setDuration:theDuration];
  }
  
  return ret;
}

// update the bookmark time *AND DURATION* of the video.
// ATV23 this is the best place to be called after the video
// has been loaded and duration determined.
-(void)updateBookmarkTime {
  ATVFMediaAsset *asset = [self media];

  // apparently without doing the explicit casts like this, the
  // wrong value gets set on 2.3.
  ATV_22 {
    double the_duration = [self duration];
    long duration_seconds = (long)the_duration;
    [asset setDuration:duration_seconds];
  }

  double the_elapsed_time;
  ATV_22 the_elapsed_time = [self elapsedTime];
  else   the_elapsed_time = [self elapsedPlaybackTime];
  long elapsed_time_seconds = (long)the_elapsed_time;
  
  [asset setBookmarkTimeInSeconds:elapsed_time_seconds];
}

// OLD STACKING CODE
-(BOOL)old_prerollMedia:(id *)error {
  LOG(@"prerollMedia:");
  // ATV2 debugging
  BOOL ret = NO;
  NSError *theError = nil;
  
  if([SapphireFrontRowCompat usingTakeTwoDotTwo])
    ret = [super cueMediaWithError:error];
  else
    ret = [super prerollMedia:error];

  if(!ret) return ret;
  
  QTMovie *theMovie = [self _getMovie:&theError];
  
  if(theError) {
    LOG(@"Error getting QTMovie, skipping stacking: %@", *error);
    return ret;
  }
  
  if(_needToStack) {
    ATVFMediaAsset *asset = [self media];
    
    // deal with stacking HERE, instead of in the now-dead BRVideo subclass.
    
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
        NSTimeInterval theDuration;
        if(QTGetTimeInterval([theMovie duration], &theDuration))
          duration = theDuration;
      }
    }
    LOG(@"_video: (%@)%@", [theMovie class], theMovie);
    
    _needToStack = NO;

    // update the asset duration
    NSTimeInterval myDuration;
    if(QTGetTimeInterval([theMovie duration], &myDuration)) {
      [asset setDuration:myDuration];
    } else {
      LOG(@"Unable to get duration!");
      return ret;
    }
    
    // set up subtitles by default
    [self setSubtitlesEnabled:[[ATVFPreferences preferences] boolForKey:kATVPrefEnableSubtitlesByDefault]];
    
    LOG(@"Going to updateTrackInfo");
    [[self ATVF_getVideo] _updateTrackInfoWithError:&theError];
    LOG(@"Error updateTrackInfo: %@", theError);
  } // need to stack
  
  // we reset before setting, in the case of playlists to not end up defaulting to
  // no ui sounds.
  //[self _resetPassthrough];
  [self _setupPassthrough:theMovie];
  
  return ret;
}

-(BOOL)hasSubtitles {
  LOG(@"In -hasSubtitles");
  NSError *error = nil;
  QTMovie *theMovie = [self _getMovie:&error];
  if(error) {
    ELOG(@"Error getting movie: %@", error);
    return NO;
  }
  NSArray *tracks = [theMovie tracksOfMediaType:QTMediaTypeVideo];
  
  LOG(@"Tracks: %@ -> %@", tracks, [theMovie tracks]);
  
  int i = 0;
  int num = [tracks count];
  BOOL isSubtitle = NO;
  
  for(i = 0; i < num; i++) {
    QTTrack *track = [tracks objectAtIndex:i];
    LOG(@"Track %d: %@ -> %@ (Media: %@)", i, track, [track trackAttributes], [[track media] mediaAttributes]);
    // i'm not sure if this is a good way to check, but it seems to work for perian at least.
    if([(NSNumber *)[track attributeForKey:QTTrackLayerAttribute] shortValue] == -1)
      isSubtitle = YES;
  }
  
  return isSubtitle;
  
}

-(void)setSubtitlesEnabled:(BOOL)enabled {
  _subtitlesEnabled = enabled;
  
  // toggle it
  NSError *error = nil;
  QTMovie *theMovie = [self _getMovie:&error];
  NSArray *tracks = [theMovie tracksOfMediaType:QTMediaTypeVideo];
  
  LOG(@"Subtitle tracks: %@", tracks);
  int i;
  int num = [tracks count];
  BOOL done = NO;
  for(i = 0; i < num; i++) {
    // this is a hack, but QTTrackLayerAttribute == -1 means subtitle, maybe
    QTTrack *track = [tracks objectAtIndex:i];
    
    if([(NSNumber *)[track attributeForKey:QTTrackLayerAttribute] shortValue] == -1) {
      LOG(@"Setting enabled:%d on track %d", enabled, i);
      if(!done) [track setEnabled:enabled];
      done = YES;
    } else {
      [track setEnabled:YES];
    }
    LOG(@"Track %d: %@ -> %@ (Media: %@)", i, track, [track trackAttributes], [[track media] mediaAttributes]);
  }  
}

-(BOOL)subtitlesEnabled {
  return _subtitlesEnabled;
}

// compatibility methods
-(void)play {
  if(![SapphireFrontRowCompat usingTakeTwoDotTwo])
    [super play];
  else
    [self setState:kBRMediaPlayerStatePlaying error:nil];
}

-(void)pause {
  if(![SapphireFrontRowCompat usingTakeTwoDotTwo])
    [super pause];
  else
    [self setState:kBRMediaPlayerStatePaused error:nil];
}
@end

// Audio setup, replaces ATVFCoreAudioHelper
// From Sapphire SapphireBrowser.m
BOOL findCorrectDescriptionForStream(AudioStreamID streamID, int sampleRate) {
	OSStatus err;
	UInt32 propertySize = 0;
	err = AudioStreamGetPropertyInfo(streamID, 0, kAudioStreamPropertyPhysicalFormats, &propertySize, NULL);
	
	if(err != noErr || propertySize == 0)
		return NO;
	
	AudioStreamBasicDescription *descs = malloc(propertySize);
	if(descs == NULL)
		return NO;
	
	int formatCount = propertySize / sizeof(AudioStreamBasicDescription);
	err = AudioStreamGetProperty(streamID, 0, kAudioStreamPropertyPhysicalFormats, &propertySize, descs);
	
	if(err != noErr)
	{
		free(descs);
		return NO;
	}
	
	int i;
	BOOL ret = NO;
	for(i=0; i<formatCount; i++) 	{
		if (descs[i].mBitsPerChannel == 16 && descs[i].mFormatID == kAudioFormatLinearPCM) {
			if(descs[i].mSampleRate == sampleRate) {
				err = AudioStreamSetProperty(streamID, NULL, 0, kAudioStreamPropertyPhysicalFormat, sizeof(AudioStreamBasicDescription), descs + i);
				if(err != noErr)
					continue;
				ret = YES;
				break;
			}
		}
	}
	free(descs);
  
	return ret;
}

BOOL setupDevice(AudioDeviceID devID, int sampleRate) {
	OSStatus err;
	UInt32 propertySize = 0;
	err = AudioDeviceGetPropertyInfo(devID, 0, FALSE, kAudioDevicePropertyStreams, &propertySize, NULL);
	
	if(err != noErr || propertySize == 0)
		return NO;
	
	AudioStreamID *streams = malloc(propertySize);
	if(streams == NULL)
		return NO;
	
	int streamCount = propertySize / sizeof(AudioStreamID);
	err = AudioDeviceGetProperty(devID, 0, FALSE, kAudioDevicePropertyStreams, &propertySize, streams);
	if(err != noErr)
	{
		free(streams);
		return NO;
	}
	
	int i;
	BOOL ret = NO;
	for(i=0; i<streamCount; i++) {
		if(findCorrectDescriptionForStream(streams[i], sampleRate)) {
			ret = YES;
			break;
		}
	}
	free(streams);

	return ret;
}

BOOL setupAudioOutput(int sampleRate) {
	OSErr err;
	UInt32 propertySize = 0;
	
	err = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propertySize, NULL);
	if(err != noErr || propertySize == 0)
		return NO;
	
	AudioDeviceID *devs = malloc(propertySize);
	if(devs == NULL)
		return NO;
	
	err = AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propertySize, devs);
	if(err != noErr) {
		free(devs);
		return NO;
	}
	
	int i, devCount = propertySize/sizeof(AudioDeviceID);
	BOOL ret = NO;
	for(i=0; i<devCount; i++) {
		if(setupDevice(devs[i], sampleRate)) {
			err = AudioHardwareSetProperty(kAudioHardwarePropertyDefaultOutputDevice, sizeof(AudioDeviceID), devs + i);
			if(err != noErr)
				continue;
			ret = YES;
			break;
		}
	}
	free(devs);
	return ret;
}

@implementation ATVFVideoPlayer (Private)

-(void)_setupPassthrough:(QTMovie *)movie {
  LOG(@"_setupPassthrough: %@", movie);
  
  // this flag really indicates we're set up, so leave it.
  if(_needsPassthroughReset) return;
  
  // don't do ANYTHING if the preference is off
  if(![[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) return;
  
  // save the current state
  Boolean temp;
  _passthroughWasEnabled = CFPreferencesGetAppBooleanValue(PASSTHROUGH_KEY, A52_DOMAIN, &temp);
  _uiSoundsWereEnabled = [[SapphireFrontRowCompat sharedFrontRowPreferences] boolForKey:@"PlayFrontRowSounds"];
  
  BOOL useAC3Passthrough = NO;
  long ac3TrackIndex = 0;
  
  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) {
    if(movie) {
      Float64 sampleRate;
      UInt32 type;
      
      // get sound type and sample rate here
      // we look for the AC3 track and prefer that
      NSArray *audioTracks = [movie tracksOfMediaType:@"soun"];

      if([audioTracks count]) {
        QTTrack *track;
        BOOL done = NO;
        
        // find the AC3 track
        int i = 0;
        for(i = 0; i < [audioTracks count]; i++) {
          track = [audioTracks objectAtIndex:i];
          QTMedia *media = [track media];
          
          LOG(@"Considering track %d for ac3: %@ %@", i, track, media);
          
          if(media != nil) {
            // get audio stream description
            Media qtMedia = [media quickTimeMedia];
            Handle sampleDesc = NewHandle(1);
            
            GetMediaSampleDescription(qtMedia, 1, (SampleDescriptionHandle)sampleDesc);
            AudioStreamBasicDescription asbd;
            ByteCount propSize = 0;
            
            QTSoundDescriptionGetProperty((SoundDescriptionHandle)sampleDesc, 
                                          kQTPropertyClass_SoundDescription, 
                                          kQTSoundDescriptionPropertyID_AudioStreamBasicDescription, 
                                          sizeof(asbd), 
                                          &asbd, 
                                          &propSize);
            
            if(propSize != 0) {
              LOG(@"Track type: %x ('ac-3' = %x)", asbd.mFormatID, 'ac-3');
              if(asbd.mFormatID == 0x6D732000 || (![SapphireFrontRowCompat usingTakeTwo] && (asbd.mFormatID == 'ac-3'))) {
              //if(asbd.mFormatID == 0x6D732000 || asbd.mFormatID == 'ac-3') {
                LOG(@"Track type matches, using.");
                type = asbd.mFormatID;
                sampleRate = asbd.mSampleRate;
                
                ac3TrackIndex = i;
                done = YES;
              }
            }
            
            DisposeHandle(sampleDesc);
          }
          
          if(done) break;
        }
      }
      
      LOG(@"Sample rate before enable: %d", (int)[ATVFCoreAudioHelper systemSampleRate]);
      
      if((type == 0x6D732000 || (![SapphireFrontRowCompat usingTakeTwo] && (type == 'ac-3'))) && 
      //if((type == 0x6D732000 || type == 'ac-3') && 
         setupAudioOutput((int)sampleRate)) {
        LOG(@"AC3 track, type: %x, rate: %d, passthrough enabled", type, (int)sampleRate);
        useAC3Passthrough = YES;
      }
    } else {
      // ATV 2.2, this will always set it, and not adjust sample rate.  deal.
      useAC3Passthrough = YES;
    }
  }
  
  if(useAC3Passthrough) {
    LOG(@"Using AC3 passthrough!");
    _needsPassthroughReset = YES;
    
    // enable the AC3 track and disable the rest
    /*
    NSArray *audioTracks = [movie tracksOfMediaType:@"soun"];
    int i = 0;
    for(i = 0; i < [audioTracks count]; i++) {
      LOG(@"Enabling track %d: %d", i, (i == ac3TrackIndex));
      
      // [[audioTracks objectAtIndex:i] setEnabled:(i == ac3TrackIndex)];
    }
    */

    if(_uiSoundsWereEnabled)
      [[SapphireFrontRowCompat sharedFrontRowPreferences] setBool:NO forKey:@"PlayFrontRowSounds"];
    
    CFPreferencesSetAppValue(PASSTHROUGH_KEY, (CFNumberRef)[NSNumber numberWithInt:1], A52_DOMAIN);
  } else {
    LOG(@"Not using AC3 passthrough");
    
    _needsPassthroughReset = YES;
    
    // disable passthrough
    CFPreferencesSetAppValue(PASSTHROUGH_KEY, (CFNumberRef)[NSNumber numberWithInt:0], A52_DOMAIN);
  }
  CFPreferencesAppSynchronize(A52_DOMAIN);
}

-(void)_resetPassthrough {
  LOG(@"In _resetPassthrough: %d", _needsPassthroughReset);
  
  if(!_needsPassthroughReset) return;
  
  _needsPassthroughReset = NO;
  // reset to our saved state
  [[SapphireFrontRowCompat sharedFrontRowPreferences] setBool:_uiSoundsWereEnabled forKey:@"PlayFrontRowSounds"];
  CFPreferencesSetAppValue(PASSTHROUGH_KEY, (CFNumberRef)[NSNumber numberWithInt:_passthroughWasEnabled], A52_DOMAIN);
  CFPreferencesAppSynchronize(A52_DOMAIN);
}

-(QTMovie *)_getMovie:(NSError **)error {
  //if(_myQTMovie) return _myQTMovie;
  
  QTMovie *theMovie = [[self ATVF_getVideo] ATVF_getMovie];
  
  // on ATV2, theMovie is actually a Movie, so we need a QTMovie from it.
  if([SapphireFrontRowCompat usingTakeTwo]) {
    theMovie = [QTMovie movieWithQuickTimeMovie:(Movie)theMovie disposeWhenDone:NO error:error];
    if(*error) {
      ELOG(@"Error getting QTMovie from Movie: %@", *error);
      return nil;
    }
  }
  
  //_myQTMovie = [theMovie retain];

  return theMovie;
}
@end
