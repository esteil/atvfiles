//
//  MEMusicPlayerSwizzle.m
//  ATVFiles
//
//  Created by Eric Steil III on 6/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MEMusicPlayerSwizzle.h"
#import "LoggingUtils.h"
#import </usr/include/objc/objc-class.h>

void PerformSwizzle(Class aClass, SEL orig_sel, SEL alt_sel, BOOL forInstance) {
  // First, make sure the class isn't nil
  if (aClass != nil) {
    Method orig_method = nil, alt_method = nil;

    // Next, look for the methods
    if (forInstance) {
      orig_method = class_getInstanceMethod(aClass, orig_sel);
      alt_method = class_getInstanceMethod(aClass, alt_sel);
    } else {
      orig_method = class_getClassMethod(aClass, orig_sel);
      alt_method = class_getClassMethod(aClass, alt_sel);
    }

    // If both are found, swizzle them
    if ((orig_method != nil) && (alt_method != nil)) {
      IMP temp;

      temp = orig_method->method_imp;
      orig_method->method_imp = alt_method->method_imp;
      alt_method->method_imp = temp;
    } else {
      NSLog(@"PerformSwizzle Error: Original %@, Alternate %@",(orig_method == nil)?@" not found":@" found",(alt_method == nil)?@" not found":@" found");
    }
  } else {
    NSLog(@"PerformSwizzle Error: Class not found");
  }
}

void MethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel) {
  PerformSwizzle(aClass, orig_sel, alt_sel, YES);
}

void ClassMethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel) {
  PerformSwizzle(aClass, orig_sel, alt_sel, NO);
}

@interface ATVFSwizzleThing : NSObject
@end

@implementation ATVFSwizzleThing 
+(void)load {
  Class memp = NSClassFromString(@"MEMusicPlayer");
  if(memp) {
    LOG(@"Swizzling in MEMusicPlayer");
    MethodSwizzle(memp, @selector(playerState), @selector(loggingPlayerState));
    MethodSwizzle(memp, @selector(initiatePlayback:), @selector(loggingInitiatePlayback:));
    MethodSwizzle(memp, @selector(currentChapterTitle), @selector(loggingCurrentChapterTitle));
    MethodSwizzle(memp, @selector(elapsedPlaybackTime), @selector(loggingElapsedPlaybackTime));
    MethodSwizzle(memp, @selector(bufferingProgress), @selector(loggingBufferingProgress));
    MethodSwizzle(memp, @selector(setElapsedPlaybackTime:), @selector(loggingSetElapsedPlaybackTime:));
    MethodSwizzle(memp, @selector(trackDuration), @selector(loggingTrackDuration));
// play pause stop pressAndHoldLeftArrow pressAndHoldRightArrow resume leftArrowClick rightArrowClick
    MethodSwizzle(memp, @selector(play), @selector(logging_play));
    MethodSwizzle(memp, @selector(pause), @selector(logging_pause));
    MethodSwizzle(memp, @selector(stop), @selector(logging_stop));
    MethodSwizzle(memp, @selector(pressAndHoldLeftArrow), @selector(logging_pressAndHoldLeftArrow));
    MethodSwizzle(memp, @selector(pressAndHoldRightArrow), @selector(logging_pressAndHoldRightArrow));
    MethodSwizzle(memp, @selector(resume), @selector(logging_resume));
    MethodSwizzle(memp, @selector(leftArrowClick), @selector(logging_leftArrowClick));
    MethodSwizzle(memp, @selector(rightArrowClick), @selector(logging_rightArrowClick));
  }
}
@end

@implementation NSObject (ATVFMEMusicPlayerSwizzledMethods)

-(int)loggingPlayerState {
	int result = [self loggingPlayerState];
	LOG(@"In MEMusicPlayer playerState -> %d", result);
	return result;
}

-(BOOL)loggingInitiatePlayback:(id *)fp8 {
  LOG(@"MEMusicPlayer initiatePlayback:(%@)%@", [*fp8 class], *fp8);
  BOOL result = [self loggingInitiatePlayback:fp8];
  LOG(@"MEMusicPlayer initiatePlayback:(%@)%@ -> %d", [*fp8 class], *fp8, result);
  return result;
}

-(id)loggingCurrentChapterTitle {
  id result = [self loggingCurrentChapterTitle];
  LOG(@"MEMusicPlayer currentChapterTitle -> (%@)%@", [result class], result);
  return result;
}

-(float)loggingElapsedPlaybackTime {
  float result = [self loggingElapsedPlaybackTime];
  LOG(@"MEMusicPlayer elapsedPlaybackTime -> %f", result);
  return result;
}

-(float)loggingBufferingProgress {
  float result = [self loggingBufferingProgress];
  LOG(@"MEMusicPlayer bufferingProgress -> %f", result);
  return result;
}

-(void)loggingSetElapsedPlaybackTime:(float)fp8 {
  LOG(@"MEMusicPlayer setElapsedPlaybackTime:%f", fp8);
  [self loggingSetElapsedPlaybackTime:fp8];
}

-(double)loggingTrackDuration {
  double result = [self loggingTrackDuration];
  LOG(@"MEMusicPlayer trackDuration -> %f", result);
  return result;
}

// play pause stop pressAndHoldLeftArrow pressAndHoldRightArrow resume leftArrowClick rightArrowClick
#define LOGGING_METHOD(sel) -(void)logging_ ## sel { LOG(@"MEMusicPlayer %@", NSStringFromSelector(@selector(sel))); [self logging_ ## sel]; }
LOGGING_METHOD(play);
LOGGING_METHOD(pause);
LOGGING_METHOD(stop);
LOGGING_METHOD(pressAndHoldLeftArrow);
LOGGING_METHOD(pressAndHoldRightArrow);
LOGGING_METHOD(resume);
LOGGING_METHOD(leftArrowClick);
LOGGING_METHOD(rightArrowClick);


@end
