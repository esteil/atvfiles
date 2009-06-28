//
// ATVFPreferences.h
// ATVFiles
//
// Mainly this is convenience functions for setting preferences with the CFPreferences API
//
// Created by Eric Steil III on 9/4/07.
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

#import <Cocoa/Cocoa.h>
#import "ATVFilesAppliance.h"

@interface ATVFPreferences : NSUserDefaults {
	NSString * _applicationID;
	NSDictionary * _registrationDictionary;
}

-(id)initWithPersistentDomainName:(NSString *)domainName;
+(ATVFPreferences *)preferences;
@end

@interface NSUserDefaultsController (SetDefaults)
- (void) _setDefaults:(NSUserDefaults *)defaults;
@end
