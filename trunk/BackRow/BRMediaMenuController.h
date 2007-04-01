/*
 *     Generated by class-dump 3.1.1.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2006 by Steve Nygard.
 */

#import <BRMenuController.h>
#import <BRAnimation.h>
#import <BRRenderLayer.h>

@interface BRMediaMenuController : BRMenuController
{
    long _previewState;
    BRAnimation *_previewFader;
    id _previewController;
    BRRenderLayer *_previewLayer;
    id _outgoingController;
    BRRenderLayer *_outgoingLayer;
    float _previewDelay;
    NSTimer *_previewDelayTimer;
    NSMutableArray *_musicStoreCollections;
    NSTimer *_musicStoreTimer;
    unsigned int _musicStoreSelected:1;
    unsigned int _musicStorePreviewRequested:1;
}

- (void)dealloc;
- (id)initWithScene:(id)fp8;
- (id)mediaPreviewMissingMediaType;
- (BOOL)mediaPreviewShouldShowMetadata;
- (BOOL)mediaPreviewShouldShowMetadataImmediately;
- (id)previewControllerForItem:(long)fp8;
- (struct _NSRect)previewFrameForBounds:(struct _NSSize)fp8;
- (void)refreshControllerForModelUpdate;
- (void)updatePreviewController;
- (void)wasBuriedByPushingController:(id)fp8;
- (void)wasExhumedByPoppingController:(id)fp8;
- (void)wasPopped;
- (void)wasPushed;
- (void)willBeBuried;
- (void)willBeExhumed;
- (void)willBePopped;

@end
