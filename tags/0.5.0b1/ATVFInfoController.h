//
//  ATVFInfoController.h
//  ATVFiles
//
//  Created by Eric Steil III on 9/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import <ATVFMediaAsset.h>

@interface ATVFInfoController : BRLayerController {
  BRHeaderControl *_header;
  BRVerticalScrollControl *_document;
  ATVFMediaAsset *_asset;
}

-(void)doLayout;
-(void)setAsset:(ATVFMediaAsset *)asset;
-(ATVFMediaAsset *)asset;

@end
