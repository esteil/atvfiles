//
//  ATVFMetadataPreviewController.m
//  ATVFiles
//
//  Created by Eric Steil III on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFMetadataPreviewController.h"
#import "ATVBRMetadataExtensions.h"

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
  
  LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[_metadataLayer metadataLabels] class], [_metadataLayer metadataLabels],
      [[_metadataLayer metadataObjects] class], [_metadataLayer metadataObjects]);
  
  // add test ones
  NSMutableArray *labels = [[_metadataLayer metadataLabels] mutableCopy];
  NSMutableArray *objects = [[_metadataLayer metadataObjects] mutableCopy];
  
  [labels addObject:@"Test 1"];
  [labels addObject:@"Test 2"];
  [objects addObject:@"123"];
  [objects addObject:@"456"];
  
  [labels addObject:@"Test 3"];
  [objects addObject:[self _stackIcon]];
  
  // set it
  [_metadataLayer setMetadata:objects withLabels:labels];
  
  LOG(@"Labels: (%@)%@, Objects: (%@)%@", [[_metadataLayer metadataLabels] class], [_metadataLayer metadataLabels], 
      [[_metadataLayer metadataObjects] class], [_metadataLayer metadataObjects]);
  
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
