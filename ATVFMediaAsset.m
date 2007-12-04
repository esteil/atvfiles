//
//  ATVFMediaAsset.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFMediaAsset.h"
#import "ATVFilesAppliance.h"
#import "ATVFDatabase.h"
#import "NSArray+Globbing.h"
#import <AGRegex/AGRegex.h>
#import "ATVFMediaAsset-Private.h"
#import "ATVFPreferences.h"

// convenience macro
#define LOAD_METADATA if(_needsMetadataLoad) [self _loadMetadata]
#define RELEASE(obj) [obj release]; obj = nil

@implementation ATVFMediaAsset

-(id)initWithMediaURL:(id)url {
  LOG(@"In ATVFMediaAsset -initWithMediaURL:(%@)%@", [url class], url);
  
  _needsMetadataLoad = YES;
  _needsMetadataSave = NO;
  _isTemporary = NO;
  _assetType = @"file";
  
  // load our file metadata info
  if([url isFileURL]) {
    NSDictionary *attributes = [[NSFileManager defaultManager] fileAttributesAtPath:[url path] traverseLink:NO];
    _lastFileMod = [[attributes objectForKey:NSFileModificationDate] retain];
  }
  
  _stackContents = [[NSMutableArray arrayWithObject:url] retain];

  return [super initWithMediaURL:url];
}

-(void)dealloc {
  LOG(@"In ATVFMediaAsset dealloc: %@", [self mediaURL]);
  
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
  RELEASE(_primaryGenreString);
  RELEASE(_genres);
  RELEASE(_seriesName);
  RELEASE(_broadcaster);
  RELEASE(_episodeNumber);
  RELEASE(_rating);
  RELEASE(_publisher);
  RELEASE(_composer);
  RELEASE(_lastFileMod);
  RELEASE(_lastFileMetadataMod);
  RELEASE(_stackContents);
  RELEASE(_filesize);
  
  [super dealloc];
}

-(BOOL)isDirectory {
	return _directory;
}

-(void)setDirectory:(BOOL)directory {
  if(directory) _isTemporary = YES;
	_directory = directory;
}

-(NSComparisonResult)compareTitleWith:(id)otherAsset {
  return [[self title] compare:[otherAsset title] options:NSCaseInsensitiveSearch | NSNumericSearch];
}

-(NSString *)title {
  LOAD_METADATA;
  NSString *title = _title;
  BOOL showExtensions = [[ATVFPreferences preferences] boolForKey:kATVPrefShowFileExtensions];
  if(!showExtensions
      && ![self isDirectory] 
      // if it's not the filename, don't strip
      && [_title isEqual:[[[self mediaURL] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
    title = [_title stringByDeletingPathExtension];
  }

  return title;
}

-(void)setTitle:(NSString *)title {
  [_title release];
  _title = title;
  [_title retain];
}

-(BRMediaType *)mediaType {
  return _mediaType;
}

-(void)setMediaType:(BRMediaType *)mediaType {
  [_mediaType release];
  _mediaType = mediaType;
  [_mediaType retain];
}

-(NSString *)filename {
  return _filename;
}

-(void)setFilename:(NSString *)filename {
  [_filename release];
  _filename = filename;
  [filename retain];
}

-(NSNumber *)filesize {
  return _filesize;
}

-(void)setFilesize:(NSNumber *)filesize {
  [_filesize release];
  _filesize = filesize;
  [_filesize retain];
}

// overrides for bookmarking?
-(void)setBookmarkTimeInMS:(unsigned int)fp8 {
  LOAD_METADATA;

  LOG(@"in -setBookmarkTimeInMS:%d", fp8);
  _bookmarkTime = fp8;
  if(_bookmarkTime >= ((_duration - 1) * 1000)) {
    // we're at the end, so set it to the beginning
    _bookmarkTime = 0;
  }
  [self _saveMetadata];
  // _needsMetadataSave = YES;
}

-(void)setHasBeenPlayed:(BOOL)fp8 {
  LOAD_METADATA;

  LOG(@"in -setHasBeenPlayed:%d", fp8);
  if(fp8) {
    if(_performanceCount <= 0) {
      _performanceCount = 1;
    }
  } else {
    _performanceCount = 0;
  }

  [self _saveMetadata];
  // _needsMetadataSave = YES;
}

-(BOOL)hasBeenPlayed {
  return _performanceCount > 0;
}

-(id)previewURL {
  id result;
  NSString *coverArtPath = [self _coverArtPath];

  if(coverArtPath) {
    result = [[NSURL fileURLWithPath:coverArtPath] absoluteString];
  } else {
    result = [super previewURL];
  }
  
  LOG(@"In -previewURL: %@", result);
  return result;
}

-(BOOL)hasCoverArt {
  LOG(@"In hasCoverArt");
  
  return [self previewURL] != nil;
}

-(id)coverArtID {
  LOG(@"In coverArtId, parent: (%@)%@", [[super coverArtID] class], [super coverArtID]);
  return [super coverArtID];
  // return @"COVER_ART_ID";
}

-(long)duration {
  LOAD_METADATA;
  return _duration;
}

-(CGImageRef)coverArt {
  LOG(@"in -coverArt");
  
  CGImageRef coverArt = nil;

  LOG(@"My previewURL: %@", [self previewURL]);
  NSString *previewURLStr = [self previewURL];
  LOG(@"After previewURLStr = [self previewURL]");
  
  if(previewURLStr) {
    NSURL *previewURL = [NSURL URLWithString:previewURLStr];
    LOG(@"cover URL Str: %@", previewURL);
    coverArt = CreateImageForURL((CFURLRef)previewURL);
  } else {
    LOG(@"No coverart, falling back");
    // fallback for generic pictures
    coverArt = [super coverArt];
    LOG(@"Coverart from super: %@", coverArt);
  }
  
  LOG(@" Returning: %@", coverArt);
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
  unsigned long offset = [[[ATVFPreferences preferences] valueForKey:kATVPrefResumeOffset] intValue] * 1000;
  return result + offset;
}

-(void)incrementPerformanceCount {
  LOAD_METADATA;

  LOG(@"in -incrementPerformanceCount");
  [super incrementPerformanceCount];
  _performanceCount++;
  [self _saveMetadata];
  // _needsMetadataSave = YES;
}

-(void)incrementPerformanceOrSkipCount:(unsigned int)fp8 {
  LOG(@"in -incrementPerformanceOrSkipCount:%d", fp8);
  [super incrementPerformanceOrSkipCount:fp8];
  _performanceCount += fp8;
  [self _saveMetadata];
  // _needsMetadataSave = YES;
}

-(long)performanceCount {
  LOAD_METADATA;

  long result = _performanceCount;
  LOG(@"in -performanceCount: %d", result);
  return result;
}

#pragma mark BRMediaAssetProtocol methods
-(id)assetID {
  LOAD_METADATA;
  LOG(@"In assetID");

  return [NSString stringWithFormat:@"%d", _mediaID];
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

-(BRGenre *)primaryGenre {
  LOAD_METADATA;
  return _primaryGenre;
}

-(NSString *)primaryGenreString {
  LOAD_METADATA;
  return _primaryGenreString;
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

-(void)setDuration:(long)duration {
  _duration = duration;
  [self _saveMetadata];
  // _needsMetadataSave = YES;
}

-(BOOL)isTemporary {
  return _isTemporary;
}

-(void)setTemporary:(BOOL)temporary {
  // we block directories from being saved.
  if(![self isDirectory]) _isTemporary = temporary;
}

// stack stuff
// add a URL onto the stack for this asset
-(void)addURLToStack:(NSURL *)URL {
  [_stackContents addObject:URL];
}

-(NSArray *)stackContents {
  return _stackContents;
}

-(BOOL)isStack {
  return _stackContents ? ([_stackContents count] > 1) : NO;
}

-(BOOL)isPlaylist {
  return NO;
}

-(long)mediaID {
  return _mediaID;
}

// NSObject protocol methods
-(unsigned)hash {
  return [self mediaID];
}

-(BOOL)isEqual:(id)object {
  if([object isKindOfClass:[ATVFMediaAsset class]]) {
    return [object mediaID] == [self mediaID];
  } else {
    return NO;
  }
}

@end

@implementation ATVFMediaAsset (Private)
// more convenience macros
#define STRING_RESULT(col) [[result stringForColumn:col] retain]
#define LONG_RESULT(col) [result longForColumn:col]
#define DATE_RESULT(col) [[result dateForColumn:col] retain];

-(void)_loadMetadata {
  BOOL _needPopulate = NO;
  NSDate *_lastFileModRecorded, *_lastFileMetadataModRecorded;
  _lastFileMetadataMod = [[NSDate dateWithTimeIntervalSince1970:-1] retain];
  
  // don't save directories
  if([self isDirectory]) {
    return;
  }

  LOG(@"In _loadMetadata for asset: %@", [self mediaURL]);
  
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
    _primaryGenre = [[BRGenre typeForString:[result stringForColumn:@"primaryGenre"]] retain];
    _primaryGenreString = [[result stringForColumn:@"primaryGenre"] retain];
    _mediaType = [[BRMediaType typeForString:[result stringForColumn:@"mediaType"]] retain];
    LOG(@"Media Type: %@, %@", _mediaType, [_mediaType typeString]);
    _dateAcquired = DATE_RESULT(@"dateAcquired");
    if([_dateAcquired timeIntervalSince1970] == 0) {
      [_dateAcquired release];
      _dateAcquired = nil;
    }
    _datePublished = DATE_RESULT(@"datePublished");
    if([_datePublished timeIntervalSince1970] == 0) {
      [_datePublished release];
      _datePublished = nil;
    }
    _lastFileModRecorded = DATE_RESULT(@"filemtime");
    _lastFileMetadataModRecorded = DATE_RESULT(@"metamtime");
    _performanceCount = LONG_RESULT(@"play_count");
    _duration = LONG_RESULT(@"duration");
    _bookmarkTime = LONG_RESULT(@"bookmark_time");
    
    [result close];
    
    // array methods
    result = [db executeQuery:@"SELECT genre FROM media_genres WHERE media_id = ? ORDER BY genre", [NSNumber numberWithLong:_mediaID]];
    [_genres release];
    _genres = [[NSMutableArray alloc] init];
    while([result next]) {
      [_genres addObject:[BRGenre typeForString:[result stringForColumn:@"genre"]]];
    }
    [result close];

    result = [db executeQuery:@"SELECT name FROM media_cast WHERE media_id = ? ORDER BY name", [NSNumber numberWithLong:_mediaID]];
    [_cast release];
    _cast = [[NSMutableArray alloc] init];
    while([result next]) {
      [_cast addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    
    result = [db executeQuery:@"SELECT name FROM media_producers WHERE media_id = ? ORDER BY name", [NSNumber numberWithLong:_mediaID]];
    [_producers release];
    _producers = [[NSMutableArray alloc] init];
    while([result next]) {
      [_producers addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    
    result = [db executeQuery:@"SELECT name FROM media_directors WHERE media_id = ? ORDER BY name", [NSNumber numberWithLong:_mediaID]];
    [_directors release];
    _directors = [[NSMutableArray alloc] init];
    while([result next]) {
      [_directors addObject:[result stringForColumn:@"name"]];
    }
    [result close];
    
  } else {
    _needPopulate = YES;
    _mediaID = 0;
  }
  
  // look for metadata mtime stuff
  NSString *metadataPath = [[[[NSURL URLWithString:[self mediaURL]] path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xml"];
  NSDictionary *attributes = [[NSFileManager defaultManager] fileAttributesAtPath:metadataPath traverseLink:NO];
  _lastFileMetadataMod = [[attributes objectForKey:NSFileModificationDate] retain];
  if(!_lastFileMetadataMod) _lastFileMetadataMod = [[NSDate dateWithTimeIntervalSince1970:-1] retain];

  BOOL _fileModified = NO, _metaModified = NO;
  if(!_needPopulate) {
    _fileModified = [_lastFileModRecorded timeIntervalSince1970] < [_lastFileMod timeIntervalSince1970];
    _metaModified = [_lastFileMetadataModRecorded timeIntervalSince1970] < [_lastFileMetadataMod timeIntervalSince1970];
  }
  
  if(_needPopulate || _fileModified || _metaModified) {
    LOG(@"No cache found or cache outdated, populating...");
    _needsMetadataLoad = NO;
    
    [self _populateMetadata:_needPopulate];
    
    return;
  }
  
  _needsMetadataLoad = NO;
}

-(void)_saveMetadata {
  // don't save assets marked temporary
  if(_isTemporary) {
    return;
  }
  
  LOG(@"In -ATVFMediaAsset _saveMetadata for: %@", [self mediaURL]);
  
  LOAD_METADATA;
  
  FMDatabase *db = [[ATVFDatabase sharedInstance] database];
  [db beginTransaction];
  
  // save basic metadata
  if(_mediaID > 0) {
    [db executeUpdate:@"UPDATE media_info SET url=?, filemtime=?, metamtime=?, duration=?, title=?, artist=?, mediaSummary=?, mediaDescription=?, publisher=?, composer=?, copyright=?, userStarRating=?, starRating=?, rating=?, seriesName=?, broadcaster=?, episodeNumber=?, season=?, episode=?, primaryGenre=?, dateAcquired=?, datePublished=?, bookmark_time=?, play_count=?, mediaType=?, asset_type=? WHERE id=?",
      [self mediaURL], _lastFileMod, _lastFileMetadataMod, [NSNumber numberWithLong:_duration], _title, _artist, _mediaSummary, 
      _mediaDescription, _publisher, _composer, _copyright, [NSNumber numberWithFloat:_userStarRating], 
      [NSNumber numberWithFloat:_starRating], _rating, _seriesName, _broadcaster, _episodeNumber, 
      [NSNumber numberWithInt:_season], [NSNumber numberWithInt:_episode], _primaryGenreString, _dateAcquired, _datePublished, 
      [NSNumber numberWithLong:_bookmarkTime], [NSNumber numberWithLong:_performanceCount], [_mediaType typeString], _assetType,
      [NSNumber numberWithLong:_mediaID]
    ];
  } else {
    [db executeUpdate:@"INSERT INTO media_info (url, filemtime, metamtime, duration, title, artist, mediaSummary, mediaDescription, publisher, composer, copyright, userStarRating, starRating, rating, seriesName, broadcaster, episodeNumber, season, episode, primaryGenre, dateAcquired, datePublished, bookmark_time, play_count, mediaType, asset_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [self mediaURL], _lastFileMod, _lastFileMetadataMod, [NSNumber numberWithLong:_duration], _title, _artist, _mediaSummary, 
      _mediaDescription, _publisher, _composer, _copyright, [NSNumber numberWithFloat:_userStarRating], 
      [NSNumber numberWithFloat:_starRating], _rating, _seriesName, _broadcaster, _episodeNumber, 
      [NSNumber numberWithInt:_season], [NSNumber numberWithInt:_episode], _primaryGenreString, _dateAcquired, _datePublished, 
      [NSNumber numberWithLong:_bookmarkTime], [NSNumber numberWithLong:_performanceCount], [_mediaType typeString], _assetType
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
      [db executeUpdate:@"INSERT INTO media_genres (media_id, genre) VALUES (?, ?)", [NSNumber numberWithLong:_mediaID], [[_genres objectAtIndex:i] typeString]];
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
  [db commit];
}

// Populate the metadata from the associated XML file
// and duration.
-(void)_populateMetadata:(BOOL)isNew {
  LOG(@"In populateMetadata for: %@", [self mediaURL]);
  if(isNew) {
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
    _primaryGenreString = nil;
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
    _duration = 0;
  }
  
  if([self isDirectory] || ![[ATVFPreferences preferences] boolForKey:kATVPrefEnableFileDurations]) {
    _duration = 0;
  }

  NSURL *url = [NSURL URLWithString:[self mediaURL]];
  NSError *error = nil;
  
  // and parse the XML here
  NSString *metadataPath = [self _metadataXmlPath];
  NSURL *metadataURL = [NSURL fileURLWithPath:metadataPath];
  LOG(@"MD XML URL: %@", metadataURL);
  
  NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:metadataURL options:NSXMLDocumentTidyXML error:&error];
  if(doc == nil) {
    ELOG(@"Error parsing XML %@: %@", metadataURL, error);
  }
  
  NSArray *mediaNodes = [doc nodesForXPath:@"./media" error:nil];
  if([mediaNodes count] > 0) {
    id mediaNode = [mediaNodes objectAtIndex:0];
    id nodes;
    id node;
    
    if([mediaNode attributeForName:@"type"]) {
      [_mediaType release];
      _mediaType = [[BRMediaType typeForString:[[mediaNode attributeForName:@"type"] stringValue]] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./title" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_title release];
      _title = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./artist" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_artist release];
      _artist = [[node stringValue] retain];
    }  
    if((nodes = [mediaNode nodesForXPath:@"./summary" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_mediaSummary release];
      _mediaSummary = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./description" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_mediaDescription release];
      _mediaDescription = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./publisher" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_publisher release];
      _publisher = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./composer" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_composer release];
      _composer = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./copyright" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_copyright release];
      _copyright = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./userStarRating" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      _userStarRating = [[node stringValue] floatValue];
    }
    if((nodes = [mediaNode nodesForXPath:@"./starRating" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      _starRating = [[node stringValue] floatValue];
    }
    if((nodes = [mediaNode nodesForXPath:@"./rating" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_rating release];
      _rating = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./seriesName" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_seriesName release];
      _seriesName = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./broadcaster" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_broadcaster release];
      _broadcaster = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./episodeNumber" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_episodeNumber release];
      _episodeNumber = [[node stringValue] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./season" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      _season = [[node stringValue] intValue];
    }
    if((nodes = [mediaNode nodesForXPath:@"./episode" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      _episode = [[node stringValue] intValue];
    }
    if((nodes = [mediaNode nodesForXPath:@"./published" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_datePublished release];
      _datePublished = [[NSCalendarDate dateWithString:[node stringValue] calendarFormat:@"%Y-%m-%d"] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./acquired" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      [_dateAcquired release];
      _dateAcquired = [[NSCalendarDate dateWithString:[node stringValue] calendarFormat:@"%Y-%m-%d"] retain];
    }
    if((nodes = [mediaNode nodesForXPath:@"./duration" error:nil]) && [nodes count] > 0) {
      node = [nodes objectAtIndex:0];
      _duration = [[node stringValue] intValue];
    }
    
    // the arrays
    int count = 0, i = 0;
    if([(nodes = [mediaNode nodesForXPath:@"./genres/genre" error:nil]) count] > 0) {
      [_genres release];
      _genres = [[NSMutableArray alloc] init];
      count = [nodes count];
      for(i = 0; i < count; i++) {
        node = [nodes objectAtIndex:i];
        [_genres addObject:[BRGenre typeForString:[node stringValue]]];
        if([[[node attributeForName:@"primary"] stringValue] isEqualToString:@"true"]) {
          [_primaryGenre release];
          _primaryGenre = [[BRGenre typeForString:[node stringValue]] retain];
          [_primaryGenreString release];
          _primaryGenreString = [[node stringValue] retain];
        }
      }
    }
    
    if([(nodes = [mediaNode nodesForXPath:@"./cast/name" error:nil]) count] > 0) {
      [_cast release];
      _cast = [[NSMutableArray alloc] init];
      count = [nodes count];
      for(i = 0; i < count; i++) {
        node = [nodes objectAtIndex:i];
        [_cast addObject:[node stringValue]];
      }
    }
    
    if([(nodes = [mediaNode nodesForXPath:@"./producers/name" error:nil]) count] > 0) {
      [_producers release];
      _producers = [[NSMutableArray alloc] init];
      count = [nodes count];
      for(i = 0; i < count; i++) {
        node = [nodes objectAtIndex:i];
        [_producers addObject:[node stringValue]];
      }
    }
    
    if([(nodes = [mediaNode nodesForXPath:@"./directors/name" error:nil]) count] > 0) {
      [_directors release];
      _directors = [[NSMutableArray alloc] init];
      count = [nodes count];
      for(i = 0; i < count; i++) {
        node = [nodes objectAtIndex:i];
        [_directors addObject:[node stringValue]];
      }
    }
    
  } else {
    ELOG(@"Media node not found, invalid XML file.");
  }
  
  [doc release];

  // populate the duration here
#ifdef READ_DURATIONS_AT_MENU
  if((_duration == 0 || _duration != 0) && ![self isDirectory] && [[ATVFPreferences preferences] boolForKey:kATVPrefEnableFileDurations]) {
    
#ifdef USE_QTKIT_DURATIONS
    // use QTKit to get the time
    if([QTMovie canInitWithURL:url]) {
      // NeverIdleFile of net.telestream.wmv.import NO
      CFPreferencesSetAppValue(CFSTR("NeverIdleFile"), kCFBooleanTrue, CFSTR("net.telestream.wmv.import"));
      CFPreferencesAppSynchronize(CFSTR("net.telestream.wmv.import"));
      
      QTMovie *movie = [[QTMovie alloc] initWithURL:url error:&error];
      LOG(@"got movie: (%@)%@, error: %@", [movie class], movie, error);
    
      // if we could open the movie
      if(movie) {
        // get the duration
        QTTime qt_duration = [movie duration];
        NSTimeInterval interval;
        QTGetTimeInterval(qt_duration, &interval);
        _duration = (long)interval;
        
        [movie release];
      }
      // NeverIdleFile of net.telestream.wmv.import YES
      CFPreferencesSetAppValue(CFSTR("NeverIdleFile"), NULL, CFSTR("net.telestream.wmv.import"));
      CFPreferencesAppSynchronize(CFSTR("net.telestream.wmv.import"));
    }
#else
    // use MPLAYER in identify mode to get the duration

    // find the mplayer in the bundle
    NSString *mplayerPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"mplayer" ofType:@""];
    LOG(@"Mplayer is at: %@", mplayerPath);

    // run it
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSString *pipeline = [NSString stringWithFormat:@"%@ -vo null -ao null -frames 0 -identify \"%@\" 2>/dev/null | grep \"^ID_LENGTH\" | sed -e s,ID_LENGTH=,, ", mplayerPath, [url path]];
    LOG(@"Pipeline command: %@", pipeline);
    
    NSArray *arguments = [NSArray arrayWithObjects:@"-c", pipeline, nil];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSFileHandle *file = [pipe fileHandleForReading];

    [task launch];

    NSData *data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _duration = (long)[string intValue];
    LOG(@"Got duration: %@, %d", string, _duration);
    
    [string release];
    [task release];
#endif // not USE_QTKIT_DURATIONS
  }  
#endif // READ_DURATIONS_AT_MENU
  
  [self _saveMetadata];
}

// Return the path of the XML metadata file
-(NSString *)_metadataXmlPath {
  NSURL *url = [NSURL URLWithString:[self mediaURL]];
  return [[[url path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xml"];
}

// Return the path of the cover art
-(NSString *)_coverArtPath {
  id result;
  // cover art finder
  
  NSArray *artCandidates;
  // get appropriate cover art
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
      result = cover;
    }
  } else {
    result = nil;
  }

  LOG(@"in -_covertArtPath: (%@)%@", [result class], result);
  return result;
}

@end
