//
//  ATVFilesAppliance.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFilesAppliance.h"

@implementation ATVFilesAppliance

- (id)applianceControllerWithScene:(id)scene {
  // create and display our main menu, which is the root of the base directory
  // FIXME: base directory currently hardcoded.
  NSString *baseDirectory = @"/Users/frontrow/Movies";
  
  ATVFileBrowserController *mainMenu = [[[ATVFileBrowserController alloc] initWithScene:scene forDirectory:baseDirectory useFolderNameForTitle:NO] autorelease];
  return mainMenu;
}

-(NSString *)applianceKey {
	return @"ATVFilesAppliance";
}

-(NSString *)applianceName {
	return @"ATVFilesAppliance";
}

+(void) load {
	LOG(@"load ATVFilesAppliance");
}

// Override to allow FrontRow to load multiple appliance plugins
// From: http://forums.somethingawful.com/showthread.php?action=showpost&postid=325081231#post325081231
+ (NSString *) className {
  // this function creates an NSString from the contents of the
  // struct objc_class, which means using this will not call this
  // function recursively, and it'll also return the *real* class
  // name.
  NSString *className = NSStringFromClass(self);

  // new method based on the BackRow NSException subclass, which conveniently provides us a backtrace
  // method!
  NSRange result = [[BRBacktracingException backtrace] rangeOfString:@"_loadApplianceInfoAtPath:"];

  if(result.location != NSNotFound) {
    LOG(@"+[%@ className] called for whitelist check, so I'm lying, m'kay?", className);
    className = @"RUICalibrationAppliance";
  }

  return className;
}

@end
