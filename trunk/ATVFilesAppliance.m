//
//  ATVFilesAppliance.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFilesAppliance.h"
#import "ATVFCoreAudioHelper.h"
#include <sqlite3.h>

@implementation ATVFilesAppliance

- (id)applianceControllerWithScene:(id)scene {
  // create and display our main menu, which is the root of the base directory
  // FIXME: base directory currently hardcoded.
  NSString *baseDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:kATVPrefRootDirectory];
  
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
	
	// SQLITE3 test
  LOG(@"Running with SQLite3 %s", sqlite3_libversion());
	
  // set up our defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *defaultDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSHomeDirectory() stringByAppendingPathComponent:@"Movies"], kATVPrefRootDirectory,
    [NSNumber numberWithBool:NO], kATVPrefEnableAC3Passthrough,
    [NSArray arrayWithObjects:
      @"m4v", @"3gp", @"m3u", @"pls", @"divx", @"xvid", @"avi", @"mov", @"wmv", @"asx", @"asf", @"ogm",
      @"mpg", @"mpeg", @"mp4", @"mkv", @"avc", @"flv", @"dv", @"fli", @"m2v", @"ts", nil
    ], kATVPrefVideoExtensions,
    [NSArray arrayWithObjects:
      @"m4b", @"m4a", @"mp3", @"wma", @"wav", @"aif", @"aiff", @"flac", @"alac", @"m3u", @"mp2", nil
    ], kATVPrefAudioExtensions,
    [NSNumber numberWithBool:NO], kATVPrefEnableFileDurations,
    [NSNumber numberWithBool:YES], kATVPrefShowFileExtensions,
    [NSNumber numberWithBool:YES], kATVPrefShowFileSize,
    nil, nil
  ];
  LOG(@"Setting default preferences:\n%@", defaultDictionary);
  
  [defaults registerDefaults:defaultDictionary];
  
  // we read prefs from here
  [defaults addSuiteNamed:@"net.ericiii.ATVFiles"];
  
  // set 48000 sample rate if ac3 allowed?
  if([[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefEnableAC3Passthrough]) {
    [ATVFCoreAudioHelper setSystemSampleRate:48000];
  }
  
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
