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
  NSLog(@"in setBookmarkTimeInMS:%d", fp8);
  [super setBookmarkTimeInMS:fp8];
}

-(void)setBookmarkTimeInSeconds:(unsigned int)fp8 {
  NSLog(@"in setBookmarkTimeInSeconds:%d", fp8);
  [super setBookmarkTimeInSeconds:fp8];
}

-(void)setHasBeenPlayed:(BOOL)fp8 {
  NSLog(@"in -setHasBeenPlayed:%d", fp8);
  [super setHasBeenPlayed:fp8];
}

@end
