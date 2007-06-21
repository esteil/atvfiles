//
//  ATVFullscreenAppController.m
//  ATVFiles
//
//  Created by Eric Steil III on 6/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFullscreenAppController.h"

@implementation ATVFullscreenAppController

-(ATVFullscreenAppController *)initWithCommand:(NSString *)command arguments:(NSArray *)arguments scene:(id)scene {
  [super initWithScene:scene];
  
  // initialize our NSTask for future use
  task = [[NSTask alloc] init];
  [task setLaunchPath:command];
  [task setArguments:arguments];
  
  return self;
}

-(void)dealloc {
  // if we're still running and deallocing, try to terminate it
  if([task isRunning]) {
    [task terminate];
  }
  
  [task release];
}

// handle the app running stuff
-(void)launchApp {
  int screenSaverTimeout;
  // tell backrow to quit rendering
  [[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerStopRenderingNotification" object:[BRDisplayManager sharedInstance]];
  
  // save the current screensaver tiemout and turn it off
  screenSaverTimeout = [[BRSettingsFacade settingsFacade] screenSaverTimeout];
  [[BRSettingsFacade settingsFacade] setScreenSaverTimeout:0];
  
  // grab display
  [[BRDisplayManager sharedInstance] releaseAllDisplays];
  
  // run app and wait for exit
  [myTask launch];
  [myTask waitUntilExit];
  
  // give backrow back the display, reset screen saver
  [[BRDisplayManager sharedInstance] captureAllDisplays];
  [[BRSettingsFacade settingsFacade] setScreenSaverTimeout:screenSaverTimeout];
  
  // tell backrow to resume rendering
  [[NSNotificationCenter defaultCenter] postNotificationName:@"BRDisplayManagerResumeRenderingNotification" object:[BRDisplayManager sharedInstance]];
  
  [scene renderScene];
}

@end

#ifdef 0
// SAMPLE CODE
- (id)applianceControllerWithScene:(id)scene {
    
  
    NSTask *myTask = [[NSTask alloc] init];
    [myTask setLaunchPath:@"/Applications/VLC.app/Contents/MacOS/VLC"];
 
    [[NSNotificationCenter defaultCenter] postNotificationName: @"BRDisplayManagerStopRenderingNotification" object: [BRDisplayManager sharedInstance]];
    [[BRSettingsFacade settingsFacade] setScreenSaverTimeout:0];
    [[BRDisplayManager sharedInstance] releaseAllDisplays];
    [myTask launch];
    [myTask waitUntilExit];
    [[BRDisplayManager sharedInstance] captureAllDisplays];
    [[BRSettingsFacade settingsFacade] setScreenSaverTimeout:20];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"BRDisplayManagerResumeRenderingNotification" object: [BRDisplayManager sharedInstance]];
    [scene renderScene];
    return self;
}
#endif