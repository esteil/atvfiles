//
//  ATVBRMetadataExtensions.m
//  ATVFiles
//
//  Created by Eric Steil III on 4/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
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
