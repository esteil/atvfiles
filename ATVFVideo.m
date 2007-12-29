//
//  ATVFVideo.m
//  ATVFiles
//
//  Created by Eric Steil III on 7/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideo.h"
#import <QTKit/QTKit.h>
#import "ATVFMediaAsset.h"
#include <objc/objc-class.h>
#import "SapphireFrontRowCompat.h"

#define NUM_LANGUAGES 151

@interface ATVFVideo (PrivateMethods)
-(void)_getLanguages;
-(QTMovie *)_getMovie;
@end

@implementation ATVFVideo

-(QTMovie *)_getMovie {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_movie");
  
  return *(QTMovie * *)(((char *)self)+ret->ivar_offset);
}

-(id)init {
  id result = [super init];
  
  // initalize language thing here
  
  return result;
}

-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 error:(id *)fp16 {
  LOG(@"In -initWithMedia:attributes:error:");
  
  return [self initWithMedia:asset attributes:fp12 allowAllMovieTypes:YES error:fp16];
}

-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 allowAllMovieTypes:(BOOL)allowAll error:(id *)fp16 {
  if([SapphireFrontRowCompat usingFrontRow])
    [super initWithMedia:asset attributes:fp12 allowAllMovieTypes:allowAll error:fp16];
  else
    [super initWithMedia:asset attributes:fp12 error:fp16];
  // id result = self;
  
  QTMovie *theMovie = [self _getMovie];
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ attributes:(%@)%@, allowAllMovieTypes:%d, error:(%@)%@", [asset class], asset, [fp12 class], fp12, allowAll, nil, nil);//[*fp16 class], *fp16);
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

-(id)initWithMedia:(id)fp8 error:(id *)fp12 {
  id result = [super initWithMedia:fp8 error:fp12];
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, nil, nil);//[*fp12 class], *fp12);
  LOG(@"In ATVFVideo -initWithMedia:error: -> (%@)%@", [result class], result);
  
  return result;
}

-(BOOL)hasSubtitles {
  QTMovie *theMovie = [self _getMovie];
  NSArray *tracks = [theMovie tracksOfMediaType:QTMediaTypeVideo];
  
  int i = 0;
  int num = [tracks count];
  for(i = 0; i < num; i++) {
    QTTrack *track = [tracks objectAtIndex:i];
    LOG(@"Track %d: %@ -> %@ (Media: %@)", i, track, [track trackAttributes], [[track media] mediaAttributes]);
  }
  
  return [tracks count] > 1;
}

-(void)enableSubtitles:(BOOL)enabled {
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

@end
