/*
 *  MenuMacros.h
 *  ATVFiles
 *
 *  Macros to make creating menu items less repetitive.
 *
 *  Created by Eric Steil III on 12/28/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#import "SapphireFrontRowCompat.h"

#define MENU_ITEM_MEDIATOR(item, actionsel, previewsel) \
  mediator = [[[BRMenuItemMediator alloc] initWithMenuItem:item] autorelease]; \
  [mediator setMenuActionSelector:actionsel]; \
  [mediator setMediaPreviewSelector:previewsel]; \
  [_items addObject:mediator];

#define MAKE_MENU_ITEM(title, isFolder) \
  item = [SapphireFrontRowCompat textMenuItemForScene:[self scene] folder:isFolder]; \
  [SapphireFrontRowCompat setTitle:title forMenu:item];

#define MAKE_DISABLED_MENU_ITEM(title, isFolder) \
  item = [SapphireFrontRowCompat textMenuItemForScene:[self scene] folder:isFolder]; \
  [SapphireFrontRowCompat setTitle:title withAttributes:[[BRThemeInfo sharedTheme] textEntryGlyphGrayAttributes] forMenu:item];

#define MENU_ITEM(title, actionsel, previewsel) \
  MAKE_MENU_ITEM(title, NO); \
  MENU_ITEM_MEDIATOR(item, actionsel, previewsel);

#define FOLDER_MENU_ITEM(title, actionsel, previewsel) \
  MAKE_MENU_ITEM(title, YES); \
  MENU_ITEM_MEDIATOR(item, actionsel, previewsel);

#define DISABLED_MENU_ITEM(title, actionsel, previewsel) \
  MAKE_DISABLED_MENU_ITEM(title, NO); \
  MENU_ITEM_MEDIATOR(item, nil, nil);

#define DISABLED_FOLDER_MENU_ITEM(title, actionsel, reviewsel) \
  MAKE_DISABLED_MENU_ITEM(title, YES); \
  MENU_ITEM_MEDIATOR(item, nil, nil);

#define BOOL_MENU_ITEM(title, prefkey, actionsel) \
  MENU_ITEM(title, actionsel, nil); \
  [SapphireFrontRowCompat setRightJustifiedText:([defaults boolForKey:prefkey] ? BRLocalizedString(@"Yes", "Yes") : BRLocalizedString(@"No", "No")) forMenu:item];
