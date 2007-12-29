//
// ATVFPlaylistAsset.m
// ATVFiles
//
// Created by Eric Steil III on 8/4/07.
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

#import "ATVFPlaylistAsset.h"
#import "ATVFilesAppliance.h"
#import "ATVFDatabase.h"
#import <AGRegex/AGRegex.h>
#import "ATVFMediaAsset-Private.h"

@interface ATVFPlaylistAsset (Private)
-(void)_parsePlaylist;
@end

@implementation ATVFPlaylistAsset

-(id)initWithMediaURL:(id)url {
  return [self initWithMediaURL:url playlistFile:YES];
}

-(id)initWithMediaURL:(id)url playlistFile:(BOOL)file {
  [super initWithMediaURL:url];
  _assetType = @"playlist";
  [_stackContents removeAllObjects];
  
  _isFile = NO;
  if(file) {
    _isFile = YES;
    [self _parsePlaylist]; 
  }
  
  return self;
}

-(BOOL)isStack {
  return NO;
}

-(BOOL)isPlaylist {
  return YES;
}

-(BOOL)isFile {
  return _isFile;
}

-(NSArray *)playlistContents {
  return _stackContents;
}

-(BOOL)appendToPlaylist:(ATVFMediaAsset *)asset {
  [_stackContents addObject:asset];
  [self _saveMetadata];
  return YES;
}

-(BOOL)removeFromPlaylist:(ATVFMediaAsset *)asset {
  [_stackContents removeObject:asset];
  [self _saveMetadata];
  return YES;
}

-(BOOL)removePositionFromPlaylist:(long)index {
  [_stackContents removeObjectAtIndex:index];
  [self _saveMetadata];
  return YES;
}

-(BOOL)insertAsset:(ATVFMediaAsset *)asset atPosition:(long)index {
  [_stackContents insertObject:asset atIndex:index];
  [self _saveMetadata];
  return YES;
}

// persistence functions
-(void)_saveMetadata {
  [super _saveMetadata];
  
  if(!_isTemporary && !_isFile) {
    FMDatabase *db = [[ATVFDatabase sharedInstance] database];
  
    // save our contents
    long i = 0;
    int count;
  
    [db executeUpdate:@"DELETE FROM playlist_contents WHERE playlist_id = ?", [NSNumber numberWithLong:_mediaID]];
    count = [_stackContents count];
    for(i = 0; i < count; i++) {
      [db executeUpdate:@"INSERT INTO playlist_contents (playlist_id, asset_id, position) VALUES (?, ?, ?)", 
        [NSNumber numberWithLong:_mediaID], [NSNumber numberWithLong:[[_stackContents objectAtIndex:i] mediaID]], [NSNumber numberWithLong:i]
      ];
    }
  }
}

-(void)_loadMetadata {
  [super _loadMetadata];
  
  if(!_isFile) {
    FMDatabase *db = [[ATVFDatabase sharedInstance] database];
    FMResultSet *result;

    // load our contents
    result = [db executeQuery:@"SELECT asset_id FROM playlist_contents WHERE playlist_id = ? ORDER BY position", 
      [NSNumber numberWithLong:_mediaID]
    ];
  
    [_stackContents release];
    _stackContents = [[NSMutableArray alloc] init];
    while([result next]) {
      [_stackContents addObject:[[ATVFDatabase sharedInstance] assetForId:[result longForColumn:@"asset_id"]]];
    }
    [result close];
  }
}

-(void)_parsePlaylist {
  LOG(@"In ATVFPlaylistAsset _parsePlaylist for %@", [self mediaURL]);
  
  NSMutableString *contents = [[NSString stringWithContentsOfURL:[NSURL URLWithString:[self mediaURL]]] mutableCopy];
  
  // normalize the line endings
  [contents replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:nil range:NSMakeRange(0, [contents length])];
  [contents replaceOccurrencesOfString:@"\r" withString:@"\n" options:nil range:NSMakeRange(0, [contents length])];

  NSArray *lines = [contents componentsSeparatedByString:@"\n"];
  NSString *line;
  NSEnumerator *lineEnum = [lines objectEnumerator];
  NSURL *url;
  NSString *prefix = [[[NSURL URLWithString:[self mediaURL]] path] stringByDeletingLastPathComponent];
  LOG(@"Playlist prefix: %@", prefix);
  ATVFMediaAsset *entryAsset;
  
  while(line = [lineEnum nextObject]) {
    LOG(@"Got line: %@", line);
    // skip if it's blank or a comment line
    if([line isEqualToString:@""] || [line hasPrefix:@"#"]) continue;
    
    // otherwise make a url and add it to our contents
    if([line hasPrefix:@"/"]) {
      // absolute path
      url = [NSURL fileURLWithPath:line];
    } else {
      // relative path, so use our path
      url = [NSURL fileURLWithPath:[prefix stringByAppendingPathComponent:line]];
    }
    
    LOG(@"Represents %@", url);
    entryAsset = [[[ATVFMediaAsset alloc] initWithMediaURL:url] autorelease];
    [self appendToPlaylist:entryAsset];
  }
}

@end
