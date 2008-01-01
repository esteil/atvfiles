//
// ATVFDirectoryContents.h
// ATVFiles
//
// This is a combined data store/menu list provider for a specific directory.
// 
// Created by Eric Steil III on 3/29/07.
// Copyright (C) 2007-2008 Eric Steil III
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
  
  long _separatorIndex;
  long _defaultIndex;
}

-(id)initWithScene:(id)scene forDirectory:(NSString *)directory;
-(id)initWithScene:(id)scene forDirectory:(NSString *)directory includeDirectories:(BOOL)includeDirectories playlists:(BOOL)includePlaylists;

-(id)mediaForIndex:(long)index;
-(void)refreshContents;

-(long)separatorIndex;
-(long)defaultIndex;

// menu list protocol stuff
- (long)itemCount;
- (id<BRMenuItemLayer>)itemForRow:(long)row;
- (long)rowForTitle:(NSString *)title;
- (NSString *)titleForRow:(long)row;

-(NSArray *)assets;

@end
