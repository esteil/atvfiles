//
//  ATVFVideoPlayerMenu.h
//  ATVFiles
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "config.h"
#import <BackRow/BackRow.h>
#import <ATVFVideoPlayerController.h>
#import <SapphireCenteredMenuController.h>

@interface ATVFVideoPlayerMenu : SapphireCenteredMenuController {
  ATVFVideoPlayerController *_controller;
  BRMediaPlayer *_player;
  NSMutableArray *_items;
}

-(ATVFVideoPlayerMenu *)initWithScene:(BRRenderScene *)scene player:(BRMediaPlayer *)player controller:(ATVFVideoPlayerController *)controller;

-(void)_doLayout;
-(void)_buildMenu;

// BRMenuListItemProvider
-(long)itemCount;
-(id)itemForRow:(long)row;
-(long)rowForTitle:(NSString *)title;
-(NSString *)titleForRow:(long)row;

@end
