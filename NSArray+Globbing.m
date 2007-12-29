//
// NSArray+Globbing.m
// ATVFiles
//
// Created by Eric Steil III on 4/8/07.
// Copyright (C) 2007 Eric Steil III
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
