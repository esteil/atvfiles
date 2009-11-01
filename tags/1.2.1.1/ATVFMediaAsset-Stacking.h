//
//  ATVFMediaAsset-Stacking.h
//  ATVFiles
//
//  Created by Eric Steil III on 10/25/08.
//  Copyright 2008 BetaNews, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ATVFMediaAsset.h"

@interface ATVFMediaAsset (Stacking)

/**
 * Returns the base media URL, which is either mediaURL or
 * the first element of the stack.
 */
-(NSString *)baseMediaURL;

-(BOOL)_prepareStack:(NSError **)error;
-(BOOL)_needsStacking;
-(BOOL)_removeStackMovie;
-(NSString *)_stackFileURL;

@end
