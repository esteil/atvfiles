//
//  ATVFDatabase.m
//  ATVFiles
//
//  Created by Eric Steil III on 5/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFDatabase.h"

static ATVFDatabase *__ATVFDatabase_singleton = nil;

@implementation ATVFDatabase

+(id)singleton {
  return __ATVFDatabase_singleton;
}

+(void)setSingleton:(id)singleton {
  __ATVFDatabase_singleton = (ATVFDatabase *)singleton;
}

-(ATVFDatabase *)init {
  LOG(@"In ATVFDatabase init");
  db = [[FMDatabase databaseWithPath:@"/tmp/test.db"] retain];
  [db open];
  
	return self;
}

-(int)schemaVersion {
  return [[db executeQuery:@"PRAGMA user_version"] intForColumnIndex:0];
}

@end
