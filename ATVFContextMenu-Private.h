/*
 *  ATVFContextMenu-Private.h
 *  ATVFiles
 *
 *  Created by Eric Steil III on 8/24/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#import "ATVFContextMenu.h"

@interface ATVFContextMenu (Private)
-(void)_buildContextMenu;
-(BOOL)_deleteFileWithMetadata:(NSString *)path;
@end

