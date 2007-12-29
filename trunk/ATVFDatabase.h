//
// ATVFDatabase.h
// ATVFiles
//
// Created by Eric Steil III on 5/6/07.
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

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "ATVFMediaAsset.h"

// the latest schema version
#define LATEST_SCHEMA_VERSION 2

@interface ATVFDatabase : BRSingleton {
	FMDatabase *db;
}

// singleton stuff
+(id)singleton;
+(void)setSingleton:(id)singleton;

-(FMDatabase *)database;

-(ATVFMediaAsset *)assetForId:(long)id;

// utility methods
-(int)schemaVersion;

@end
