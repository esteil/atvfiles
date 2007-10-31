//
//  ATVFilesAppliance.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFilesAppliance.h"
#import "ATVFCoreAudioHelper.h"
#import "ATVFDatabase.h"
#import "ATVFPreferences.h"
#import <objc/objc-class.h>

@implementation ATVFilesAppliance

- (id)applianceControllerWithScene:(id)scene {
  // create and display our main menu, which is the root of the base directory
  // FIXME: base directory currently hardcoded.
  NSString *baseDirectory = [[ATVFPreferences preferences] stringForKey:kATVPrefRootDirectory];
  
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
  LOG(@"Running with SQLite3 %@", [FMDatabase sqliteLibVersion]);
	
  LOG(@"ATVFDatabase User Version: %d", [[ATVFDatabase sharedInstance] schemaVersion]);
  
  // set up our defaults
  // stacking regexps (from XBMC)
  NSDictionary *stackREs = [NSArray arrayWithObjects:
    @"[ _\\.-]+cd[ _\\.-]*([0-9a-d]+)",
    @"[ _\\.-]+dvd[ _\\.-]*([0-9a-d]+)",
    @"[ _\\.-]+part[ _\\.-]*([0-9a-d]+)",
    // @"()[ _\\.-]+([0-9]*[a-d]+)(\\....)$",
    // @"()[\\^ _\\.-]+([0-9]+)(\\....)$",
    // @"([a-z])([0-9]+)(\\....)$",
    @"()([a-d])(\\....)$",
    nil
  ];
  
  ATVFPreferences *defaults = [ATVFPreferences preferences];
  NSDictionary *defaultDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSHomeDirectory() stringByAppendingPathComponent:@"Movies"], kATVPrefRootDirectory,
    [NSNumber numberWithBool:NO], kATVPrefEnableAC3Passthrough,
    [NSArray arrayWithObjects:
      @"m4v", @"3gp", @"divx", @"xvid", @"avi", @"mov", @"wmv", @"asx", @"asf", @"ogm",
      @"mpg", @"mpeg", @"mp4", @"mkv", @"avc", @"flv", @"dv", @"fli", @"m2v", @"ts", nil
    ], kATVPrefVideoExtensions,
    [NSArray arrayWithObjects:
      @"m4b", @"m4a", @"mp3", @"wma", @"wav", @"aif", @"aiff", @"flac", @"alac", @"mp2", nil
    ], kATVPrefAudioExtensions,
    [NSArray arrayWithObjects:@"m3u", /*@"pls",*/ nil], kATVPrefPlaylistExtensions,
    [NSNumber numberWithBool:YES], kATVPrefEnableFileDurations,
    [NSNumber numberWithBool:YES], kATVPrefShowFileExtensions,
    [NSNumber numberWithBool:YES], kATVPrefShowFileSize,
    [NSNumber numberWithBool:YES], kATVPrefShowUnplayedDot,
    [NSNumber numberWithInt:0], kATVPrefResumeOffset,
    stackREs, kATVPrefStackRegexps,
    [NSNumber numberWithBool:YES], kATVPrefEnableStacking,
    [NSNumber numberWithBool:NO], kATVPrefEnableSubtitlesByDefault,
    nil, nil
  ];
  LOG(@"Setting default preferences:\n%@", defaultDictionary);
  
  [defaults registerDefaults:defaultDictionary];
  
  // we read prefs from here
  // [defaults addSuiteNamed:@"net.ericiii.ATVFiles"];
  
  // set 48000 sample rate if ac3 allowed?
  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) {
    [ATVFCoreAudioHelper setSystemSampleRate:48000];
    [ATVFCoreAudioHelper setPassthroughPreference:@"1"];
  } else {
    [ATVFCoreAudioHelper setPassthroughPreference:@"0"];
  }
}

// Fix for main menu scrolling, from AQ
+(void)initialize {
  Method main, norm;
  main = class_getInstanceMethod([BRMainMenuController class], @selector(listFrameForBounds:));
  
  if(main != NULL) {
    norm = class_getInstanceMethod([BRMenuController class], @selector(listFrameForBounds:));
    if(norm != NULL && main->method_imp != norm->method_imp) {
      main->method_imp = norm->method_imp;
    }
  }
}

// Override to allow FrontRow to load multiple appliance plugins
// From: http://forums.somethingawful.com/showthread.php?action=showpost&postid=325081231#post325081231
+ (NSString *) className {
  // LOG(@"In ATVFilesAppliance +className");
  // this function creates an NSString from the contents of the
  // struct objc_class, which means using this will not call this
  // function recursively, and it'll also return the *real* class
  // name.
  NSString *className = NSStringFromClass(self);

  // new method based on the BackRow NSException subclass, which conveniently provides us a backtrace
  // method!
  NSRange result = [[BRBacktracingException backtrace] rangeOfString:@"_loadApplianceInfoAtPath:"];

  // LOG(@"Backtrace: %@", [BRBacktracingException backtrace]);
  
  if(result.location != NSNotFound) {
    LOG(@"+[%@ className] called for whitelist check, so I'm lying, m'kay?", className);
    className = @"RUIMoviesAppliance";
  }

  return className;
}

@end
