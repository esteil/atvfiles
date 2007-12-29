//
// ATVBRMetadataExtensions.m
// ATVFiles
//
// Created by Eric Steil III on 4/20/07.
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

#import "ATVBRMetadataExtensions.h"
#include <objc/objc-class.h>

@implementation BRMetadataPreviewController (ATVBRMetadataExtensions)
-(id)asset {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_asset");
  
  return *(id *)(((char *)self)+ret->ivar_offset);
}
@end

@implementation BRMetadataLayer (ATVBRMetadataExtensions)
-(NSArray *)metadataLabels {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_metadataLabels");
  
  return *(NSArray * *)(((char *)self)+ret->ivar_offset);
}

-(NSArray *)metadataObjects {
  Class klass = [self class];
  Ivar ret = class_getInstanceVariable(klass, "_metadataObjs");
  
  return *(NSArray * *)(((char *)self)+ret->ivar_offset);
}
@end
