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

#import "ATVFMusicNowPlayingController.h"
#include <objc/objc-class.h>
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>
#import "BackRowCommon.h"

@interface BRLayerController (compat)
-(void)controlWillActivate;
-(void)controlWasActivated;
-(void)removeControl:(id)control;
-(void)setLayoutManager:(id)manager;
@end

@interface BRMusicNowPlayingControl (ATVFPlayerAccess)
-(BRMusicPlayer *)ATVF_getPlayer;
-(void)ATVF_setPlayer:(BRMusicPlayer *)player;
@end

@implementation BRMusicNowPlayingControl (ATVFPlayerAccess)
-(BRMusicPlayer *)ATVF_getPlayer {
  Class myClass = [self class];
  Ivar ret = class_getInstanceVariable(myClass, "_player");
  
  return *(BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);
}

-(void)ATVF_setPlayer:(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
	BRMusicPlayer * *thePlayer = (BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
	
	[*thePlayer release];
	*thePlayer = [player retain];
}
@end

@interface BRMusicNowPlayingControl (compat)
-(void)setPlayer:(BRMusicPlayer *)player;
@end

@implementation ATVFMusicNowPlayingController

-(ATVFMusicNowPlayingController *)initWithPlayer:(BRMusicPlayer *)player {
  [self init];
  [self setPlayer:player];
  return self;
}

-(ATVFMusicNowPlayingController *)init {
  [super init];

  _nowPlayingControl = [BRMusicNowPlayingControl control];
  [_nowPlayingControl retain];
  [self addControl:_nowPlayingControl];
  
  [self setLayoutManager:self];
  
  return self;
}

-(void)dealloc {
  [_player release];
  [_nowPlayingControl release];
  [_eventHandler release];
  
  [super dealloc];
}

-(void)setPlayer:(BRMusicPlayer *)player {
  LOG_MARKER;
  LOG(@"Setting player: (%@)%@", [player class], player);
  
  [_player release];
  _player = [player retain];
  if([_nowPlayingControl respondsToSelector:@selector(setPlayer:)]) {
    LOG(@"Using setPlayer:");
    [_nowPlayingControl setPlayer:_player];
  } else {
    LOG(@"Using ATVF_setPlayer");
    [_nowPlayingControl ATVF_setPlayer:_player];
  }
  
  [_eventHandler release];
  _eventHandler = nil;
  
  if(NSClassFromString(@"BRMediaPlayerEventHandler") != nil) {
    LOG(@"Initializing BRMediaPlayerEventHandler");
    _eventHandler = [BRMediaPlayerEventHandler handlerWithPlayer:_player];
    [_eventHandler retain];
    LOG(@"Got (%@)%@", [_eventHandler class], _eventHandler);
  }
}

-(BRMusicPlayer *)player {
  return _player;
}

// logging shim
-(BOOL)brEventAction:(BREvent *)event {
  BOOL ret = NO;
  
  // override menu
  uint32_t pageUsageHash = ([event page] << 16 | [event usage]);
  if(pageUsageHash == kBREventTapMenu) {
    LOG(@"Menu pressed, returning to menu");
    [[self stack] popController];
    ret = YES;
  } else if(pageUsageHash == kBREventHoldMenu) {
    LOG(@"Menu held, stopping playback.");
    [_player stop];
    ret = YES;
  } else if(_eventHandler != nil) {
    LOG(@"Forwarding event to _eventHandler");
    ret = [_eventHandler brEventAction:event];
#if 0
  } else if(pageUsageHash == kBREventTapPlayPause) {
    if([_player playerState] == kBRMediaPlayerStatePaused) [_player play];
    else [_player pause];
    ret = YES;
  } else if(pageUsageHash == kBREventTapRight) {
    LOG(@"kBREventTapRight");
    [_player rightArrowClick];
    ret = YES;
  } else if(pageUsageHash == kBREventTapLeft) {
    LOG(@"kBREventTapLeft");
    [_player leftArrowClick];
    ret = YES;
  } else if(pageUsageHash == kBREventHoldLeft) {
    LOG(@"kBREventHoldLeft");
    [_player pressAndHoldLeftArrow];
    ret = YES;
  } else if(pageUsageHash == kBREventHoldRight) {
    LOG(@"kBREventHoldRight");
    [_player pressAndHoldRightArrow];
    ret = YES;
#endif
  } else {
    ret = [super brEventAction:event];
    LOG(@"Event: %d -> %@", ret, event);
  }
  
  return ret;
}

// This is where the layout magic happens (ATV2).
-(void)layoutSublayers {
  [_nowPlayingControl setFrame:[SapphireFrontRowCompat frameOfController:self]];
}

// CALayoutManager informal protocol
// This method just calls the ATV2 layout method for Leopard, when set as layout manager.
-(void)layoutSublayersOfLayer:(id)layer {
  LOG(@"In layoutSublayersOfLayer:");
  [self layoutSublayers];
}
@end
