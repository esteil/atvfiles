//
// ATVFilesAppliance.m
// ATVFiles
//
// Created by Eric Steil III on 3/29/07.
// Copyright (C) 2007-2008 Eric Steil III
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ATVFilesAppliance.h"
#import "ATVFCoreAudioHelper.h"
#import "ATVFDatabase.h"
#import "ATVFPreferences.h"
#import <objc/objc-class.h>
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>

@implementation BRMainMenuController (ATVFilesAutorun)
-(void)wasPushed {
  LOG(@"In ATVFilesAutoRun wasPushed");
  
  [super wasPushed];
  
  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnterAutomatically]) {
    LOG(@"Automatically entering ATVFiles...");
    
    if([SapphireFrontRowCompat usingFrontRow]) {
      [[self stack] pushController:[[[ATVFilesAppliance alloc] init] applianceController]];
    } else {
      [[self stack] pushController:[[[ATVFilesAppliance alloc] init] applianceControllerWithScene:[self scene]]];
    }
  }
}
@end

@implementation ATVFilesAppliance

-(NSString *)applianceKey {
	return @"ATVFilesAppliance";
}

-(NSString *)applianceName {
	return @"ATVFilesAppliance";
}

-(NSString *)moduleIconName {
  return @"ApplianceIcon.png";
}

-(NSString *)moduleKey {
  return [ATVFilesAppliance moduleKey];
}

+(NSString *)moduleKey {
  return @"net.ericiii.ATVFiles";
}

-(NSString *)moduleName {
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
  NSMutableDictionary *defaultDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
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
    [NSNumber numberWithBool:NO], kATVPrefEnterAutomatically,
    [NSNumber numberWithBool:YES], kATVPrefShowFileIcons,
    kATVPrefPlacesModeEnabled, kATVPrefPlacesMode,
    [NSArray arrayWithObjects:@"/"], kATVPrefMountBlacklist,
    [NSNumber numberWithBool:YES], kATVPrefEnableFolderParades,
    nil, nil
  ];
  [defaults registerDefaults:defaultDictionary];
  
  // register the default places list, which is just ~/Movies
  [defaultDictionary setValue:[NSArray arrayWithObject:[defaults stringForKey:kATVPrefRootDirectory]] forKey:kATVPrefPlaces];
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
  
  // BRImageManager tests
  // NSURL *url1 = [NSURL URLWithString:@"http://ericiii.net/sa/appletv/icon/TV.png"];
  // NSURL *url2 = [NSURL URLWithString:@"file://localhost/Users/frontrow/tmp/ApplianceIcon.png"];
  // 
  // LOG(@"URLS: %@, %@", url1, url2);
  // BRImageManager *mgr = [BRImageManager sharedInstance];
  // 
  // LOG(@"Images: %@ %@", [mgr imageNameFromURL:url1], [mgr imageNameFromURL:url2]);
}

// Fix for main menu scrolling, from AQ
+(void)initialize {
  LOG(@"In ATVFilesAppliance initailize");
  SapphireLoadFramework([[[NSBundle bundleForClass:self] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks"]);

#if 0
  Method main, norm;
  main = class_getInstanceMethod([BRMainMenuController class], @selector(listFrameForBounds:));
  
  if(main != NULL) {
    norm = class_getInstanceMethod([BRMenuController class], @selector(listFrameForBounds:));
    if(norm != NULL && main->method_imp != norm->method_imp) {
      main->method_imp = norm->method_imp;
    }
  }
#endif
  
  // and here, tell os x to check for new removable media to mount anything not mounted at boot
  [[NSWorkspace sharedWorkspace] mountNewRemovableMedia];
  
  // tell the feature manager to enable us
  Class klass = NSClassFromString(@"BRFeatureManager");
  if(klass) {
    [[klass sharedInstance] enableFeatureNamed:[[NSBundle bundleForClass:self] bundleIdentifier]];
  }
}

// Override to allow FrontRow to load multiple appliance plugins
// From: http://forums.somethingawful.com/showthread.php?action=showpost&postid=325081231#post325081231
+ (NSString *) className {
  LOG(@"In ATVFilesAppliance className");
  
  // this function creates an NSString from the contents of the
  // struct objc_class, which means using this will not call this
  // function recursively, and it'll also return the *real* class
  // name.
  NSString *className = NSStringFromClass(self);

  // new method based on the BackRow NSException subclass, which conveniently provides us a backtrace
  // method!
  NSString *backtrace = [BRBacktracingException backtrace];
  LOG(@"Backtrace: %@", backtrace);
  
  // APPLE TV
  NSRange result = [backtrace rangeOfString:@"_loadApplianceInfoAtPath:"];
  
  if(result.location != NSNotFound) {
    LOG(@"+[%@ className] called for ATV whitelist check, so I'm lying, m'kay?", className);
    className = @"RUIMoviesAppliance";
  } else {
    // 10.5/ATV2
    NSRange result2 = [backtrace rangeOfString:@"(in BackRow)"];
    
    if(result2.location != NSNotFound) {
      // ATV2
      NSRange result3 = [backtrace rangeOfString:@"(in Finder)"];
      
      if(result3.location != NSNotFound) {
        LOG(@"+[%@ className] called for ATV2 whitelist check, so I'm lying, m'kay?", className);
        className = @"MOVAppliance";
      } else {
        LOG(@"+[%@ className] called for Leopard whitelist check, so I'm lying, m'kay?", className);
        className = @"RUIMoviesAppliance";
      }
    }
  }

  return className;
}

@end
