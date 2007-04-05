/*
 *  LocalizationStuff.h
 *  ATVFiles
 *
 *  Some random macros to deal with string localizaitons.
 *
 *  Created by Eric Steil III on 4/4/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */
 
#import <BackRow/BackRow.h>

// This is our replacement for NSLocalizedString
#define BRLocalizedString(key, comment) [BRLocalizedStringManager appliance:self localizedStringForKey:key inFile:nil]
