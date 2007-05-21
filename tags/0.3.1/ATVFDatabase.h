//
//  ATVFDatabase.h
//  ATVFiles
//
//  Created by Eric Steil III on 5/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

// the latest schema version
#define LATEST_SCHEMA_VERSION 1

@interface ATVFDatabase : BRSingleton {
	FMDatabase *db;
}

// singleton stuff
+(id)singleton;
+(void)setSingleton:(id)singleton;

-(FMDatabase *)database;

// utility methods
-(int)schemaVersion;

@end
