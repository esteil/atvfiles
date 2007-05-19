//
//  ATVBRMetadataExtensions.h
//  ATVFiles
//
//  Created by Eric Steil III on 4/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BRMetadataPreviewController (ATVBRMetadataExtensions)
-(BRMetadataLayer *)metadataLayer;
@end

@interface BRMetadataLayer (ATVBRMetadataExtensions)
-(NSArray *)metadataLabels;
-(NSArray *)metadataObjects;
@end

@interface BRMetadataLinesLayer (ATVBRMetadataExtensions)

@end

@interface BRMetadataLineLayer (ATVBRMetadataExtensions)
@end

