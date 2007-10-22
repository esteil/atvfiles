//
//  ATVFVideoPlayerMenu.m
//  ATVFiles
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFVideoPlayerMenu.h"

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
  [blackLayer setFrame:[self masterLayerFrame]];
  [[self masterLayer] insertSublayer:blackLayer atIndex:0];
  
  // and the blurred image
  BRImageLayer *backgroundImage = [BRImageLayer layerWithScene:[self scene]];
  [backgroundImage setFrame:[[self masterLayer] frame]];
  LOG(@"Frame: %@ %@ -> %@", NSStringFromRect([[self masterLayer] frame]), NSStringFromRect([self masterLayerFrame]), NSStringFromRect([backgroundImage frame]));
  [backgroundImage setTexture:[_controller blurredVideoFrame]];
  
  BRDarkenedLayer *darkenedLayer = [[[BRDarkenedLayer alloc] initWithScene:[self scene] andLayer:backgroundImage] autorelease];
  [darkenedLayer setFrame:[self masterLayerFrame]];
  [[self masterLayer] insertSublayer:darkenedLayer atIndex:1];
  
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
  
  title = BRLocalizedString(@"Subtitles", "Subtitles");
  DISABLED_MENU_ITEM(title, @selector(_subtitles), nil);
  
  title = BRLocalizedString(@"Return to file listing", "Return to file listing");
  MENU_ITEM(title, @selector(_returnToFileListing), nil);
  [item setRightIcon:[[BRThemeInfo sharedTheme] returnToImageForScene:[self scene]]];
  
  
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

@end
