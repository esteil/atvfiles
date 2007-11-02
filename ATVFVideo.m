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

#define NUM_LANGUAGES 151

@interface ATVFVideo (PrivateMethods)
-(void)_getLanguages;
@end

@implementation ATVFVideo

-(id)init {
  id result = [super init];
  
  // initalize language thing here
  
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
  NSArray *tracks = [_movie tracksOfMediaType:QTMediaTypeVideo];
  
  int i = 0;
  int num = [tracks count];
  for(i = 0; i < num; i++) {
    QTTrack *track = [tracks objectAtIndex:i];
    // LOG(@"Track %d: %@ -> %@ (Media: %@)", i, track, [track trackAttributes], [[track media] mediaAttributes]);
  }
  
  return [tracks count] > 1;
}

-(void)enableSubtitles:(BOOL)enabled {
  NSArray *tracks = [_movie tracksOfMediaType:QTMediaTypeVideo];
  
  if([tracks count] > 1) {
    [[tracks objectAtIndex:1] setEnabled:enabled];
  }
}

-(void)_getLanguages {
  // fill in,
  // see http://www.mactech.com/articles/mactech/Vol.18/18.07/July02QTToolkit/index.html
  // SetMovieLanguage
}

@end
