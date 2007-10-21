//
//  ATVFVideoPlayerController.m
//  ATVFiles
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideoPlayerController.h"

@implementation ATVFVideoPlayerController

// Handle menu keypress, and ignore everything else.
-(BOOL)brEventAction:(BREvent *)event {
  if([[self stack] peekController] != self)
    return NO;
    
  switch([event pageUsageHash]) {
#ifdef PLAYBACK_CONTEXT_MENU
    case kBREventTapMenu:
      LOG(@"Bringing up playback context menu");
      
      BROptionDialog *dialog = [[[BROptionDialog alloc] initWithScene:[self scene]] autorelease];
      [dialog addLabel:@"net.ericiii.atvfiles.playback-context-menu"];
      
      [dialog setTitle:@"This is a dialog title"];
      [dialog setPrimaryInfoText:@""];
      
      [dialog addOptionText:@"Return to video"];
      [dialog addOptionText:@"Return to menu"];

      [dialog addOptionText:@"Enable Subtitles"];
      [dialog addOptionText:@"Previous Track"];
      [dialog addOptionText:@"Next Track"];
      
      
      [[self stack] pushController:dialog];
      
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
  LOG(@"In wasExhumedByPoppingController: (%@)%@", [controller class], controller);
  
  [super wasExhumedByPoppingController:controller];
  
  // Resume playback if it's our option dialog
  if([controller isLabelled:@"net.ericiii.atvfiles.playback-context-menu"]) {
    [[self player] play];
  }
}

@end
