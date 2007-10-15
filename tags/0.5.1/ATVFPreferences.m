//
//  ATVFPreferences.m
//  ATVFiles
//
//  Based on BundleUserDefaults http://cocoacafe.wordpress.com/2007/06/18/bundleuserdefaults/
//
//  Created by Eric Steil III on 9/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
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
}

-(void)removeObjectForKey:(NSString *)defaultName {
	CFPreferencesSetAppValue((CFStringRef)defaultName, NULL, (CFStringRef)_applicationID);
}


-(void)registerDefaults:(NSDictionary *)registrationDictionary {
	[_registrationDictionary release];
	_registrationDictionary = [registrationDictionary retain];
}

-(BOOL)synchronize {
	return CFPreferencesSynchronize((CFStringRef)_applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

@end
