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

@implementation ATVFVideo

-(id)init {
  id result = [super init];
  
  return result;
}

-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 error:(id *)fp16 {
  LOG(@"_video: (%@)%@", [_movie class], _movie);
  [super initWithMedia:asset attributes:fp12 error:fp16];
  // id result = self;
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ attributes:(%@)%@, error:(%@)%@", [asset class], asset, [fp12 class], fp12, nil, nil);//[*fp16 class], *fp16);
  // LOG(@"In ATVFVideo -initWithMedia:attributes:error: -> (%@)%@", [result class], result);
  LOG(@"_video: (%@)%@", [_movie class], _movie);
  
  [_movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];

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
      [_movie insertSegmentOfMovie:segment timeRange:QTMakeTimeRange(QTZeroTime, [segment duration]) atTime:[_movie duration]];
    }
  }
  LOG(@"_video: (%@)%@", [_movie class], _movie);
  
  // update the asset duration
  // if([asset duration] == 0) {
  NSTimeInterval duration;
  if(QTGetTimeInterval([_movie duration], &duration)) {
    [asset setDuration:duration];
  } else {
    LOG(@"Unable to get duration!");
  }
  // }
  [self _updateTrackInfoWithError:nil];
  
  return self;
}

-(id)initWithMedia:(id)fp8 error:(id *)fp12 {
  id result = [super initWithMedia:fp8 error:fp12];
  
  LOG(@"In ATVFVideo -initWithMedia:(%@)%@ error:(%@)%@", [fp8 class], fp8, nil, nil);//[*fp12 class], *fp12);
  LOG(@"In ATVFVideo -initWithMedia:error: -> (%@)%@", [result class], result);
  
  return result;
}

@end
