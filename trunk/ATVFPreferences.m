//
// ATVFPreferences.m
// ATVFiles
//
// Based on BundleUserDefaults http://cocoacafe.wordpress.com/2007/06/18/bundleuserdefaults/
//
// Created by Eric Steil III on 9/4/07.
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

#import "ATVFPreferences.h"

@implementation ATVFPreferences

+(ATVFPreferences *)preferences {
  static ATVFPreferences *_preferences = nil;
  
  if(!_preferences)
    _preferences = [[self alloc] initWithPersistentDomainName:@"net.ericiii.ATVFiles"];
    
  return _preferences;
}

-(id)initWithPersistentDomainName:(NSString *)domainName {
	if(self = [super init])	{
		_applicationID = [domainName copy];
		_registrationDictionary = nil;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
	}
	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[_applicationID release];
	[_registrationDictionary release];
	[super dealloc];
}

-(void)_applicationWillTerminate:(NSNotification *)notification {
	[self synchronize];
}

-(id)objectForKey:(NSString *)defaultName {
	id value = [(id)CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)_applicationID) autorelease];
	if(value == nil)
		value = [_registrationDictionary objectForKey:defaultName];
	return value;
}

-(void)setObject:(id)value forKey:(NSString *)defaultName {
	CFPreferencesSetAppValue((CFStringRef)defaultName, (CFPropertyListRef)value, (CFStringRef)_applicationID);
  [self synchronize];
}

-(void)removeObjectForKey:(NSString *)defaultName {
	CFPreferencesSetAppValue((CFStringRef)defaultName, NULL, (CFStringRef)_applicationID);
  [self synchronize];
}


-(void)registerDefaults:(NSDictionary *)registrationDictionary {
	[_registrationDictionary release];
	_registrationDictionary = [registrationDictionary retain];
}

-(BOOL)synchronize {
	return CFPreferencesSynchronize((CFStringRef)_applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

@end
