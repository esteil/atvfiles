//
//  ATVFPreferences.h
//  ATVFiles
//
//  Mainly this is convenience functions for setting preferences with the CFPreferences API
//
//  Created by Eric Steil III on 9/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
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
