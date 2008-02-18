//
// BRMusicNowPlayingController+SetPlayer.m
// ATVFiles
//
// Created by Eric Steil III on 6/29/07.
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

#import "BRMusicNowPlayingController+SetPlayer.h"
#include <objc/objc-class.h>

@implementation BRMusicNowPlayingMonitor (ATVFSetPlayer)

-(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
  
	return *(BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
}

-(void)setPlayer:(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
	BRMusicPlayer * *thePlayer = (BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
	
	[*thePlayer release];
	*thePlayer = [player retain];
}

@end

@implementation BRMusicNowPlayingController (ATVFSetPlayer)

-(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");

	return *(BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
}

-(void)setPlayer:(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
	BRMusicPlayer * *thePlayer = (BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
	
	[*thePlayer release];
	*thePlayer = [player retain];
  
  [self _subscribeToPlayerNotifications];
}

@end
