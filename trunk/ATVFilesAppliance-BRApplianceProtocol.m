//
// ATVFilesAppliance-BRApplianceProtocol.m
// ATVFiles appliance methods for ATV1 and 10.5.
//
// Created by Eric Steil III on 2/13/08.
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

/*
 * This implements the methods required for being recognized
 * as an appliance on ATV 1.1 and FrontRow.
 *
 * That is, the BRApplianceProtocol (both variations, with applianceController
 * and applianceControllerWithScene:)
 */
@implementation ATVFilesAppliance (BRApplianceProtocol)

// Leopard, just call the ATV version with a nil scene.
-(id)applianceController {
  return [self applianceControllerWithScene:nil];
}

// ATV
- (id)applianceControllerWithScene:(id)scene {
  // create and display our main menu, which is the root of the base directory
  // FIXME: base directory currently hardcoded.
  NSString *baseDirectory = [[ATVFPreferences preferences] stringForKey:kATVPrefRootDirectory];
  
  ATVFileBrowserController *mainMenu;
  NSString *placesMode = [[ATVFPreferences preferences] stringForKey:kATVPrefPlacesMode];
  
  if([placesMode isEqual:kATVPrefPlacesModeOff]) {
    mainMenu = [[[ATVFileBrowserController alloc] initWithScene:scene forDirectory:baseDirectory useNameForTitle:NO] autorelease];
  } else {
    mainMenu = [[[ATVFileBrowserController alloc] initWithScene:scene usePlacesTitle:NO] autorelease];
  }
  
  return mainMenu;
}

-(id)initWithSettings:(id)settings {
  
  LOG(@"In initWithSettings:(%@)%@", [settings class], settings);
  
  return [super init];
}

-(id)version {
  return @"1.0";
}

@end
