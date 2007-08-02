//
//  ATVFVideo.m
//  ATVFiles
//
//  Created by Eric Steil III on 7/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideo.h"
#import <QTKit/QTKit.h>
#import "ATVMediaAsset.h"

@implementation ATVFVideo

-(id)init {
  id result = [super init];
  
  return result;
}

-(id)initWithMedia:(ATVMediaAsset *)fp8 attributes:(id)fp12 error:(id *)fp16 {
  LOG(@"_video: (%@)%@", [_movie class], _movie);
  [super initWithMedia:fp8 attributes:fp12 error:fp16];
  // id result = self;
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ attributes:(%@)%@, error:(%@)%@", [fp8 class], fp8, [fp12 class], fp12, nil, nil);//[*fp16 class], *fp16);
  // LOG(@"In ATVFVideo -initWithMedia:attributes:error: -> (%@)%@", [result class], result);
  LOG(@"_video: (%@)%@", [_movie class], _movie);
  
  [_movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];

  // Is this a stack where we have to append to the video?
  if([[fp8 stackContents] count] > 1) {
    int i;
    int count = [[fp8 stackContents] count];
    
    NSError *error = nil;
    for(i = 1; i < count; i++) {
      NSURL *segmentURL = [[fp8 stackContents] objectAtIndex:i];
      LOG(@" Adding %@ to playback", segmentURL);
      
      QTMovie *segment = [QTMovie movieWithURL:segmentURL error:&error];
      if(error) {
        LOG(@"Error adding segment: %@", error);
        break;
      }
      
      // add it
      [_movie insertSegmentOfMovie:segment timeRange:QTMakeTimeRange(QTZeroTime, [segment duration]) atTime:[_movie duration]];
      // [segment release];
    }
  }
  LOG(@"_video: (%@)%@", [_movie class], _movie);
  
  [self _updateTrackInfoWithError:nil];
  
  return self;
}

-(id)initWithMedia:(id)fp8 error:(id *)fp12 {
  id result = [super initWithMedia:fp8 error:fp12];
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, nil, nil);//[*fp12 class], *fp12);
  LOG(@"In ATVFVideo -initWithMedia:error: -> (%@)%@", [result class], result);
  
  return result;
}

-(void)setPlaybackContext:(id)fp8 {
  LOG(@"In ATVFVideo -setPlaybackContext:(%@)%@", [fp8 class], fp8);
  [super setPlaybackContext:fp8];
}

-(double)duration {
  double duration = [super duration];
  LOG(@"In ATVFVideo -duration -> %f", duration);
  return duration;
}
@end
