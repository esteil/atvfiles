//
//  ATVFilesAppliance.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFilesAppliance.h"

static IMP gOrigLoadAppliancePtr = (IMP)0;

@class BRAlertController;

@implementation ATVFilesAppliance

- (id)applianceControllerWithScene:(id)scene {
	BRAlertController *alert = [BRAlertController alertOfType:2
													   titled:@"ATVFilesAppliance"
												  primaryText:@"ATVFilesAppliance is running!"
												secondaryText:@"Now to make it useful."
													withScene:scene];
	return alert;

//	// create a menu list?
//	FilezMenu *menu = [[[FilezMenu alloc] initWithScene:scene] autorelease];
//	NSLog(@"menu: %@", menu);
	
//	return menu;
}

-(NSString *)applianceKey {
	return @"ATVFilesAppliance";
}

-(NSString *)applianceName {
	return @"ATVFilesAppliance";
}




+(void) load {
	NSLog(@"load ATVFilesAppliance");
}

// Override to allow FrontRow to load multiple appliance plugins
// From: http://forums.somethingawful.com/showthread.php?action=showpost&postid=325081231#post325081231
+ (NSString *) className {
    // this function creates an NSString from the contents of the
    // struct objc_class, which means using this will not call this
    // function recursively, and it'll also return the *real* class
    // name.
    NSString * className = NSStringFromClass( self );
	
    if ( gOrigLoadAppliancePtr == 0 ) {
        // get original function address
        // one implementation is raw C code, which may be more reliable
        // (can't be overridden by the target class)
        /*
		 Class c = objc_getClass( "BRApplianceManager" );
		 Method m = class_getInstanceMethod( c, @selector( _loadApplianceInfoAtPath: ) );
		 if ( m != NULL )
		 gOrigLoadAppliancePtr = (_loadApplianceInfoAtPath_fn) m->method_imp;
		 */
        gOrigLoadAppliancePtr = [BRApplianceManager instanceMethodForSelector:
            @selector( _loadApplianceInfoAtPath: )];
    }
	
    @try {
        [NSException raise: NSGenericException format: @"backtracing"];
    } @catch(NSException * e) {
        [e _addExceptionHandlerStackTrace];
        NSArray * trace = [[[e userInfo] objectForKey: @"NSStackTraceKey"]
                           componentsSeparatedByString: @"  "];
        if ( [trace count] > 2 ) {
            void * test = (void *) gOrigLoadAppliancePtr;
            NSString * callerStr = [trace objectAtIndex:1];
			unsigned int caller;
            [[NSScanner scannerWithString: callerStr] scanHexInt:&caller];
			
            // an arbitrary number -- function is a little over a
            // kilobyte in size, but the className call is near the
            // beginning anyway
            if ( (caller > test) && (caller < test + 1000) ) {
                NSLog(@"+[%@ className] called for whitelist check, so I'm lying, m'kay?",
                             className );
                className = @"RUICalibrationAppliance";
            }
        }
    }
	
    return ( className );
}

@end
