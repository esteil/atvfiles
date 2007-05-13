//
//  ATVMediaAsset.h
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <BackRow/BackRow.h>

// from BackRow framework
CGImageRef CreateImageForURL(CFURLRef imageURL); 

@interface ATVMediaAsset : BRSimpleMediaAsset {
	BOOL _directory;
  NSString *_title, *_filename;
  BRMediaType *_mediaType;
  NSNumber *_filesize;
  // NSDictionary *_metadata;
  
  BOOL _needsMetadataLoad;
  NSDate *_lastFileMod; // mtime of file when we last saw it
  NSDate *_lastFileMetadataMod; // mtime of metadata file when we last saw it

  long _mediaID;
  NSString *_artist;
  NSString *_mediaSummary;
  NSString *_mediaDescription;
  NSString *_copyright;
  long _duration;
  long _performanceCount;
  NSMutableArray *_cast;
  NSMutableArray *_directors;
  NSMutableArray *_producers;
  NSDate *_dateAcquired;
  NSDate *_datePublished;
  BRGenre *_primaryGenre;
  NSMutableArray *_genres;
  NSString *_seriesName;
  NSString *_broadcaster;
  NSString *_episodeNumber;
  unsigned int _season;
  unsigned int _episode;
  float _userStarRating;
  NSString *_rating;
  float _starRating;
  NSString *_publisher;
  NSString *_composer;
  long _bookmarkTime;
}

-(BOOL)isDirectory;
-(void)setDirectory:(BOOL)directory;

-(NSComparisonResult)compareTitleWith:(id)otherAsset;

-(NSString *)title;
-(void)setTitle:(NSString *)title;

-(BRMediaType *)mediaType;
-(void)setMediaType:(BRMediaType *)mediaType;

-(NSString *)filename;
-(void)setFilename:(NSString *)filename;

-(NSNumber *)filesize;
-(void)setFilesize:(NSNumber *)filesize;

@end
