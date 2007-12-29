//
//  ATVFVideo.h
//  ATVFiles
//
//  Created by Eric Steil III on 7/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <ATVFMediaAsset.h>

@interface ATVFVideo : BRVideo {

}

-(BOOL)hasSubtitles;
-(void)enableSubtitles:(BOOL)enabled;
-(id)initWithMedia:(ATVFMediaAsset *)asset attributes:(id)fp12 allowAllMovieTypes:(BOOL)allowAll error:(id *)fp16;

@end
