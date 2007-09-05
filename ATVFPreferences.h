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


@interface ATVFPreferences : NSObject {

}

+(void)setValue:(CFTypeRef)value forKey:(CFStringRef)key;
+(void)setInt:(int)value forKey:(CFStringRef)key;
+(void)setBool:(BOOL)value forKey:(CFStringRef)key;

@end
