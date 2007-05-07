//
//  ATVFDatabase.m
//  ATVFiles
//
//  Created by Eric Steil III on 5/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFDatabase.h"
#import "ATVFDatabase-Private.h"

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
  
#ifdef DEBUG
  [db setTraceExecution:YES];
  [db setLogsErrors:YES];
#endif

  [db open];
  [self upgradeSchema];
  
	return self;
}

-(int)schemaVersion {
  int schema = 0;
  FMResultSet *result = [db executeQuery:@"SELECT version FROM schema_info LIMIT 1"];
  if([result next]) {
    NSString *version = [result stringForColumn:@"version"];
    LOG(@"NSString version: %@", version);
    schema = [version intValue];
    LOG(@"Version: [%@] = %d", version, schema);
  }
  [result close];
  return schema;
}

@end
