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

@end
