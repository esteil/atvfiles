//
//  ATVFullscreenAppController.h
//  ATVFiles
//
//  Created by Eric Steil III on 6/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BRLayerController.h>

@interface ATVFullscreenAppController : BRLayerController {
  NSTask *task;
}

-(ATVFullscreenAppController *)initWithCommand:(NSString *)command arguments:(NSArray *)arguments scene:(id)scene;
-(void)launchApp;

@end
