//  ATVBRMetadataExtensions.h
//
//  ATVFiles
//
//  Created by Eric Steil III on 4/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>

@interface BRMetadataPreviewController (ATVBRMetadataExtensions)
-(BRMetadataLayer *)metadataLayer;
@end

@interface BRMetadataLayer (ATVBRMetadataExtensions)
-(NSArray *)metadataLabels;
-(NSArray *)metadataObjects;
-(BRMetadataLinesLayer *)metadataLinesLayer;
@end

@interface BRMetadataLinesLayer (ATVBRMetadataExtensions)
-(NSArray *)lineLayers;
@end

@interface BRMetadataLineLayer (ATVBRMetadataExtensions)
@end

