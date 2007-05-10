//
//  ATVMediaAsset.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVMediaAsset.h"
#import "ATVFilesAppliance.h"
#import "ATVFDatabase.h"
#import "NSArray+Globbing.h"

// convenience macro
#define LOAD_METADATA if(_needsMetadataLoad) [self _loadMetadata]
#define RELEASE(obj) [obj release]; obj = nil

@interface ATVMediaAsset (Private)
-(void)_loadMetadata;
-(void)_saveMetadata;
-(void)_populateMetadata;
@end

@implementation ATVMediaAsset

-(id)initWithMediaURL:(id)url {
  LOG(@"In ATVMediaAsset -initWithMediaURL:(%@)%@", [url class], url);
  
  _needsMetadataLoad = YES;
  
  return [super initWithMediaURL:url];
}

-(void)dealloc {
  RELEASE(_artist);
  RELEASE(_mediaSummary);
  RELEASE(_mediaDescription);
  RELEASE(_copyright);
  RELEASE(_cast);
  RELEASE(_directors);
  RELEASE(_producers);
  RELEASE(_dateAcquired);
  RELEASE(_datePublished);
  RELEASE(_primaryGenre);
  RELEASE(_genres);
  RELEASE(_seriesName);
  RELEASE(_broadcaster);
  RELEASE(_episodeNumber);
  RELEASE(_rating);
  RELEASE(_publisher);
  RELEASE(_composer);
  
  [super dealloc];
}

-(BOOL)isDirectory {
	return _directory;
}

-(void)setDirectory:(BOOL)directory {
	_directory = directory;
}

-(NSComparisonResult)compareTitleWith:(id)otherAsset {
  return [[self title] compare:[otherAsset title] options:NSCaseInsensitiveSearch | NSNumericSearch];
}

-(NSString *)title {
  LOAD_METADATA;
  return _title;
}

-(void)setTitle:(NSString *)title {
  _title = title;
}

-(BRMediaType *)mediaType {
  return _mediaType;
}

-(void)setMediaType:(BRMediaType *)mediaType {
  _mediaType = mediaType;
}

-(NSString *)filename {
  return _filename;
}

-(void)setFilename:(NSString *)filename {
  _filename = filename;
}

-(NSNumber *)filesize {
  return _filesize;
}

-(void)setFilesize:(NSNumber *)filesize {
  _filesize = filesize;
}

// overrides for bookmarking?
-(void)setBookmarkTimeInMS:(unsigned int)fp8 {
  LOAD_METADATA;

  LOG(@"in -setBookmarkTimeInMS:%d", fp8);
  _bookmarkTime = fp8;
  [self _saveMetadata];
}

-(void)setHasBeenPlayed:(BOOL)fp8 {
  LOAD_METADATA;

  LOG(@"in -setHasBeenPlayed:%d", fp8);
  if(_performanceCount <= 0) {
    _performanceCount = 1;
    [self _saveMetadata];
  }
}

-(id)previewURL {
  id result = [super previewURL];
  LOG(@"in -previewURL: (%@)%@", [result class], result);
  return result;
}

-(long)duration {
  LOAD_METADATA;
  return _duration;
}

-(CGImageRef)coverArt {
  LOG(@"in -coverArt");
  
  CGImageRef coverArt = nil;
  
  // cover art finder
  // get appropriate cover art
  NSArray *artCandidates;
  NSString *path = [[NSURL URLWithString:[self mediaURL]] path];
  NSMutableString *escapedPath = [path mutableCopy];
  [escapedPath replaceOccurrencesOfString:@"[" withString:@"\\[" options:nil range:NSMakeRange(0, [escapedPath length])];
  [escapedPath replaceOccurrencesOfString:@"]" withString:@"\\]" options:nil range:NSMakeRange(0, [escapedPath length])];
  [escapedPath replaceOccurrencesOfString:@"?" withString:@"\\?" options:nil range:NSMakeRange(0, [escapedPath length])];
  [escapedPath replaceOccurrencesOfString:@"*" withString:@"\\*" options:nil range:NSMakeRange(0, [escapedPath length])];
  
  NSString *cover;
  if([self isDirectory]) {
    artCandidates = [NSArray pathsMatchingPattern:[escapedPath stringByAppendingPathComponent:@"folder.*"]];
    artCandidates = [artCandidates arrayByAddingObjectsFromArray:[NSArray pathsMatchingPattern:[escapedPath stringByAppendingPathComponent:@"cover.*"]]];
  } else {
    // look for <filename>.jpg
    artCandidates = [NSArray pathsMatchingPattern:[[escapedPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"*"]];
  }
  
  // clean up artCandidates to only the extensions we care about
  //  that is, jpg png tiff tif
  NSArray *extensions = [NSArray arrayWithObjects:@"jpg", @"png", @"tiff", @"tif", nil];
  artCandidates = [artCandidates pathsMatchingExtensions:extensions];

  LOG(@"Candidates: %@", artCandidates);
  
  // get the appropriate object, i.e. first match
  if([artCandidates count] > 0) {
    cover = [artCandidates objectAtIndex:0];
  } else {
    cover = nil;
  }
  
  if(cover) {
    LOG(@"Looking for cover art at %@", cover);
    if([[NSFileManager defaultManager] isReadableFileAtPath:cover]) {
      LOG(@"Using covert art at %@", cover);
      // load the jpg
      coverArt = CreateImageForURL((CFURLRef)[NSURL fileURLWithPath:cover]);
    }
  } else {
    LOG(@"No cover art found for %@", path);
  }

  // fallback for generic pictures
  if(!coverArt) {
    coverArt = [super coverArt];
  }
  
  return coverArt;
}

-(CGImageRef)coverArtForBookmarkTimeInMS:(unsigned int)fp8 {
  LOG(@"in -coverArtForBookmarkTimeInMS: %d", fp8);
  return [super coverArtForBookmarkTimeInMS:fp8];
}

-(unsigned int)bookmarkTimeInMS {
  LOAD_METADATA;
  
  unsigned int result = _bookmarkTime;
  LOG(@"in -bookmarkTimeInMS: %d", result);
  return result;
}

-(void)incrementPerformanceCount {
  LOAD_METADATA;

  LOG(@"in -incrementPerformanceCount");
  [super incrementPerformanceCount];
  _performanceCount++;
  [self _saveMetadata];
}

-(void)incrementPerformanceOrSkipCount:(unsigned int)fp8 {
  LOG(@"in -incrementPerformanceOrSkipCount:%d", fp8);
  [super incrementPerformanceOrSkipCount:fp8];
  _performanceCount += fp8;
  [self _saveMetadata];
}

-(long)performanceCount {
  LOAD_METADATA;

  long result = _performanceCount;
  LOG(@"in -performanceCount: %d", result);
  return result;
}

#pragma mark BRMediaAssetProtocol methods
-(long)assetID {
  LOAD_METADATA;

  return _mediaID;
}

-(NSString *)artist {
  LOAD_METADATA;

  return _artist;
}

-(NSString *)mediaSummary {
  LOAD_METADATA;
  return _mediaSummary;
}

-(NSString *)mediaDescription {
  LOAD_METADATA;
  return _mediaDescription;
}

-(NSString *)copyright {
  LOAD_METADATA;
  return _copyright;
}

-(NSArray *)cast {
  LOAD_METADATA;
  return _cast;
}

-(NSArray *)directors {
  LOAD_METADATA;
  return _directors;
}

-(NSArray *)producers {
  LOAD_METADATA;
  return _producers;
}

-(NSDate *)dateAcquired {
  LOAD_METADATA;
  return _dateAcquired;
}

-(NSDate *)datePublished {
  LOAD_METADATA;
  return _datePublished;
}

-(NSString *)primaryGenre {
  LOAD_METADATA;
  return _primaryGenre;
}

-(NSArray *)genres {
  LOAD_METADATA;
  return _genres;
}

-(NSString *)seriesName {
  LOAD_METADATA;
  return _seriesName;
}

-(NSString *)broadcaster {
  LOAD_METADATA;
  return _broadcaster;
}

-(NSString *)episodeNumber {
  LOAD_METADATA;
  return _episodeNumber;
}

-(unsigned int)season {
  LOAD_METADATA;
  return _season;
}

-(unsigned int)episode {
  LOAD_METADATA;
  return _episode;
}

-(float)userStarRating {
  LOAD_METADATA;
  return _userStarRating;
}

-(NSString *)rating {
  LOAD_METADATA;
  return _rating;
}

-(float)starRating {
  LOAD_METADATA;
  return _starRating;
}

-(NSString *)publisher {
  LOAD_METADATA;
  return _publisher;
}

-(NSString *)composer {
  LOAD_METADATA;
  return _composer;
}

#pragma mark Private

// more convenience macros
#define STRING_RESULT(col) [[result stringForColumn:col] retain]
#define LONG_RESULT(col) [result longForColumn:col]
#define DATE_RESULT(col) [[result dateForColumn:col] retain];

-(void)_loadMetadata {
  LOG(@"In _loadMetadata");
  FMDatabase *db = [[ATVFDatabase sharedInstance] database];
  
  // load the base media info
  FMResultSet *result = [db executeQuery:@"SELECT * FROM media_info WHERE url = ?", [self mediaURL]];
  if([result next]) {
    // populate from result set here
    _mediaID = [result longForColumn:@"id"];
    _artist = STRING_RESULT(@"artist");
    _title = STRING_RESULT(@"title");
    _mediaSummary = STRING_RESULT(@"mediaSummary");
    _mediaDescription = STRING_RESULT(@"mediaDescription");
    _publisher = STRING_RESULT(@"publisher");
    _composer = STRING_RESULT(@"composer");
    _copyright = STRING_RESULT(@"copyright");
    _userStarRating = LONG_RESULT(@"userStarRating");
    _starRating = LONG_RESULT(@"starRating");
    _rating = STRING_RESULT(@"rating");
    _seriesName = STRING_RESULT(@"seriesName");
    _broadcaster = STRING_RESULT(@"broadcaster");
    _episodeNumber = STRING_RESULT(@"episodeNumber");
    _season = LONG_RESULT(@"season");
    _episode = LONG_RESULT(@"episode");
    _primaryGenre = STRING_RESULT(@"primaryGenre");
    _dateAcquired = DATE_RESULT(@"dateAcquired");
    _datePublished = DATE_RESULT(@"datePublished");
    _lastFileMod = DATE_RESULT(@"filemtime");
    _lastFileMetadataMod = DATE_RESULT(@"metamtime");
    _performanceCount = LONG_RESULT(@"play_count");
    _duration = LONG_RESULT(@"duration");
    _bookmarkTime = LONG_RESULT(@"bookmark_time");
    
    [result close];
    
    // array methods
    result = [db executeQuery:@"SELECT genre FROM media_genres WHERE media_id = ? ORDER BY genre", [NSNumber numberWithLong:_mediaID]];
    _genres = [[NSMutableArray alloc] init];
    while([result next]) {
      [_genres addObject:[result stringForColumn:@"genre"]];
    }
    [result close];

    result = [db executeQuery:@"SELECT name FROM media_cast WHERE media_id = ? ORDER BY name", [NSNumber numberWithLong:_mediaID]];
    _cast = [[NSMutableArray alloc] init];
    while([result next]) {
      [_cast addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    
    result = [db executeQuery:@"SELECT name FROM media_producers WHERE media_id = ? ORDER BY name", [NSNumber numberWithLong:_mediaID]];
    _producers = [[NSMutableArray alloc] init];
    while([result next]) {
      [_producers addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    
    result = [db executeQuery:@"SELECT name FROM media_directors WHERE media_id = ? ORDER BY name", [NSNumber numberWithLong:_mediaID]];
    _directors = [[NSMutableArray alloc] init];
    while([result next]) {
      [_directors addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    
  } else {
    LOG(@"No cache found, flagging for populate...");
    _needsMetadataLoad = NO;
    _mediaID = 0;
    
    [self _populateMetadata];
    
    return;
  }
  
  _needsMetadataLoad = NO;
}

-(void)_saveMetadata {
  FMDatabase *db = [[ATVFDatabase sharedInstance] database];
  
  // save basic metadata
  if(_mediaID > 0) {
    [db executeUpdate:@"UPDATE media_info SET url=?, filemtime=?, metamtime=?, duration=?, title=?, artist=?, mediaSummary=?, mediaDescription=?, publisher=?, composer=?, copyright=?, userStarRating=?, starRating=?, rating=?, seriesName=?, broadcaster=?, episodeNumber=?, season=?, episode=?, primaryGenre=?, dateAcquired=?, datePublished=?, bookmark_time=?, play_count=? WHERE id=?",
      [self mediaURL], _lastFileMod, _lastFileMetadataMod, [NSNumber numberWithLong:_duration], _title, _artist, _mediaSummary, 
      _mediaDescription, _publisher, _composer, _copyright, [NSNumber numberWithFloat:_userStarRating], 
      [NSNumber numberWithFloat:_starRating], _rating, _seriesName, _broadcaster, _episodeNumber, 
      [NSNumber numberWithInt:_season], [NSNumber numberWithInt:_episode], _primaryGenre, _dateAcquired, _datePublished, 
      [NSNumber numberWithLong:_bookmarkTime], [NSNumber numberWithLong:_performanceCount], [NSNumber numberWithLong:_mediaID]
    ];
  } else {
    [db executeUpdate:@"INSERT INTO media_info (url, filemtime, metamtime, duration, title, artist, mediaSummary, mediaDescription, publisher, composer, copyright, userStarRating, starRating, rating, seriesName, broadcaster, episodeNumber, season, episode, primaryGenre, dateAcquired, datePublished, bookmark_time, play_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [self mediaURL], _lastFileMod, _lastFileMetadataMod, [NSNumber numberWithLong:_duration], _title, _artist, _mediaSummary, 
      _mediaDescription, _publisher, _composer, _copyright, [NSNumber numberWithFloat:_userStarRating], 
      [NSNumber numberWithFloat:_starRating], _rating, _seriesName, _broadcaster, _episodeNumber, 
      [NSNumber numberWithInt:_season], [NSNumber numberWithInt:_episode], _primaryGenre, _dateAcquired, _datePublished, 
      [NSNumber numberWithLong:_bookmarkTime], [NSNumber numberWithLong:_performanceCount]
    ];
    
    // get the media id
    FMResultSet *result = [db executeQuery:@"SELECT id FROM media_info WHERE url = ?", [self mediaURL]];
    if([result next]) {
      _mediaID = [result longForColumn:@"id"];
    } else {
      _mediaID = 0;
      [result close];
      return;
    }
    [result close];
  }
  
  // save array values
  int i = 0;
  int count;
  
  [db executeUpdate:@"DELETE FROM media_genres WHERE media_id = ?", [NSNumber numberWithLong:_mediaID]];
  if(_genres) {
    count = [_genres count];
    for(i = 0; i < count; i++) {
      [db executeUpdate:@"INSERT INTO media_genres (media_id, genre) VALUES (?, ?)", [NSNumber numberWithLong:_mediaID], [_genres objectAtIndex:i]];
    }
  }
  
  [db executeUpdate:@"DELETE FROM media_cast WHERE media_id = ?", [NSNumber numberWithLong:_mediaID]];
  if(_cast) {
    count = [_cast count];
    for(i = 0; i < count; i++) {
      [db executeUpdate:@"INSERT INTO media_cast (media_id, name) VALUES (?, ?)", [NSNumber numberWithLong:_mediaID], [_cast objectAtIndex:i]];
    }
  }
  
  [db executeUpdate:@"DELETE FROM media_producers WHERE media_id = ?", [NSNumber numberWithLong:_mediaID]];
  if(_producers) {
    count = [_producers count];
    for(i = 0; i < count; i++) {
      [db executeUpdate:@"INSERT INTO media_producers (media_id, name) VALUES (?, ?)", [NSNumber numberWithLong:_mediaID], [_producers objectAtIndex:i]];
    }
  }
  
  [db executeUpdate:@"DELETE FROM media_directors WHERE media_id = ?", [NSNumber numberWithLong:_mediaID]];
  if(_directors) {
    count = [_directors count];
    for(i = 0; i < count; i++) {
      [db executeUpdate:@"INSERT INTO media_directors (media_id, name) VALUES (?, ?)", [NSNumber numberWithLong:_mediaID], [_directors objectAtIndex:i]];
    }
  }
}

// Populate the metadata from the associated XML file
// and duration.
-(void)_populateMetadata {
  LOG(@"In populateMetadata for: %@", [self mediaURL]);
  _artist = nil;
  _mediaSummary = nil;
  _mediaDescription = nil;
  _copyright = nil;
  _duration = 0;
  _performanceCount = 0;
  _cast = nil;
  _directors = nil;
  _producers = nil;
  _dateAcquired = nil;
  _datePublished = nil;
  _primaryGenre = nil;
  _genres = nil;
  _seriesName = nil;
  _broadcaster = nil;
  _episodeNumber = nil;
  _season = 0;
  _episode = 0;
  _userStarRating = 0;
  _rating = nil;
  _starRating = 0;
  _publisher = nil;
  _composer = nil;
  _bookmarkTime = 0;
  
  _lastFileMod = [[NSDate date] retain];
  _lastFileMetadataMod = [[NSDate date] retain];
  
  // populate the duration here
  if([self isDirectory] || ![[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefEnableFileDurations]) {
    _duration = 0;
  } else {
    // use QTKit to get the time
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:[self mediaURL]];
    
    if([QTMovie canInitWithURL:url]) {
      QTMovie *movie = [QTMovie movieWithURL:url error:&error];
      LOG(@"got movie: (%@)%@, error: %@", [movie class], movie, error);
    
      // if we could open the movie
      if(movie) {
        // get the duration
        QTTime qt_duration = [movie duration];
        NSTimeInterval interval;
        QTGetTimeInterval(qt_duration, &interval);
        _duration = (long)interval;
      }
    }
  }  
  
  [self _saveMetadata];
}

@end
