//
//  ATVDirectoryContents.h
//  ATVFiles
//
//  This is a combined data store/menu list provider for a specific directory.
// 
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BRSimpleMediaAsset.h>
#import <BRTextMenuItemLayer.h>
#import <BRMediaType.h>
#import "ATVMediaAsset.h"

@interface ATVDirectoryContents : NSObject {
	NSString *_directory;
  NSMutableArray *_files;
  NSMutableArray *_menuItems;
  NSMutableArray *_assets;
  id _scene;
}

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory;
-(id)mediaForIndex:(long)index;
-(void)refreshContents;

- (long)itemCount;
- (id)itemForRow:(long)row;
- (long)rowForTitle:(id)title;
- (id)titleForRow:(long)row;

@end
