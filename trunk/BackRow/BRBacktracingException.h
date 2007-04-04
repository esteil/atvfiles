/*
 *     Generated by class-dump 3.1.1.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2006 by Steve Nygard.
 */

@interface BRBacktracingException : NSException
{
}

+ (id)backtrace;
+ (id)backtraceSkippingFrames:(int)fp8;
+ (void)install;
+ (void)logBacktraceSkippingFrames:(int)fp8 withMessage:(id)fp12;
+ (void)logBacktraceWithMessage:(id)fp8;
+ (void)setSignificantRaiseHandler:(void *)fp8;
- (id)backtrace;
- (id)initWithName:(id)fp8 reason:(id)fp12 userInfo:(id)fp16;
- (void)raise;
- (void)raiseWithoutReporting;

@end
