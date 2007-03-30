//
//  ATVMediaAsset.h
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BRSimpleMediaAsset.h>
#import <BRMediaType.h>

@interface ATVMediaAsset : BRSimpleMediaAsset {
	BOOL _directory;
  NSString *_title, *_filename;
  BRMediaType *_mediaType;
  NSNumber *_filesize;
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
