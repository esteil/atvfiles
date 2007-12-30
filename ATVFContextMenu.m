//
// ATVFContextMenu.m
// ATVFiles
//
// Created by Eric Steil III on 8/19/07.
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

#import "ATVFContextMenu.h"
#import "ATVFPlaylistAsset.h"
#import "ATVFContextMenu-MenuActions.h"
#import "ATVFContextMenu-Private.h"
#import "ATVFMediaAsset-Private.h"
#import "ATVFPreferences.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>
#import "MenuMacros.h"

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
  [_items release];
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
    LOG(@"Performing selector on self");
    [self performSelector:selector];
    LOG(@"Done performing selector on self");
  }
}

-(long)itemCount {
  return [_items count];
}

-(id)itemForRow:(long)row {
  id item = [[_items objectAtIndex:row] menuItem];
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

@end

@implementation ATVFContextMenu (Private)

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
    
    // add/remove from places
    if([[[ATVFPreferences preferences] arrayForKey:kATVPrefPlaces] containsObject:[[NSURL URLWithString:[_asset mediaURL]] path]]) {
      // remove
      title = BRLocalizedString(@"Remove from Places", "Remove from Places");
      MENU_ITEM(title, @selector(_doRemoveFromPlaces), nil);
    } else {
      // add
      title = BRLocalizedString(@"Add to Places", "Add to Places");
      MENU_ITEM(title, @selector(_doAddToPlaces), nil);
    }
    
    // eject
    if([_asset isEjectable]) {
      title = BRLocalizedString(@"Eject", "Eject");
      MENU_ITEM(title, @selector(_doEject), nil);
    }
  } else if([_asset isPlaylist]) {
    // we're a playlist
    
    // info
    title = BRLocalizedString(@"Playlist Info", "Context menu entry for showing playlist info");
    if([SapphireFrontRowCompat usingFrontRow]) {
      DISABLED_MENU_ITEM(title, @selector(_doPlaylistInfo), nil);
    } else {
      MENU_ITEM(title, @selector(_doPlaylistInfo), nil);
    }
    
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
    if([SapphireFrontRowCompat usingFrontRow]) {
      DISABLED_MENU_ITEM(title, @selector(_doFileInfo), nil);
    } else {
      MENU_ITEM(title, @selector(_doFileInfo), nil);
    }
    
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
  [SapphireFrontRowCompat addDividerAtIndex:[_items count] toList:[self list]];
  
  // link to places menu
  title = BRLocalizedString(@"Places", "Context menu entry for viewing places");
  FOLDER_MENU_ITEM(title, @selector(_doShowPlaces), nil);
  
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