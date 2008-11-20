/*
 *  BackRowUtils.h
 *  AwkwardTV
 *
 *  Created by Alan Quatermain on 02/04/07.
 *  Copyright 2007 AwkwardTV. All rights reserved.
 *
 */

#import <syslog.h>
#import <Foundation/Foundation.h>
#import <BackRow/BRLocalizedStringManager.h>

// BackRow-supplied logging routines
void BRLog( NSString * format, ... );
void BRDebugLog( NSString * format, ... );
void BRSystemLog( int level, NSString * format, ... );
void BRSystemLogv( int level, NSString * format, va_list args );

// other BackRow public functions
CGImageRef CreateImageForURL( CFURLRef imageURL );

// plugin-based NSLocalizedString macros
// use genstrings -s BRLocalizedString -o <Language>.lproj to generate Localized.strings
#define BRLocalizedString(key, comment) \
[BRLocalizedStringManager appliance:self localizedStringForKey:(key) inFile:nil]
#define BRLocalizedStringFromTable(key, tbl, comment) \
[BRLocalizedStringManager appliance:self localizedStringForKey:(key) inFile:(tbl)]

// stuff
NSRect ScaleFrameForAspectRatio(float ratio, NSRect frame);

// convenience macros to make the code a little nicer
#define ATV_11 if(![SapphireFrontRowCompat usingTakeTwo] && ![SapphireFrontRowCompat usingTakeTwoDotTwo])
#define FRONTROW if([SapphireFrontRowCompat usingFrontRow])
#define ATV_20 if([SapphireFrontRowCompat usingTakeTwo])
#define ATV_20_ONLY if([SapphireFrontRowCompat usingTakeTwo] && ![SapphireFrontRowCompat usingTakeTwoDotTwo])
#define NOT_ATV_22 if(![SapphireFrontRowCompat usingTakeTwoDotTwo])
#define ATV_22 if([SapphireFrontRowCompat usingTakeTwoDotTwo])
#define ATV_23 if(NSClassFromString(@"ATVAirTunesManager"))
