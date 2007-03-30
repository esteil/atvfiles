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
  NSString *_title;
  BRMediaType *_mediaType;
}

-(BOOL)isDirectory;
-(void)setDirectory:(BOOL)directory;

-(NSComparisonResult)compareTitleWith:(id)otherAsset;

-(NSString *)title;
-(void)setTitle:(NSString *)title;

-(BRMediaType *)mediaType;
-(void)setMediaType:(BRMediaType *)mediaType;

@end
