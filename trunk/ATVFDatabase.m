//
//  ATVFDatabase.m
//  ATVFiles
//
//  Created by Eric Steil III on 5/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFDatabase.h"
#import "ATVFDatabase-Private.h"
#import <BackRow/BackRow.h>

static ATVFDatabase *__ATVFDatabase_singleton = nil;

@implementation ATVFDatabase

+(id)singleton {
  return __ATVFDatabase_singleton;
}

+(void)setSingleton:(id)singleton {
  __ATVFDatabase_singleton = (ATVFDatabase *)singleton;
}

-(ATVFDatabase *)init {
  // NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:@"ATVFiles.db"];
  
  NSString *path;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  path = [paths objectAtIndex:0];
  if(!path) {
    ELOG(@"FATAL ERROR CANNOT FIND DATABASE PATH: %@", paths);
  }

  path = [[path stringByAppendingPathComponent:@"ATVFiles"] stringByAppendingPathComponent:@"ATVFiles.db"];
  
  // recursive directory creation to create it
  NSString *appSupportATVFiles = [path stringByDeletingLastPathComponent];
  if(![[NSFileManager defaultManager] fileExistsAtPath:appSupportATVFiles isDirectory:nil]) {
    LOG(@"Creating ~/Library/Application Support/ATVFiles directory");
    [[NSFileManager defaultManager] createDirectoryAtPath:appSupportATVFiles attributes:nil];
  }
  
  LOG(@"In ATVFDatabase init: %@", path);
  db = [[FMDatabase databaseWithPath:path] retain];
  
#ifdef DEBUG
  [db setTraceExecution:YES];
  [db setLogsErrors:YES];
#endif

  [db open];
  [self upgradeSchema];
  
	return self;
}

-(void)dealloc {
  [db close];
  [db release];
  db = nil;
  [super dealloc];
}

-(FMDatabase *)database {
  return db;
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
