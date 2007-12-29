//
// ATVFMediaAsset.h
// ATVFiles
//
// This represents a single "asset," that is an item that can be played
// back or otherwise viewed (i.e. a media file, a stack, or a folder).
//
// Created by Eric Steil III on 3/29/07.
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
#import <QTKit/QTKit.h>
#import <BackRow/BackRow.h>

#define kATVFAssetTypeFile @"file"

// from BackRow framework
CGImageRef CreateImageForURL(CFURLRef imageURL); 

@interface ATVFMediaAsset : BRSimpleMediaAsset {
	BOOL _directory;
  BOOL _isVolume;
  BOOL _isEjectable;
  BOOL _isRemovable;
  
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
  NSString *_primaryGenreString;
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
  
  NSMutableArray *_stackContents;
  BOOL _needsMetadataSave;
  
  BOOL _isTemporary; // does this one get saved?
  NSString *_assetType;
  
  NSString *_coverArtURL;
  NSString *_coverArtImageName;
}

-(id)coverArt;
-(id)coverArtNoDefault;

-(long)mediaID;

-(BOOL)isDirectory;
-(void)setDirectory:(BOOL)directory;

-(BOOL)isVolume;
-(void)setVolume:(BOOL)volume;

-(BOOL)isEjectable;
-(void)setEjectable:(BOOL)ejectable;

-(BOOL)isRemovable;
-(void)setRemovable:(BOOL)removable;

-(NSComparisonResult)compareTitleWith:(id)otherAsset;

-(NSString *)title;
-(void)setTitle:(NSString *)title;

-(BRMediaType *)mediaType;
-(void)setMediaType:(BRMediaType *)mediaType;

-(NSString *)filename;
-(void)setFilename:(NSString *)filename;

-(NSNumber *)filesize;
-(void)setFilesize:(NSNumber *)filesize;

-(void)setDuration:(long)duration;

-(BOOL)isTemporary;
-(void)setTemporary:(BOOL)temporary;

-(NSString *)primaryGenreString;

// stack stuff
-(void)addURLToStack:(NSURL *)URL;
-(NSArray *)stackContents;
-(BOOL)isStack;

// other
-(BOOL)isPlaylist;

@end
