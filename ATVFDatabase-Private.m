//
// ATVFDatabase-Private.m
// ATVFiles
//
// Copyright (C) 2007-2008 Eric Steil III
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