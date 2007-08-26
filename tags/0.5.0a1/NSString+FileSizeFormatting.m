//
//  NSString+formattedFileSize.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSString+FileSizeFormatting.h"


@implementation NSString (FileSizeFormatting)

+(NSString *)formattedFileSizeWithBytes:(NSNumber *)filesize {
  static NSString *suffix[] = {
    @"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB"
  };
  
  int i, c = 7; // c is number of items in suffix[]
  float size = [filesize floatValue];
  
  for(i = 0 ; i < c && size >= 1024; i++) {
    size = size / 1024;
  }
  
  return [NSString stringWithFormat:@"%.1f%@", size, suffix[i]];
}

@end
