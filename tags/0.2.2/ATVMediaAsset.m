//
//  ATVMediaAsset.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVMediaAsset.h"
#import "ATVFilesAppliance.h"
#import "NSArray+Globbing.h"

@implementation ATVMediaAsset

-(id)init {
  LOG(@"In ATVMediaAsset -init");
  
  return [super init];
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
  
  if([self isDirectory] || ![[NSUserDefaults standardUserDefaults] boolForKey:kATVPrefEnableFileDurations]) {
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
  unsigned int result = [super bookmarkTimeInMS];
  LOG(@"in -bookmarkTimeInMS: %d", result);
  return result;
}

-(void)incrementPerformanceCount {
  LOG(@"in -incrementPerformanceCount");
  [super incrementPerformanceCount];
}

-(void)incrementPerformanceOrSkipCount:(unsigned int)fp8 {
  LOG(@"in -incrementPerformanceOrSkipCount:%d", fp8);
  [super incrementPerformanceOrSkipCount:fp8];
}

-(long)performanceCount {
  long result = [super performanceCount];
  LOG(@"in -performanceCount: %d", result);
  return result;
}

@end
