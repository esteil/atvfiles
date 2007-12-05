//
//  ATVFVLCAppController.h
//  ATVFiles
//
//  Created by Eric Steil III on 6/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#ifdef ENABLE_EXTERNAL_PLAYERS
#import <Cocoa/Cocoa.h>
#import <ATVFullscreenAppController.h>
#import <ATVFMediaAsset.h>

@interface ATVFVLCAppController : ATVFullscreenAppController {

}

-(ATVFVLCAppController *)initWithAsset:(ATVFMediaAsset *)asset;

@end
#endif
