//
//  NSString+formattedFileSize.h
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (FileSizeFormatting)
+ (NSString *)formattedFileSizeWithBytes:(NSNumber *)filesize;
@end
