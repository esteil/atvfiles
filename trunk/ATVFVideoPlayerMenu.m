//
//  ATVFVideoPlayerMenu.m
//  ATVFiles
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideoPlayerMenu.h"
#import "ATVFVideoPlayer.h"
#import "MenuMacros.h"
#import "SapphireFrontRowCompat.h"

@interface ATVFVideoPlayerMenu (Private)
-(void)_makeBackground;
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

-(ATVFVideoPlayerMenu *)initWithScene:(BRRenderScene *)scene player:(BRMediaPlayer *)player controller:(ATVFVideoPlayerController *)controller {
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
  
  return self;
}

// because the FrontRow one doesn't set a title, we have to build our own :(
// but we prefer the built in one on the apple tv
-(void)setTitle:(NSString *)title {
  if([SapphireFrontRowCompat usingFrontRow]) {
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
  
  // and the blurred image
  BRImageLayer *backgroundImage = [SapphireFrontRowCompat newImageLayerWithImage:[_controller blurredVideoFrame] scene:[self scene]];
  
  // mess with the framing
  NSRect frame = [SapphireFrontRowCompat frameOfController:self];
  
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
  [backgroundImage setFrame:frame];
  
  [SapphireFrontRowCompat insertSublayer:backgroundImage toControl:self atIndex:1];
}

// these are some macros to help in building the menu items, since it's so horribly repetitive
-(void)_buildMenu {
  [_items release];
  _items = [[NSMutableArray arrayWithCapacity:5] retain];

  BRAdornedMenuItemLayer *item = nil;
  BRMenuItemMediator *mediator = nil;
  NSString *title = nil;

  title = BRLocalizedString(@"Resume", "Resume playback");
  MENU_ITEM(title, @selector(_resumePlayback), nil);

  title = BRLocalizedString(@"Return to file listing", "Return to file listing");
  MENU_ITEM(title, @selector(_returnToFileListing), nil);
  [SapphireFrontRowCompat setRightIcon:[SapphireFrontRowCompat returnToImageForScene:[self scene]] forMenu:item];
  
  if(![SapphireFrontRowCompat usingFrontRow] && [(ATVFVideoPlayer *)_player hasSubtitles]) {
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
    [[self list] setDividerIndex:[_items count]];
    
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
  [[self stack] popToControllerOfClass:NSClassFromString(@"ATVFVideoPlayerController")];
}

-(void)_returnToFileListing {
  [[self stack] popToControllerOfClass:NSClassFromString(@"ATVFileBrowserController")];
}

-(void)_enableSubtitles {
  [(ATVFVideoPlayer *)_player setSubtitlesEnabled:YES];
  [[self stack] popToControllerOfClass:NSClassFromString(@"ATVFVideoPlayerController")];
}

-(void)_disableSubtitles {
  [(ATVFVideoPlayer *)_player setSubtitlesEnabled:NO];
  [[self stack] popToControllerOfClass:NSClassFromString(@"ATVFVideoPlayerController")];
}

-(void)_nextPlaylistEntry {
  LOG(@"_nextPlaylistEntry");
  [(ATVFVideoPlayer *)_player nextPlaylistEntry]; 
  [[self stack] popToControllerOfClass:NSClassFromString(@"ATVFVideoPlayerController")];
}

-(void)_previousPlaylistEntry {
  LOG(@"_previousPlaylistEntry");
  [(ATVFVideoPlayer *)_player previousPlaylistEntry]; 
  [[self stack] popToControllerOfClass:NSClassFromString(@"ATVFVideoPlayerController")];
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
@end
