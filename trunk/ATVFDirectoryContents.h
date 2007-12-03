//
//  ATVFDirectoryContents.h
//  ATVFiles
//
//  This is a combined data store/menu list provider for a specific directory.
// 
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFMediaAsset.h"
#import "ATVFPlaylistAsset.h"

@interface ATVFDirectoryContents : NSObject {
	NSString *_directory;
  NSMutableArray *_menuItems;
  NSMutableArray *_assets;
  id _scene;
  BOOL _includeDirectories;
  BOOL _includePlaylists;
}

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory;
-(id)initWithScene:(id)scene forDirectory:(NSString *)directory includeDirectories:(BOOL)includeDirectories playlists:(BOOL)includePlaylists;

-(id)mediaForIndex:(long)index;
-(void)refreshContents;

- (long)itemCount;
- (BRRenderLayer *)itemForRow:(long)row;
- (long)rowForTitle:(NSString *)title;
- (NSString *)titleForRow:(long)row;

-(NSArray *)assets;

@end
