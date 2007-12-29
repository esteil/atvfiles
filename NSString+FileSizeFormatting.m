//
// NSString+formattedFileSize.m
// ATVFiles
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
  
  return [NSString stringWithFormat:@"%.01f%@", size, suffix[i]];
}

@end
