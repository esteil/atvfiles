//
//  ATVFContextMenu.m
//  ATVFiles
//
//  Created by Eric Steil III on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFContextMenu.h"

@interface ATVFContextMenu (Private)
-(void)_buildContextMenu;
-(void)_doAbout;
@end

@implementation ATVFContextMenu

-(ATVFContextMenu *)initWithScene:(BRRenderScene *)scene forAsset:(ATVFMediaAsset *)asset {
  LOG(@"In ATVFContextMenu initWithScene:(%@)%@ forAsset:(%@)%@", [scene class], scene, [asset class], asset);
  [super initWithScene:scene];
  _asset = [asset retain];
  
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
  return [[[[_items objectAtIndex:row] menuItem] textItem] title];
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
  [_items release];
  _items = [[NSMutableArray arrayWithCapacity:1] retain];

  BRAdornedMenuItemLayer *item = nil;
  NSString *title = nil;
  BRMenuItemMediator *mediator = nil;
  
  // other menu items go here, possibly depending on asset?
  
  // settings here
  item = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:[self scene]];
  title = BRLocalizedString(@"Settings", "Context menu entry for going to settings screen");
  [[item textItem] setTitle:title withAttributes:[[BRThemeInfo sharedTheme] textEntryGlyphGrayAttributes]];
  [[item textItem] setArrowDisabled:YES];
  
  mediator = [[[BRMenuItemMediator alloc] initWithMenuItem:item] autorelease];
  [mediator setMenuActionSelector:nil];
  [mediator setMediaPreviewSelector:nil];
  [_items addObject:mediator];
  
  // only about for now, will go on bottom in any case
  item = [BRAdornedMenuItemLayer adornedFolderMenuItemWithScene:[self scene]];
  title = BRLocalizedString(@"About", "Context menu entry for going to the about screen");
  [[item textItem] setTitle:title];
  
  mediator = [[[BRMenuItemMediator alloc] initWithMenuItem:item] autorelease];
  [mediator setMenuActionSelector:@selector(_doAbout)];
  [mediator setMediaPreviewSelector:nil];
  [_items addObject:mediator];
}

-(void)_doAbout {
  NSString *shortVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  BRAlertController *alert = [BRAlertController alertOfType:0
      titled:BRLocalizedString(@"About ATVFiles", @"Caption for about screen")
        primaryText:[NSString stringWithFormat:BRLocalizedString(@"Version: %@ (%@)%@", "Label for version, replacements are: version number (0.5.0), short version number (22), and a tag indicating debug builds on the next line"), shortVersion, [NSNumber numberWithFloat:ATVFilesVersionNumber], 
#ifdef DEBUG
        BRLocalizedString(@"\nDEBUG BUILD", "Tag for debug builds (must start with newline)")
#else
        @""
#endif
      ]
      secondaryText:[NSString stringWithFormat:@"Copyright (C) 2007 Eric Steil III (ericiii.net)\n\nSpecial Thanks: alan_quatermain\n\n%s", ATVFilesVersionString]
          withScene:[self scene]];

  [_stack pushController:alert];
}

@end