//
// ATVFVideoPlayerMenu.h
// ATVFiles
//
// Created by Eric Steil III on 10/21/07.
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
#import "config.h"
#import <BackRow/BackRow.h>
#import <ATVFVideoPlayerController.h>
#import <SapphireCompatClasses/SapphireCenteredMenuController.h>

@interface ATVFVideoPlayerMenu : BRCenteredMenuController {
  int padding[16]; // padding
  
  ATVFVideoPlayerController *_controller;
  BRMediaPlayer *_player;
  NSMutableArray *_items;
  BRHeaderControl *_titleControl;
  BRImageControl *_backgroundControl;
  
  // so we can chain onto it
  id _realLayoutManager;
  
  // just a flag, if this is false playback will be resumed when deactivating.
  BOOL _exiting;
}

-(ATVFVideoPlayerMenu *)initWithScene:(BRRenderScene *)scene player:(BRMediaPlayer *)player controller:(BRVideoPlayerController *)controller;

-(void)_doLayout;
-(void)_buildMenu;

// BRMenuListItemProvider
-(long)itemCount;
-(id)itemForRow:(long)row;
-(long)rowForTitle:(NSString *)title;
-(NSString *)titleForRow:(long)row;

@end
