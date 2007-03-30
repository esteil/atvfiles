/*
 *     Generated by class-dump 3.1.1.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2006 by Steve Nygard.
 */

#import <BRLayerController.h>

@class BRGoBackControl, BRHeaderControl, BRImageControl, BRTextControl;

@interface BRAlertController : BRLayerController
{
    id _eventDelegate;
    SEL _eventSelector;
    BRHeaderControl *_header;
    int _type;
    BRTextControl *_primary;
    BRTextControl *_secondary;
    BRImageControl *_image;
    BRGoBackControl *_goBack;
}

+ (id)alertForError:(id)fp8 withScene:(id)fp12;
+ (id)alertOfType:(int)fp8 titled:(id)fp12 primaryText:(id)fp16 secondaryText:(id)fp20 withScene:(id)fp24;
- (BOOL)brEventAction:(id)fp8;
- (void)dealloc;
- (id)initWithType:(int)fp8 titled:(id)fp12 primaryText:(id)fp16 secondaryText:(id)fp20 withScene:(id)fp24;
- (void)setEventDelegate:(id)fp8 selector:(SEL)fp12;
- (void)setHasGoBackControl:(BOOL)fp8;
- (void)setPrimaryText:(id)fp8;
- (void)setPrimaryText:(id)fp8 withAttributes:(id)fp12;
- (void)setSecondaryText:(id)fp8;
- (void)setSecondaryText:(id)fp8 withAttributes:(id)fp12;
- (void)setTitle:(id)fp8;
- (void)wasPushed;

@end

