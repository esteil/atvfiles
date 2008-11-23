//
// ATVFMusicNowPlayingController.h
// ATVFiles
//
// Created by Eric Steil III on 2/15/08.
// Copyright 2008 Eric Steil III. All rights reserved.
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

@interface BRMusicNowPlayingControl
-(Class)class;
-(void)release;
+(id)control;
-(void)setFrame:(NSRect)frame;
-(void)retain;
@end

/*
 * This class is for Leopard/ATV2 only.  It will not work on ATV1.1.
 */
@interface ATVFMusicNowPlayingController : BRLayerController {
  char padding[128];
  
  BRMusicPlayer *_player;
  BRMusicNowPlayingControl *_nowPlayingControl;
}

-(ATVFMusicNowPlayingController *)initWithPlayer:(BRMusicPlayer *)player;

-(void)setPlayer:(BRMusicPlayer *)player;
-(BRMusicPlayer *)player;

@end
