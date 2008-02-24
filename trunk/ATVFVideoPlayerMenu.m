//
// ATVFVideoPlayerMenu.m
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

#import "ATVFVideoPlayerMenu.h"
#import "ATVFVideoPlayer.h"
#import "MenuMacros.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>
#import "ATVFileBrowserController.h"

@interface BRCenteredMenuController (FRCompat)
-(void)controlWillActivate;
-(void)controlWasActivated;
-(void)controlWillDeactivate;
-(void)controlWasDeactivated;
-(id)layoutManager;
-(void)setLayoutManager:(id)manager;
@end

@interface ATVFVideoPlayerMenu (Private)
-(void)_makeBackground;
@end

@interface ATVFVideoPlayer (Private)
-(void)_resetPassthrough;
@end

@implementation ATVFVideoPlayerMenu (FRCompat)

-(BRRenderScene *)scene {
  if([BRCenteredMenuController instancesRespondToSelector:@selector(scene)])
    return [super scene];
  else
    return [BRRenderScene sharedInstance];
}

-(float)heightForRow:(long)row {
  return 0.0f;
}

-(BOOL)rowSelectable:(long)row {
  return YES;
}

@end

@implementation ATVFVideoPlayerMenu

-(ATVFVideoPlayerMenu *)initWithScene:(BRRenderScene *)scene player:(BRMediaPlayer *)player controller:(BRVideoPlayerController *)controller {
  _player = [player retain];
  _controller = [controller retain];
  _items = nil;
  NSString *title = [[player media] title];
  NSString *primaryText = @"";
  
  if([(ATVFVideoPlayer *)_player currentPlaylistLength] > 1) {
    // in a playlist, so put an appropriate subtitle
    ATVFMediaAsset *currentAsset = [(ATVFVideoPlayer *)_player playlistAssetAtOffset:[(ATVFVideoPlayer *)_player currentPlaylistOffset]];
    primaryText = [NSString stringWithFormat:@"(%u/%u) %@", [(ATVFVideoPlayer *)_player currentPlaylistOffset] + 1, [(ATVFVideoPlayer *)_player currentPlaylistLength], [currentAsset title]];
  }

  // ATV needs this done *BEFORE* calling initWithScene: or else it doesn't render
  if(![SapphireFrontRowCompat usingFrontRow]) {
    [self setTitle:title];
    [self setPrimaryInfoText:primaryText];
  }
  
  if([BRCenteredMenuController instancesRespondToSelector:@selector(initWithScene:)])
    [super initWithScene:scene];
  else
    [super init];
  
  [self _buildMenu];
  [[self list] setDatasource:self];
  
  if([SapphireFrontRowCompat usingFrontRow]) 
    [[self list] setShowsWidgetBackingLayer:YES];
  else
    [[[self list] layer] setShowsWidgetBackingLayer:YES];

  [self _makeBackground];
  if([SapphireFrontRowCompat usingFrontRow]) {
    [self setTitle:title];
    [self setPrimaryInfoText:primaryText];
  }
  
  // and frontorw needs the title setting *AFTER*
  
  if([self respondsToSelector:@selector(layoutManager)]) {
    _realLayoutManager = [[self layoutManager] retain];
    [self setLayoutManager:self];
  } else {
    _realLayoutManager = nil;
  }
  
  _exiting = NO;
  
  return self;
}

// because the FrontRow one doesn't set a title, we have to build our own :(
// but we prefer the built in one on the apple tv
-(void)setTitle:(NSString *)title {
  if([SapphireFrontRowCompat usingFrontRow]) {
    if(_titleControl) {
      [_titleControl dealloc];
    }
    
    _titleControl = [SapphireFrontRowCompat newHeaderControlWithScene:[self scene]];
    [_titleControl setTitle:title];
    [_titleControl setFrame:[[BRThemeInfo sharedTheme] centeredMenuHeaderFrameForMasterFrame:[SapphireFrontRowCompat frameOfController:self]]];
    [self addControl:_titleControl];
  } else {
    [super setTitle:title];
  }
}

-(void)dealloc {
  [_player release];
  [_controller release];
  [_items release];
  [_titleControl release];
  [_backgroundControl release];
  [_realLayoutManager release];
  
  [super dealloc];
}

-(void)_doLayout {
  [super _doLayout];
}

-(void)_makeBackground {
  // set the background to black, which ATV needs but FR doesn't??
  if(![SapphireFrontRowCompat usingFrontRow]) {
    BRQuadLayer *blackLayer = [BRQuadLayer layerWithScene:[self scene]];
    [blackLayer setRedColor:0.0f greenColor:0.0f blueColor:0.0f];
    [blackLayer setFrame:[[[self scene] root] frame]];
    [blackLayer setAlphaValue:0.7f];
    [[self masterLayer] insertSublayer:blackLayer atIndex:0];
  }
  
  if(!_backgroundControl) {
    // and the blurred image
    _backgroundControl = (BRImageControl *)[SapphireFrontRowCompat newImageLayerWithImage:[_controller blurredVideoFrame] scene:[self scene]];
    
    // the above returns retained objects for 10.5/ATV2, but autoreleased on ATV1
    // so we have to retain it
    if(![SapphireFrontRowCompat usingFrontRow])
      [_backgroundControl retain];
  }
  
  // mess with the framing
  NSRect frame = [SapphireFrontRowCompat frameOfController:self];
  LOG(@"Frame: %@", NSStringFromRect(frame));
  
  // just scale it out
  // this is kinda hacky, and not at all apple-like, but eh i never could figure it out.
  //
  // what it really needs to do is a slight scale but keep aspect ratio centered on the screen.
  int xcenter = frame.size.width;
  int ycenter = frame.size.height;
  
  frame.size.width += (frame.size.width * 0.25);
  frame.size.height += (frame.size.height * 0.25);
  
  frame.origin.x -= (frame.size.width - xcenter) / 2.0;
  frame.origin.y -= (frame.size.height - ycenter) / 2.0;

  // set the blurred image size
  [_backgroundControl setFrame:frame];
  
  LOG(@"Frame: %@", NSStringFromRect(frame));
  
  [SapphireFrontRowCompat insertSublayer:_backgroundControl toControl:self atIndex:1];
}

// these are some macros to help in building the menu items, since it's so horribly repetitive
-(void)_buildMenu {
  [_items release];
  _items = [[NSMutableArray arrayWithCapacity:5] retain];

  BRAdornedMenuItemLayer *item = nil;
  BRMenuItemMediator *mediator = nil;
  NSString *title = nil;

  title = BRLocalizedString(@"Return to file listing", "Return to file listing");
  MENU_ITEM(title, @selector(_returnToFileListing), nil);
  [SapphireFrontRowCompat setRightIcon:[SapphireFrontRowCompat returnToImageForScene:[self scene]] forMenu:item];
  
  title = BRLocalizedString(@"Resume", "Resume playback");
  MENU_ITEM(title, @selector(_resumePlayback), nil);

  if(false && [(ATVFVideoPlayer *)_player hasSubtitles]) {
    if([(ATVFVideoPlayer *)_player subtitlesEnabled]) {
      // disable item
      title = BRLocalizedString(@"Disable Subtitles", @"Disable Subtitles");
      MENU_ITEM(title, @selector(_disableSubtitles), nil);
    } else {
      // enable item
      title = BRLocalizedString(@"Enable Subtitles", @"Enable Subtitles");
      MENU_ITEM(title, @selector(_enableSubtitles), nil);
    }
  }
  
  // playlist navigation
  if([(ATVFVideoPlayer *)_player currentPlaylistLength] > 1) {
    [[self list] addDividerAtIndex:[_items count] withLabel:@""];
    
    if([(ATVFVideoPlayer *)_player currentPlaylistOffset] > 0) {
      // previous enabled
      title = BRLocalizedString(@"Previous Entry", @"Previous Entry");
      MENU_ITEM(title, @selector(_previousPlaylistEntry), nil);
    }
    
    if([(ATVFVideoPlayer *)_player currentPlaylistOffset] < [(ATVFVideoPlayer *)_player currentPlaylistLength] - 1) {
      // next enabled
      title = BRLocalizedString(@"Next Entry", @"Next Entry");
      MENU_ITEM(title, @selector(_nextPlaylistEntry), nil);
    }
  }
}

// menu item stuff
-(void)itemSelected:(long)row {
  BRMenuItemMediator *item = [_items objectAtIndex:row];
  SEL selector = [item menuActionSelector];
  
  LOG(@"Menu item selected: %d, selector: %@", row, NSStringFromSelector([item menuActionSelector]));
  if(!selector) {
    LOG(@"Disabled menu item found!");
    [RUISoundHandler playSound:16];
    return;
  } else {
    // do it
    [self performSelector:selector];
  }
}

-(long)itemCount {
  return [_items count];
}

-(id)itemForRow:(long)row {
  BRAdornedMenuItemLayer *item = (BRAdornedMenuItemLayer *)[[_items objectAtIndex:row] menuItem];
  return item;
}

-(NSString *)titleForRow:(long)row {
  return [SapphireFrontRowCompat titleForMenu:(BRAdornedMenuItemLayer *)[[_items objectAtIndex:row] menuItem]];
}

-(long)rowForTitle:(NSString *)title {
  long i, count = [self itemCount];
  for(i = 0; i < count; i++) {
    if([title isEqualToString:[self titleForRow:i]]) 
      return i;
  }
  
  return -1;
}

// menu handlers
-(void)_resumePlayback {
  //[[super popAnimation] run];
  [[self stack] popToControllerWithLabel:@"atvfiles-video-player"];
  _exiting = NO;
}

-(void)_returnToFileListing {
  //[[super popAnimation] run];
  [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
  _exiting = YES;
}

-(void)_enableSubtitles {
  [(ATVFVideoPlayer *)_player setSubtitlesEnabled:YES];
  [[self stack] popToControllerWithLabel:@"atvfiles-video-player"];
}

-(void)_disableSubtitles {
  [(ATVFVideoPlayer *)_player setSubtitlesEnabled:NO];
  [[self stack] popToControllerWithLabel:@"atvfiles-video-player"];
}

-(void)_nextPlaylistEntry {
  LOG(@"_nextPlaylistEntry");
  [(ATVFVideoPlayer *)_player nextPlaylistEntry]; 
  [[self stack] popToControllerWithLabel:@"atvfiles-video-player"];
}

-(void)_previousPlaylistEntry {
  LOG(@"_previousPlaylistEntry");
  [(ATVFVideoPlayer *)_player previousPlaylistEntry]; 
  [[self stack] popToControllerWithLabel:@"atvfiles-video-player"];
}

// stack callbacks, etc.
-(void)willBePopped {
  [super willBePopped];
  
  if(![SapphireFrontRowCompat usingFrontRow])
    [[super popAnimation] run];
}

-(void)wasPopped {
  if(!_exiting)
    [(ATVFVideoPlayer *)_player play];
  else
    [(ATVFVideoPlayer *)_player _resetPassthrough];

  [super wasPopped];
}

-(id)popAnimation {
  id r = [super popAnimation];
  LOG(@"in ATVFVideoPlayerMenu popAnimation, returning: (%@)%@", [r class], r);
  return r;
}

-(id)pushAnimation {
  id r = [super pushAnimation];
  LOG(@"in ATVFVideoPlayerMenu pushAnimation, returning: (%@)%@", [r class], r);
  return r;
}

// Layout-related items

// CALayoutManager informal protocol
// This method lays out the background and title after the real layout manager lays out everything.
-(void)layoutSublayersOfLayer:(id)layer {
  LOG(@"In layoutSublayersOfLayer:");
  if(_realLayoutManager)
    [_realLayoutManager layoutSublayersOfLayer:layer];
  
  [self _makeBackground];
  if(_titleControl) [_titleControl setFrame:[[BRThemeInfo sharedTheme] centeredMenuHeaderFrameForMasterFrame:[SapphireFrontRowCompat frameOfController:self]]];
}

-(void)controlWasDeactivated {
  LOG(@"-controlWasDeactivated");
  if(!_exiting)
    [(ATVFVideoPlayer *)_player play];
  else
    [(ATVFVideoPlayer *)_player _resetPassthrough];

  [super controlWasDeactivated];
}

-(void)controlWillActivate {
  [super controlWillActivate];
  _exiting = NO;
}

-(void)willBePushed {
  [super willBePushed];
  _exiting = NO;
}

@end
