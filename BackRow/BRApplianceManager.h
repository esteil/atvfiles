/*
 *     Generated by class-dump 3.1.1.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2006 by Steve Nygard.
 */


@interface BRApplianceManager : NSObject
{
    NSMutableArray *_applianceList;
}

+ (id)sharedManager;
- (BOOL)applianceInfo:(id)fp8 appliesToMediaHost:(id)fp12;
- (id)applianceInfoList;
- (void)dealloc;
- (id)instantiateApplianceForInfo:(id)fp8;
- (void)loadAppliances;

@end

