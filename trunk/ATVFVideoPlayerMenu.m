//
//  ATVFVideoPlayerMenu.m
//  ATVFiles
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideoPlayerMenu.h"
#import "ATVFVideoPlayer.h"

@implementation ATVFVideoPlayerMenu

-(ATVFVideoPlayerMenu *)initWithScene:(BRRenderScene *)scene player:(BRMediaPlayer *)player controller:(ATVFVideoPlayerController *)controller {
  _player = [player retain];
  _controller = [controller retain];
  _items = nil;
  
  // [self setTitle:BRLocalizedString(@"TITLE?", "Title?")];
  [super initWithScene:scene];
  [self _buildMenu];
  [[self list] setDatasource:self];
  
  return self;
}

-(void)dealloc {
  [_player release];
  [_controller release];
  [_items release];
  
  [super dealloc];
}

-(void)_doLayout {
  [super _doLayout];
  
  // set the background
  BRQuadLayer *blackLayer = [BRQuadLayer layerWithScene:[self scene]];
  [blackLayer setRedColor:0.0f greenColor:0.0f blueColor:0.0f];
  [blackLayer setFrame:[[[self scene] root] frame]];
  [[self masterLayer] insertSublayer:blackLayer atIndex:0];
  
  // and the blurred image
  BRTexture *backgroundTexture = [_controller blurredVideoFrame];
  const struct BRTextureInfo *textureInfo = [backgroundTexture textureInfo];
  
  BRImageLayer *backgroundImage = [BRImageLayer layerWithScene:[self scene]];
  // TODO: Inline ScaleFrameForAspectRatio??
  NSRect frame = ScaleFrameForAspectRatio(textureInfo->size.height / textureInfo->size.width, [self masterLayerFrame]);
  LOG(@"Frame: %@ -> %@, w: %f, h: %f", NSStringFromRect([self masterLayerFrame]), NSStringFromRect(frame), textureInfo->size.width, textureInfo->size.height);
  
  NSRect newFrame = [self masterLayerFrame];
  float ratio = textureInfo->size.width / textureInfo->size.height;
  
  // calculate center point of the display
  int xcenter = newFrame.size.width;
  int ycenter = newFrame.size.height;
  
  // calcuate new frame size
  newFrame.size.width = (textureInfo->size.width * newFrame.size.height) / textureInfo->size.height;
  
  // finally, enlarge it 5%
  newFrame.size.width += (newFrame.size.width * 0.05);
  // newFrame.origin.x -= (newFrame.size.width * 0.25);
  newFrame.size.height += (newFrame.size.height * 0.05);
  // newFrame.origin.y -= (newFrame.size.height * 0.25);

  // offset the width to keep it centered
  int newxcenter = newFrame.size.width;
  int diff = newxcenter - xcenter;
  newFrame.origin.x -= diff / 2.0;
  
  int newycenter = newFrame.size.height;
  diff = newycenter - ycenter;
  newFrame.origin.y -= diff / 2.0;
  
  LOG(@"New frame: %@, ratio: %f", NSStringFromRect(newFrame), ratio);

  [backgroundImage setFrame:newFrame];
  // [backgroundImage setFrame:[[[self scene] root] frame]];
  // LOG(@"Frame: %@ %@ -> %@", NSStringFromRect([[[self scene] root] frame]), NSStringFromRect([self masterLayerFrame]), NSStringFromRect([backgroundImage frame]));
  [backgroundImage setTexture:[_controller blurredVideoFrame]];
  [blackLayer setAlphaValue:0.7f];
  
  [[self masterLayer] insertSublayer:backgroundImage atIndex:1];
  
  LOG(@"Sublayers: %@", [[self masterLayer] sublayers]);
    
}

// these are some macros to help in building the menu items, since it's so horribly repetitive
#define MENU_ITEM_MEDIATOR(item, actionsel, previewsel) \
  mediator = [[[BRMenuItemMediator alloc] initWithMenuItem:item] autorelease]; \
  [mediator setMenuActionSelector:actionsel]; \
  [mediator setMediaPreviewSelector:previewsel]; \
  [_items addObject:mediator];
  
#define MENU_ITEM(title, actionsel, previewsel) \
  item = [BRAdornedMenuItemLayer adornedMenuItemWithScene:[self scene]]; \
  [[item textItem] setTitle:title]; \
  MENU_ITEM_MEDIATOR(item, actionsel, previewsel);

#define FOLDER_MENU_ITEM(title, actionsel, previewsel) \
  item = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:[self scene]]; \
  [[item textItem] setTitle:title]; \
  MENU_ITEM_MEDIATOR(item, actionsel, previewsel);

#define DISABLED_MENU_ITEM(title, actionsel, previewsel) \
  item = [BRAdornedMenuItemLayer adornedMenuItemWithScene:[self scene]]; \
  [[item textItem] setTitle:title withAttributes:[[BRThemeInfo sharedTheme] textEntryGlyphGrayAttributes]]; \
  MENU_ITEM_MEDIATOR(item, nil, nil);

#define DISABLED_FOLDER_MENU_ITEM(title, actionsel, reviewsel) \
  item = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:[self scene]]; \
  [[item textItem] setTitle:title withAttributes:[[BRThemeInfo sharedTheme] textEntryGlyphGrayAttributes]]; \
  MENU_ITEM_MEDIATOR(item, nil, nil);

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
  [item setRightIcon:[[BRThemeInfo sharedTheme] returnToImageForScene:[self scene]]];
  
  if([(ATVFVideoPlayer *)_player hasSubtitles]) {
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
  return [[(BRAdornedMenuItemLayer *)[[_items objectAtIndex:row] menuItem] textItem] title];
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
