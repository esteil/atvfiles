//
//  ATVFSettingsController.m
//  ATVFiles
//
//  Created by Eric Steil III on 9/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFSettingsController.h"
#import "ATVFilesAppliance.h"

@implementation ATVFSettingsController

-(ATVFSettingsController *)initWithScene:(BRRenderScene *)scene {
  [super initWithScene:scene];

  // set title
  [self setListTitle:BRLocalizedString(@"Settings", "Title for settings menu")];
  
  [self _buildMenu];
  [[self list] setDatasource:self];
  
  return self;
}


-(void)dealloc {
  [_items dealloc];
  [super dealloc];
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
  
#define BOOL_MENU_ITEM(title, prefkey, actionsel) \
  MENU_ITEM(title, actionsel, nil); \
  [[item textItem] setRightJustifiedText:([defaults boolForKey:prefkey] ? BRLocalizedString(@"Yes", "Yes") : BRLocalizedString(@"No", "No"))];
  
// #define kATVPrefRootDirectory @"RootDirectory"
// #define kATVPrefVideoExtensions @"VideoExtensions"
// #define kATVPrefAudioExtensions @"AudioExtensions"
// #define kATVPrefPlaylistExtensions @"PlaylistExtensions"
// #define kATVPrefEnableAC3Passthrough @"EnableAC3Passthrough"
// #define kATVPrefEnableFileDurations @"EnableFileDurations"
// #define kATVPrefShowFileExtensions @"ShowFileExtensions"
// #define kATVPrefShowFileSize @"ShowFileSize"
// #define kATVPrefShowUnplayedDot @"ShowUnplayedDot"
// #define kATVPrefResumeOffset @"ResumeOffset"
// #define kATVPrefStackRegexps @"StackRegexps"
// #define kATVPrefEnableStacking @"EnableStacking"
  
-(void)_buildMenu {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [_items release];
  _items = [[NSMutableArray arrayWithCapacity:5] retain];

  BRAdornedMenuItemLayer *item = nil;
  NSString *title = nil;
  BRMenuItemMediator *mediator = nil;
  
  title = BRLocalizedString(@"AC3 Passthrough", "Preference menu item for EnableAC3Passthrough");
  BOOL_MENU_ITEM(title, kATVPrefEnableAC3Passthrough, nil);
  
  title = BRLocalizedString(@"Read File Durations", "Preference menu item for EnableFileDurations");
  BOOL_MENU_ITEM(title, kATVPrefEnableFileDurations, nil);
  
  title = BRLocalizedString(@"Show File Extensions", "Show File Extensions");
  BOOL_MENU_ITEM(title, kATVPrefShowFileExtensions, nil);
  
  BOOL_MENU_ITEM(BRLocalizedString(@"Show File Sizes", "Show File Sizes"), kATVPrefShowFileSize, nil);
  BOOL_MENU_ITEM(BRLocalizedString(@"Show Unplayed Dot", "Show Unplayed Dot"), kATVPrefShowUnplayedDot, nil);
  BOOL_MENU_ITEM(BRLocalizedString(@"Enable File Stacking", "Enable File Stacking"), kATVPrefEnableStacking, nil);
}

@end
