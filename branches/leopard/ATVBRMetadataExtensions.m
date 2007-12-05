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

-(BRMetadataLinesLayer *)metadataLinesLayer {
  return _metadataLinesLayer;
}
@end

@implementation BRMetadataLinesLayer (ATVBRMetadataExtensions)
-(NSArray *)lineLayers {
  return _lineLayers;
}
@end

@implementation BRMetadataLineLayer (ATVBRMetadataExtensions)
@end

