//
//  ATVFCoreAudioHelper.h
//  ATVFiles
//
//  Created by Eric Steil III on 4/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATVFCoreAudioHelper : NSObject {

}

+(float)systemSampleRate;
+(BOOL)setSystemSampleRate:(float)rate;

+(CFTypeRef)getPassthroughPreference;
+(void)setPassthroughPreference:(CFTypeRef)value;

@end
