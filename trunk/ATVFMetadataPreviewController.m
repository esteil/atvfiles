//
//  ATVFMetadataPreviewController.m
//  ATVFiles
//
//  Created by Eric Steil III on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFMetadataPreviewController.h"
#import "ATVBRMetadataExtensions.h"
#import "ATVFMediaAsset.h"
#import "ATVFPreferences.h"
#import "NSString+FileSizeFormatting.h"
#import "SapphireFrontRowCompat.h"
#include <objc/objc-class.h>

@interface ATVFMetadataPreviewController (Private)
-(id)_stackIcon;
-(void)_doMetadataUpdate;
@end

@interface BRMetadataPreviewController (FRCompat)
-(id)scene;
-(void)_updateMetadataLayer;
@end

@implementation ATVFMetadataPreviewController
-(ATVFMetadataPreviewController *)initWithScene:(BRRenderScene *)scene {
	if([[BRMetadataPreviewController class] instancesRespondToSelector:@selector(initWithScene:)])
		return [super initWithScene:scene];
	else
		return [super init];
}

// ATV
-(void)_populateMetadata {
  [super _populateMetadata];
  [self _doMetadataUpdate];
}

// 10.5
-(void)_updateMetadataLayer {
  [super _updateMetadataLayer];
  [self _doMetadataUpdate];
}

-(void)_doMetadataUpdate {
  BRMetadataLayer *metadataLayer = [self metadataLayer];
  id asset = [self asset];
  
  // debug
  // LOG(@"Rects: display: %@, frameForArtByItself: %@, frameForArtWhenWithMetadata: %@, maxMetadata: %@",
  //   NSStringFromRect([self _displayRect]), NSStringFromRect([self _frameForArtByItself]), NSStringFromRect([self _frameForArtWhenWithMetadata]), NSStringFromRect([self _maxMetadataFrame]));
  // 
  // 
  // LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[[self metadataLayer] metadataLabels] class], [[self metadataLayer] metadataLabels],
  //     [[[self metadataLayer] metadataObjects] class], [[self metadataLayer] metadataObjects]);
  
  // override Genre tag to not be sucky
  NSString *genreLabel = [BRLocalizedStringManager backRowLocalizedStringForKey:@"MetadataGenre" inFile:nil];
  NSString *genreString = [(ATVFMediaAsset *)asset primaryGenreString];
  
  NSMutableArray *labels = [[metadataLayer metadataLabels] mutableCopy];
  NSMutableArray *objects = [[metadataLayer metadataObjects] mutableCopy];
  
  int genreIndex = [labels indexOfObject:genreLabel];
  // LOG(@"Label %@ found at %d", genreLabel, genreIndex);
  if(genreIndex != NSNotFound) {
    // LOG(@"Replacing genre label %@ with %@->%@ at index %d", genreLabel, [objects objectAtIndex:genreIndex], genreString, genreIndex);
    if(genreString && ![genreString isEqualToString:@"unknown"]) {
      [objects replaceObjectAtIndex:genreIndex withObject:genreString];
    } else {
      [objects replaceObjectAtIndex:genreIndex withObject:@""];
    }
  }
  
  // LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[[self metadataLayer] metadataLabels] class], [[self metadataLayer] metadataLabels],
  //     [[[self metadataLayer] metadataObjects] class], [[self metadataLayer] metadataObjects]);
  
  BOOL showSize = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileSize];
  if(showSize) {
    [labels addObject:BRLocalizedString(@"Size", "File size metadata label")];
    [objects addObject:[NSString formattedFileSizeWithBytes:[(ATVFMediaAsset *)asset filesize]]];
  }
  
  // set it
  [metadataLayer setMetadata:objects withLabels:labels];
  
  // LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[[self metadataLayer] metadataLabels] class], [[self metadataLayer] metadataLabels], 
  //     [[[self metadataLayer] metadataObjects] class], [[self metadataLayer] metadataObjects]);
  // 
  // LOG(@"Rects: display: %@, frameForArtByItself: %@, frameForArtWhenWithMetadata: %@, maxMetadata: %@",
  //   NSStringFromRect([self _displayRect]), NSStringFromRect([self _frameForArtByItself]), NSStringFromRect([self _frameForArtWhenWithMetadata]), NSStringFromRect([self _maxMetadataFrame]));
  // LOG(@"Metadata frame: %@", NSStringFromRect([[self metadataLayer] frame]));
  
}

-(id)_stackIcon {
  return [SapphireFrontRowCompat imageAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"stack-icon" ofType:@"png"] 
                                       scene:[self scene]];
}

// instance variable access for metadata layer
-(BRMetadataLayer *)metadataLayer {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_metadataLayer");
  
  return *(BRMetadataLayer * *)(((char *)self)+ret->ivar_offset);
}
@end
