//
//  ATVFContextMenu.h
//  ATVFiles
//
//  Created by Eric Steil III on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFMediaAsset.h"

extern const double ATVFilesVersionNumber;
extern const unsigned char ATVFilesVersionString[];

@interface ATVFContextMenu : BRMenuController {
  ATVFMediaAsset *_asset;
  NSMutableArray *_items;
}

-(ATVFContextMenu *)initWithScene:(BRRenderScene *)scene forAsset:(ATVFMediaAsset *)asset;

@end
