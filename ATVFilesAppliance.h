//
// ATVFilesAppliance.h
// ATVFiles
//
// Created by Eric Steil III on 3/29/07.
// Copyright (C) 2007 Eric Steil III
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

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFileBrowserController.h"
#import "config.h"

// this just makes the warnings shut up
@interface ATVFilesAppliance : BRAppliance {

}

+(NSString *)moduleKey;

-(id)applianceController;

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
#define kATVPrefEnableSubtitlesByDefault @"EnableSubtitlesByDefault"
#define kATVPrefEnterAutomatically @"EnterAutomatically"
#define kATVPrefShowFileIcons @"ShowFileIcons"
#define kATVPrefPlaces @"Places"
#define kATVPrefPlacesMode @"PlacesMode"
#define kATVPrefMountBlacklist @"MountBlacklist"

// preference values
#define kATVPrefPlacesModeOff @"Off"
#define kATVPrefPlacesModeVolumes @"Volumes"
#define kATVPrefPlacesModeEnabled @"On"

// notifications
#define ATVFMountsDidChangeNotification @"ATVFMountsDidChangeNotification"
