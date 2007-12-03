//
//  NSArray+Globbing.m
//  ATVFiles
//
//  Created by Eric Steil III on 4/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Globbing.h"
#include <glob.h>

@implementation NSArray (Globbing)

/* Return an array of pathnames that match a shell-like pattern.
* The pattern may contain *, ?, ~ or [...] wildcards.
* See the manual page for bash or glob(3) for more details.
*/
+(NSArray *)pathsMatchingPattern:(NSString *)pattern {
	
	NSMutableArray* result = [NSMutableArray array];
	
	glob_t g;
	glob([pattern cStringUsingEncoding:NSUTF8StringEncoding], GLOB_NOSORT|GLOB_TILDE|GLOB_QUOTE, NULL, &g);
	
	int i;
	for (i = 0; i < g.gl_pathc; i++) {
		NSString* path = [NSString stringWithCString:g.gl_pathv[i] encoding:NSUTF8StringEncoding];
		[result addObject:path];
	}
	
	globfree(&g);
	
	return result;
}

@end
