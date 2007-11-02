//
//  ATVFVideoPlayerController.m
//  ATVFiles
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideoPlayerController.h"
#import "config.h"
#import "ATVFVideoPlayerMenu.h"

@implementation ATVFVideoPlayerController

// Handle menu keypress, and ignore everything else.
-(BOOL)brEventAction:(BREvent *)event {
  if([[self stack] peekController] != self)
    return NO;
    
  switch([event pageUsageHash]) {
#ifdef PLAYBACK_CONTEXT_MENU
    case kBREventTapMenu:
      ; // won't compile without this??!??
      ATVFVideoPlayerMenu *menu = [[[ATVFVideoPlayerMenu alloc] initWithScene:[self scene] player:[self player] controller:self] autorelease];
      [menu addLabel:@"net.ericiii.atvfiles.playback-context-menu"];
      [self _removeTransportLayer];
      [[self player] pause];
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
    [[controller popAnimation] run];
    [self _addTransportLayer];
  }
}

-(id)buryAnimationWithPushingController:(BRLayerController *)controller {
  id r = [controller pushAnimation];
  id r2 = [super buryAnimationWithPushingController:controller];
  
  LOG(@"In -buryAnimationWithPushingController, controller says (%@)%@, super says (%@)%@", [r class], r, [r2 class], r2);
  
  return r2;
}

-(void)wasBuriedByPushingController:(BRLayerController *)controller {
  [super wasBuriedByPushingController:controller];

  if([controller isLabelled:@"net.ericiii.atvfiles.playback-context-menu"]) {
    // [[self buryAnimationWithPushingController:controller] run];
    [[controller pushAnimation] run];
    [self _removeMasterLayer];
  }
}

@end
