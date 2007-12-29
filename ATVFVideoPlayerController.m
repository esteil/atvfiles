//
// ATVFVideoPlayerController.m
// ATVFiles
//
// Created by Eric Steil III on 10/21/07.
// Copyright (C) 2007 Eric Steil III
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

#import "ATVFVideoPlayerController.h"
#import "config.h"
#import "ATVFVideoPlayerMenu.h"
#import "SapphireFrontRowCompat.h"
#import "ATVFVideoPlayer.h"

@interface ATVFVideoPlayerController (FRCompat)
-(void)_removeTransportControl;
-(void)_addTransportControl;
@end

@implementation ATVFVideoPlayerController

// Handle menu keypress, and ignore everything else.
-(BOOL)brEventAction:(BREvent *)event {
  //LOG(@"In -brEventAction: (%@)%@", [event class], event);
  
  if([[self stack] peekController] != self)
    return NO;
    
  switch([event pageUsageHash]) {
#ifdef PLAYBACK_CONTEXT_MENU
    case kBREventTapMenu: // ATV
    case BREVENT_HASH(12, 134): // 10.5
      ; // won't compile without this??!??
      ATVFVideoPlayerMenu *menu;
      
      if([self respondsToSelector:@selector(scene)]) // ATV
        menu = [[[ATVFVideoPlayerMenu alloc] initWithScene:[self scene] player:[self player] controller:self] autorelease];
      else // 10.5
        menu = [[[ATVFVideoPlayerMenu alloc] initWithScene:[BRRenderScene sharedInstance] player:[self player] controller:self] autorelease];

      [menu addLabel:@"net.ericiii.atvfiles.playback-context-menu"];
      
      if([SapphireFrontRowCompat usingFrontRow])
        [self _removeTransportControl];
      else
        [self _removeTransportLayer];
      
      [(ATVFVideoPlayer *)[self player] pause];
      [[self stack] pushController:menu];
      
      return YES;
      break;

      // context menu
      // BRListControl *list = [self list];
      // ATVFMediaAsset *asset = [_contents mediaForIndex:[list selection]];

      // LOG(@"Context menu button pressed!");
      // LOG(@" List: (%@)%@", [list class], list);
      // LOG(@"  Selected: %d", [list selection]);
      // 
      // LOG(@" Selected asset: (%@)%@ <%@>", [asset class], asset, [asset mediaURL]);
      // 
      // ATVFContextMenu *contextMenu = [[[ATVFContextMenu alloc] initWithScene:[self scene] forAsset:asset] autorelease];
      // [contextMenu setListIcon:[self listIcon]];
      // [[self stack] pushController:contextMenu];
      // 
      // return YES;
      // break;
#endif
  }
  
  return [super brEventAction:event];
}

-(void)wasExhumedByPoppingController:(id)controller {
  [super wasExhumedByPoppingController:controller];
  
  // Resume playback if it's our option dialog
  if([controller isLabelled:@"net.ericiii.atvfiles.playback-context-menu"]) {
    [(BRMediaPlayer *)[self player] resume];
    // [self _removeTransportLayer];
    
    if(![SapphireFrontRowCompat usingFrontRow])
      [[controller popAnimation] run];

    if([SapphireFrontRowCompat usingFrontRow])
      [self _addTransportControl];
    else
      [self _addTransportLayer];
  }
}

-(id)buryAnimationWithPushingController:(BRLayerController *)controller {
  id r = nil;
  id r2 = nil;
  
  if(![SapphireFrontRowCompat usingFrontRow])
    r = [controller pushAnimation];

  r2 = [super buryAnimationWithPushingController:controller];
  
  LOG(@"In -buryAnimationWithPushingController, controller says (%@)%@, super says (%@)%@", [r class], r, [r2 class], r2);
  
  return r2;
}

-(void)wasBuriedByPushingController:(BRLayerController *)controller {
  [super wasBuriedByPushingController:controller];

  if([controller isLabelled:@"net.ericiii.atvfiles.playback-context-menu"]) {
    // [[self buryAnimationWithPushingController:controller] run];
    if(![SapphireFrontRowCompat usingFrontRow]) {
      [[controller pushAnimation] run];
      [self _removeMasterLayer];
    }
  }
}

@end
