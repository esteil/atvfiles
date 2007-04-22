//
//  ATVBRMetadataExtensions.m
//  ATVFiles
//
//  Created by Eric Steil III on 4/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVBRMetadataExtensions.h"


@implementation BRMetadataPreviewController (ATVBRMetadataExtensions)
-(BRMetadataLayer *)metadataLayer {
  return _metadataLayer;
}
@end

@implementation BRMetadataLayer (ATVBRMetadataExtensions)
-(NSArray *)metadataLabels {
  return _metadataLabels;
}
-(NSArray *)metadataObjects {
  return _metadataObjs;
}
@end

@implementation BRMetadataLinesLayer (ATVBRMetadataExtensions)
@end

@implementation BRMetadataLineLayer (ATVBRMetadataExtensions)
@end

