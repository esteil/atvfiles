//
//  ATVFMetadataPreviewController.h
//  ATVFiles
//
//  Created by Eric Steil III on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>

@interface ATVFMetadataPreviewController : BRMetadataPreviewController {
  // BRRenderLayer *
}

-(ATVFMetadataPreviewController *)initWithScene:(BRRenderScene *)scene;

@end
