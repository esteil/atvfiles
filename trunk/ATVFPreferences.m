//
//  ATVFPreferences.m
//  ATVFiles
//
//  Created by Eric Steil III on 9/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFPreferences.h"

@implementation ATVFPreferences
// the basic get value function
// the basic set value function
+(void)setValue:(CFTypeRef)value forKey:(CFStringRef)key {
  CFPreferencesSetAppValue(key, value, CFSTR("net.ericiii.ATVFiles"));
  CFPreferencesAppSynchronize(CFSTR("net.ericiii.ATVFiles"));
}

+(void)setInt:(int)value forKey:(CFStringRef)key {
  [self setValue:[NSNumber numberWithInt:value] forKey:key];
}

+(void)setBool:(BOOL)value forKey:(CFStringRef)key {
  [self setValue:[NSNumber numberWithBool:value] forKey:key];
}

@end
