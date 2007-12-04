//
//  ATVFContextMenu.m
//  ATVFiles
//
//  Created by Eric Steil III on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFContextMenu.h"
#import "ATVFPlaylistAsset.h"
#import "ATVFContextMenu-MenuActions.h"
#import "ATVFContextMenu-Private.h"
#import "ATVFMediaAsset-Private.h"

@implementation ATVFContextMenu

-(ATVFContextMenu *)initWithScene:(BRRenderScene *)scene forAsset:(ATVFMediaAsset *)asset {
  LOG(@"In ATVFContextMenu initWithScene:(%@)%@ forAsset:(%@)%@", [scene class], scene, [asset class], asset);
  [super initWithScene:scene];
  _asset = [asset retain];
  
  [self addLabel:ATVFContextMenuControllerLabel];
  
  // set title
  [self setListTitle:[_asset title]];

  [self _buildContextMenu];
  [[self list] setDatasource:self];
  
  return self;
}

-(void)dealloc {
  [_asset release];
  [super dealloc];
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

@end

@implementation ATVFContextMenu (Private)
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

-(void)_buildContextMenu {
  LOG(@"Building context menu for asset %@: %@", _asset, [_asset mediaURL]);
  
  [_items release];
  _items = [[NSMutableArray arrayWithCapacity:5] retain];

  BRAdornedMenuItemLayer *item = nil;
  NSString *title = nil;
  BRMenuItemMediator *mediator = nil;
  
  // other menu items go here, possibly depending on asset?
  if([_asset isDirectory]) {
    // we're a directory
    
    // play all
    title = BRLocalizedString(@"Play Folder", "Context menu entry for playing contents of a folder");
    MENU_ITEM(title, @selector(_doPlayFolder), nil);

    // delete
    title = BRLocalizedString(@"Delete", "Context menu entry for deleting a file");
    MENU_ITEM(title, @selector(_doDelete), nil);
    
  } else if([_asset isPlaylist]) {
    // we're a playlist
    
    // info
    title = BRLocalizedString(@"Playlist Info", "Context menu entry for showing playlist info");
    MENU_ITEM(title, @selector(_doPlaylistInfo), nil);
    
    // mark as (un)played
    if([_asset hasBeenPlayed]) {
      title = BRLocalizedString(@"Mark as Unplayed", "Context menu entry for marking as unplayed");
      MENU_ITEM(title, @selector(_doMarkAsUnplayed), nil);
    } else {
      title = BRLocalizedString(@"Mark as Played", "Context menu entry for marking as played");
      MENU_ITEM(title, @selector(_doMarkAsPlayed), nil);
    }
    
    // delete (if file backed)
    if([(ATVFPlaylistAsset *)_asset isFile]) {
      title = BRLocalizedString(@"Delete", "Context menu entry for deleting a file");
      MENU_ITEM(title, @selector(_doDelete), nil);
    }
  } else {
    // a normal (stacked) asset
    
    // file info
    title = BRLocalizedString(@"File Info", "Context menu entry for showing playlist info");
    MENU_ITEM(title, @selector(_doFileInfo), nil);
    
    // mark as (un)played
    if([_asset hasBeenPlayed]) {
      title = BRLocalizedString(@"Mark as Unplayed", "Context menu entry for marking as unplayed");
      MENU_ITEM(title, @selector(_doMarkAsUnplayed), nil);
    } else {
      title = BRLocalizedString(@"Mark as Played", "Context menu entry for marking as played");
      MENU_ITEM(title, @selector(_doMarkAsPlayed), nil);
    }
    
    // delete
    title = BRLocalizedString(@"Delete", "Context menu entry for deleting a file");
    MENU_ITEM(title, @selector(_doDelete), nil);
  }
  
  // divider
  [[self list] setDividerIndex:[_items count]];
  
  // settings here
  title = BRLocalizedString(@"Settings", "Context menu entry for going to settings screen");
  FOLDER_MENU_ITEM(title, @selector(_doSettings), nil);
  
  // only about for now, will go on bottom in any case
  title = BRLocalizedString(@"About", "Context menu entry for going to the about screen");
  MENU_ITEM(title, @selector(_doAbout), nil);
}

-(BOOL)_deleteFileWithMetadata:(NSString *)path {
  BOOL result = YES;
  return result;
}
@end