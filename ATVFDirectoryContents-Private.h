/*
 *  ATVFDirectoryContents-Private.h
 *  ATVFiles
 *
 *  Created by Eric Steil III on 12/15/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#import <BackRow/BackRow.h>
#import "ATVFDirectoryContents.h"

@interface ATVFDirectoryContents (Private)
-(NSString *)_getStackInfo:(NSString *)filename index:(int *)index;
-(BRBitmapTexture *)_stackIcon;
-(BRBitmapTexture *)_playlistIcon;
-(BRBitmapTexture *)_textureFromURL:(NSURL *)url;
@end

