//
//  ATVMediaAsset.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVMediaAsset.h"


@implementation ATVMediaAsset

-(BOOL)isDirectory {
	return _directory;
}

-(void)setDirectory:(BOOL)directory {
	_directory = directory;
}

-(NSComparisonResult)compareTitleWith:(id)otherAsset {
  return [[self title] compare:[otherAsset title] options:NSCaseInsensitiveSearch];
}

-(NSString *)title {
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
  LOG(@"in -setBookmarkTimeInMS:%d", fp8);
  [super setBookmarkTimeInMS:fp8];
}

-(void)setBookmarkTimeInSeconds:(unsigned int)fp8 {
  LOG(@"in -setBookmarkTimeInSeconds:%d", fp8);
  [super setBookmarkTimeInSeconds:fp8];
}

-(void)setHasBeenPlayed:(BOOL)fp8 {
  LOG(@"in -setHasBeenPlayed:%d", fp8);
  [super setHasBeenPlayed:fp8];
}

-(id)previewURL {
  id result = [super previewURL];
  LOG(@"in -previewURL: (%@)%@", [result class], result);
  return result;
}

-(long)duration {
  long result = 0;
  
  if([self isDirectory]) {
    result = 0;
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
        _duration = [movie duration];
        NSTimeInterval interval;
        QTGetTimeInterval(_duration, &interval);
        result = (long)interval;
      }
    }
  }
  
  LOG(@"in -duration: %d", result);
  return result;
}

@end
