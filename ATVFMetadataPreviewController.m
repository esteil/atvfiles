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

@interface ATVFMetadataPreviewController (Private)
-(BRBitmapTexture *)_stackIcon;
@end

@implementation ATVFMetadataPreviewController

-(ATVFMetadataPreviewController *)initWithScene:(BRRenderScene *)scene {
  [super initWithScene:scene];
  return self;
}

-(void)_populateMetadata {
  LOG(@"In -ATVFMetadataPreviewController _populateMetadata");
  
  LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[_metadataLayer metadataLabels] class], [_metadataLayer metadataLabels], 
      [[_metadataLayer metadataObjects] class], [_metadataLayer metadataObjects]);
      
  [super _populateMetadata];

  // debug
  LOG(@"Rects: display: %@, frameForArtByItself: %@, frameForArtWhenWithMetadata: %@, maxMetadata: %@",
    NSStringFromRect([self _displayRect]), NSStringFromRect([self _frameForArtByItself]), NSStringFromRect([self _frameForArtWhenWithMetadata]), NSStringFromRect([self _maxMetadataFrame]));

  
  LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[_metadataLayer metadataLabels] class], [_metadataLayer metadataLabels],
      [[_metadataLayer metadataObjects] class], [_metadataLayer metadataObjects]);

  // override Genre tag to not be sucky
  NSString *genreString = [(ATVFMediaAsset *)_asset primaryGenreString];

  NSMutableArray *labels = [[_metadataLayer metadataLabels] mutableCopy];
  NSMutableArray *objects = [[_metadataLayer metadataObjects] mutableCopy];

  int genreIndex = [labels indexOfObject:@"Genre"];
  if(genreIndex != NSNotFound) {
    LOG(@"Replacing genre label");
    [objects replaceObjectAtIndex:genreIndex withObject:genreString];
  }
  
  LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[_metadataLayer metadataLabels] class], [_metadataLayer metadataLabels],
      [[_metadataLayer metadataObjects] class], [_metadataLayer metadataObjects]);

  BOOL showSize = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileSize];
  if(showSize) {
    [labels addObject:@"Size"];
    [objects addObject:[NSString formattedFileSizeWithBytes:[(ATVFMediaAsset *)_asset filesize]]];
  }
  
  // set it
  [_metadataLayer setMetadata:objects withLabels:labels];

  LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[_metadataLayer metadataLabels] class], [_metadataLayer metadataLabels], 
      [[_metadataLayer metadataObjects] class], [_metadataLayer metadataObjects]);

  LOG(@"Rects: display: %@, frameForArtByItself: %@, frameForArtWhenWithMetadata: %@, maxMetadata: %@",
    NSStringFromRect([self _displayRect]), NSStringFromRect([self _frameForArtByItself]), NSStringFromRect([self _frameForArtWhenWithMetadata]), NSStringFromRect([self _maxMetadataFrame]));
  LOG(@"Metadata frame: %@", NSStringFromRect([_metadataLayer frame]));
  
}

-(BRBitmapTexture *)_stackIcon {
  NSURL *stackIconURL = [NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"stack-icon" ofType:@"png"]];

  CGImageRef playlistImg = CreateImageForURL((CFURLRef)stackIconURL);

  struct BRBitmapDataInfo info;
  info.internalFormat = GL_RGBA;
  info.dataFormat = GL_BGRA;
  info.dataType = GL_UNSIGNED_INT_8_8_8_8_REV;
  info.width = 512;
  info.height = 512;

  BRRenderContext *context = [_scene resourceContext];

  NSData *data = CreateBitmapDataFromImage( playlistImg, info.width, info.height );
  BRBitmapTexture *image = [[BRBitmapTexture alloc] initWithBitmapData: data
                                                           bitmapInfo: &info context: context mipmap: YES];

  [data release];
  return [image autorelease];  
}
   
@end
