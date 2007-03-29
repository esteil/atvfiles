//
//  ATVMediaAsset.h
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BRSimpleMediaAsset.h>

@interface ATVMediaAsset : BRSimpleMediaAsset {
	BOOL _directory;
}

-(BOOL)isDirectory;
-(void)setDirectory:(BOOL)directory;

@end
