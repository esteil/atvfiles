//
// ATVFVideo.m
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

#import "ATVFVideo.h"
#import <QTKit/QTKit.h>
#import "ATVFMediaAsset.h"
#include <objc/objc-class.h>
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>

#define NUM_LANGUAGES 151

// FrontRow compatibility
@interface BRVideo (FRCompat)
-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 allowAllMovieTypes:(BOOL)allowAll error:(id *)fp16;
-(id)initWithMedia:(id)fp8 error:(id *)fp12;
@end

@interface ATVFVideo (PrivateMethods)
-(void)_getLanguages;
-(QTMovie *)_getMovie;
@end

@implementation ATVFVideo

-(QTMovie *)_getMovie {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_movie");
  
  QTMovie *theMovie = *(QTMovie * *)(((char *)self)+ret->ivar_offset);
  
  // ATV2, need to convert it.
  // ATV2, make it really a QTMovie because it's just a Movie
  if(NSClassFromString(@"BRBaseAppliance") != nil) {
    theMovie = [QTMovie movieWithQuickTimeMovie:(Movie)theMovie disposeWhenDone:NO error:nil];
  }
  
  return theMovie;
}

-(id)init {
  id result = [super init];
  
  // initalize language thing here
  
  return result;
}

-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 error:(id *)fp16 {
  LOG(@"In -initWithMedia:attributes:error:");
  
  return [self initWithMedia:asset attributes:fp12 allowAllMovieTypes:YES filter:nil error:fp16];
}

-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 allowAllMovieTypes:(BOOL)allowAll filter:(id)filter error:(id *)fp16 {
  if([SapphireFrontRowCompat usingFrontRow]) {
    if([super respondsToSelector:@selector(initWithMedia:allowAllTrackTypes:filter:error:)]) {
      [super initWithMedia:asset allowAllTrackTypes:allowAll filter:filter error:fp16];
    } else {
      [super initWithMedia:asset attributes:fp12 allowAllMovieTypes:allowAll error:fp16];
    }
  } else
    [super initWithMedia:asset attributes:fp12 error:fp16];
  // id result = self;
  
  QTMovie *theMovie = [self _getMovie];
  
  LOG(@"_video: (%@)%@", [theMovie class], theMovie);

  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ attributes:(%@)%@, allowAllMovieTypes:%d, filter:(%@)%@, error:(%@)%@", [asset class], asset, [fp12 class], fp12, allowAll, [filter class], filter, nil, nil);//[*fp16 class], *fp16);
  // LOG(@"In ATVFVideo -initWithMedia:attributes:error: -> (%@)%@", [result class], result);
  LOG(@"_video: (%@)%@", [theMovie class], theMovie);
  
  [theMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];

  // Is this a stack where we have to append to the video?
  if([asset isStack]) {
    int i;
    int count = [[asset stackContents] count];
    
    NSError *error = nil;
    for(i = 1; i < count; i++) {
      NSURL *segmentURL = [[asset stackContents] objectAtIndex:i];
      LOG(@" Adding %@ to playback", segmentURL);

      QTDataReference *segmentRef = [QTDataReference dataReferenceWithReferenceToURL:segmentURL];
      LOG(@"Ref: %@", segmentRef);
      QTMovie *segment = [QTMovie movieWithDataReference:segmentRef error:&error];
      if(error) {
        LOG(@"Error adding segment: %@", error);
        break;
      }
      
      // add it
      [theMovie insertSegmentOfMovie:segment timeRange:QTMakeTimeRange(QTZeroTime, [segment duration]) atTime:[theMovie duration]];
    }
  }
  LOG(@"_video: (%@)%@", [theMovie class], theMovie);
  
  // update the asset duration
  // if([asset duration] == 0) {
  NSTimeInterval duration;
  if(QTGetTimeInterval([theMovie duration], &duration)) {
    [asset setDuration:duration];
  } else {
    LOG(@"Unable to get duration!");
    return nil;
  }
  // }
  
  NSError *error = nil;
  LOG(@"Going to updateTrackInfo");
  [self _updateTrackInfoWithError:&error];
  LOG(@"Error updateTrackInfo: (%@)%@", [error class], error);
  
  // [self _update]
  return self;
}

// 1.0?  in any case, we won't run there.
-(id)initWithMedia:(id)fp8 error:(id *)fp12 {
  id result = [super initWithMedia:fp8 error:fp12];
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, nil, nil);//[*fp12 class], *fp12);
  LOG(@"In ATVFVideo -initWithMedia:error: -> (%@)%@", [result class], result);
  
  return result;
}

-(BOOL)hasSubtitles {
  return NO;
  
  QTMovie *theMovie = [self _getMovie];
  NSArray *tracks = [theMovie tracksOfMediaType:QTMediaTypeVideo];
  
  int i = 0;
  int num = [tracks count];
  BOOL isSubtitle = NO;
  for(i = 0; i < num; i++) {
    QTTrack *track = [tracks objectAtIndex:i];
    LOG(@"Track %d: %@ -> %@ (Media: %@)", i, track, [track trackAttributes], [[track media] mediaAttributes]);
    if([(NSNumber *)[track attributeForKey:QTTrackLayerAttribute] shortValue] == -1)
      isSubtitle = YES;
  }
  
  return isSubtitle;
}

-(void)enableSubtitles:(BOOL)enabled {
  return;
  
  QTMovie *theMovie = [self _getMovie];
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

-(void)_getLanguages {
  // fill in,
  // see http://www.mactech.com/articles/mactech/Vol.18/18.07/July02QTToolkit/index.html
  // SetMovieLanguage
}

// ATV2
-(void)setCaptionsEnabled:(BOOL)captionsEnabled {
  // ???
}

@end
