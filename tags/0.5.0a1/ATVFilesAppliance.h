//
//  ATVFilesAppliance.h
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFileBrowserController.h"
#import "config.h"

// this just makes the warnings shut up
@interface ATVFilesAppliance : BRAppliance {

}

@end

// keys for preferences
#define kATVPrefRootDirectory @"RootDirectory"
#define kATVPrefVideoExtensions @"VideoExtensions"
#define kATVPrefAudioExtensions @"AudioExtensions"
#define kATVPrefPlaylistExtensions @"PlaylistExtensions"
#define kATVPrefEnableAC3Passthrough @"EnableAC3Passthrough"
#define kATVPrefEnableFileDurations @"EnableFileDurations"
#define kATVPrefShowFileExtensions @"ShowFileExtensions"
#define kATVPrefShowFileSize @"ShowFileSize"
#define kATVPrefShowUnplayedDot @"ShowUnplayedDot"
#define kATVPrefResumeOffset @"ResumeOffset"
#define kATVPrefStackRegexps @"StackRegexps"
#define kATVPrefEnableStacking @"EnableStacking"
