//
//  NSArray+Globbing.h
//  ATVFiles
//
//  Created by Eric Steil III on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (Globbing)

+(NSArray *)pathsMatchingPattern:(NSString *)pattern;

@end
