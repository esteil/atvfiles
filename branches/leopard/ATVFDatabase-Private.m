#import "ATVFDatabase-Private.h"
#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "FMDatabase.h"

@implementation ATVFDatabase (Private)

-(BOOL)upgradeSchema {
  int currentVersion = [self schemaVersion];
  
  if(currentVersion < LATEST_SCHEMA_VERSION) {
    LOG(@"Upgrading database schema from %d to %d...", currentVersion, LATEST_SCHEMA_VERSION);
    
    int version;
    BOOL result;
    for(version = (currentVersion + 1); version <= LATEST_SCHEMA_VERSION; version++) {
      if(!(result = [self installSchemaVersion:version])) {
        ELOG(@"Unable to upgrade database to schema %d", version);
        return result;
      } 
    }
  }

  return YES;
}

// this method can contain additional code to convert data if necessary
// otherwise it just pulls from Resources/SQLUpdates/NNN.sql, where NNN is version
-(BOOL)installSchemaVersion:(long)version {
  // find the schema file
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSString *schemaFile = [myBundle pathForResource:[NSString stringWithFormat:@"%d", version] ofType:@"sql" inDirectory:@"SQLUpdates"];
  
  if(schemaFile) {
    LOG(@"Installing schema version %d from %@", version, schemaFile);
    
    // load the sql statement
    NSError *error = nil;
    NSString *code = [NSString stringWithContentsOfFile:schemaFile encoding:NSUTF8StringEncoding error:&error];
    if(error) {
      ELOG(@"Error getting SQL data: %@", error);
      return NO;
    }
    
    [db beginTransaction];
    
    // execute it
    char *sql_error;
    int result = sqlite3_exec([db sqliteHandle], [code cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &sql_error);
    if(result != SQLITE_OK) {
      ELOG(@"Error executing SQL data: %s", sql_error);
      sqlite3_free(sql_error);
      [db rollback];
      return NO;
    }
    
    // update the schema version
    if(![db executeUpdate:[NSString stringWithFormat:@"UPDATE schema_info SET version=%d", version]]) {
      ELOG(@"Unable to update schema version: %@", [db lastErrorMessage]);
      [db rollback];
      return NO;
    }
    
    [db commit];
  }
  
  return YES;
}

@end