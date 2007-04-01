/*
 *     Generated by class-dump 3.1.1.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2006 by Steve Nygard.
 */

#import <BRAnimation.h>
#import <BRImageLayer.h>
#import <BRMetadataLayer.h>
#import <BRRenderLayer.h>
#import <BRRenderScene.h>

@interface BRMetadataPreviewController : NSObject
{
    id _asset;
    BRRenderScene *_scene;
    BRRenderLayer *_mainLayer;
    BRImageLayer *_coverArtLayer;
    BRMetadataLayer *_metadataLayer;
    BRAnimation *_animation;
    struct _NSRect _frame;
    int _state;
    NSTimer *_timer;
    unsigned int _blockDuringAnimation:1;
    unsigned int _artworkNeedsUpdating:1;
}

- (void)activate;
- (void)deactivate;
- (void)dealloc;
- (BOOL)fadeLayerIn;
- (id)initWithScene:(id)fp8;
- (id)layer;
- (void)setAsset:(id)fp8;
- (void)setBlocksDuringAnimation:(BOOL)fp8;
- (void)setShowsMetadataImmediately:(BOOL)fp8;
- (BOOL)showsMetadataImmediately;
- (void)willDeactivate;
- (void)willLoseFocus;
- (void)willRegainFocus;

@end
