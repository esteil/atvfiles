//
//  ATVFPlaylistAsset.m
//  ATVFiles
//
//  Created by Eric Steil III on 8/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFPlaylistAsset.h"
#import "ATVFilesAppliance.h"
#import "ATVFDatabase.h"
#import <AGRegex/AGRegex.h>
#import "ATVFMediaAsset-Private.h"

@implementation ATVFPlaylistAsset

-(id)initWithMediaURL:(id)url {
  [super initWithMediaURL:url];
  _assetType = @"playlist";
  return self;
}

-(BOOL)isStack {
  return NO;
}

-(BOOL)isPlaylist {
  return YES;
}

-(NSArray *)playlistContents {
  return _stackContents;
}

-(BOOL)appendToPlaylist:(ATVFMediaAsset *)asset {
  [_stackContents addObject:asset];
  return YES;
}

// persistence functions
-(void)_saveMetadata {
  [super _saveMetadata];
  
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

-(void)_loadMetadata {
  [super _loadMetadata];
  
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

@end
