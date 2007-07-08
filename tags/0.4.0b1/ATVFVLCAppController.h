//
//  ATVFVLCAppController.h
//  ATVFiles
//
//  Created by Eric Steil III on 6/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ATVFullscreenAppController.h>
#import <ATVMediaAsset.h>

@interface ATVFVLCAppController : ATVFullscreenAppController {

}

-(ATVFVLCAppController *)initWithAsset:(ATVMediaAsset *)asset;

@end
