//
//  ATVFSettingsController.m
//  ATVFiles
//
//  Created by Eric Steil III on 9/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFSettingsController.h"
#import "ATVFilesAppliance.h"
#import "SapphireFrontRowCompat.h"

@interface ATVFSettingsController (Private)
-(void)_toggleAC3Passthrough;
-(void)_toggleEnableFileDurations;
-(void)_toggleShowFileExtensions;
-(void)_toggleShowFileSizes;
-(void)_toggleShowUnplayedDot;
-(void)_toggleEnableFileStacking;
-(void)_toggleBooleanPreference:(NSString *)key;
-(void)_adjustResumeOffset;
-(void)_chooseNewRootDirectory;
@end

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

// these are some macros to help in building the menu items, since it's so horribly repetitive
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
  ATVFPreferences *defaults = [ATVFPreferences preferences];
  
  [_items release];
  _items = [[NSMutableArray arrayWithCapacity:5] retain];

  BRAdornedMenuItemLayer *item = nil;
  NSString *title = nil;
  BRMenuItemMediator *mediator = nil;
  
  title = BRLocalizedString(@"AC3 Passthrough", "Preference menu item for EnableAC3Passthrough");
  BOOL_MENU_ITEM(title, kATVPrefEnableAC3Passthrough, @selector(_toggleAC3Passthrough));
  
  title = BRLocalizedString(@"Read File Durations", "Preference menu item for EnableFileDurations");
  BOOL_MENU_ITEM(title, kATVPrefEnableFileDurations, @selector(_toggleEnableFileDurations));
  
  title = BRLocalizedString(@"Show File Extensions", "Show File Extensions");
  BOOL_MENU_ITEM(title, kATVPrefShowFileExtensions, @selector(_toggleShowFileExtensions));
  
  BOOL_MENU_ITEM(BRLocalizedString(@"Show File Sizes", "Show File Sizes"), kATVPrefShowFileSize, @selector(_toggleShowFileSizes));
  BOOL_MENU_ITEM(BRLocalizedString(@"Show Unplayed Dot", "Show Unplayed Dot"), kATVPrefShowUnplayedDot, @selector(_toggleShowUnplayedDot));
  BOOL_MENU_ITEM(BRLocalizedString(@"Show File Icons", "Show File Icons"), kATVPrefShowFileIcons, @selector(_toggleShowFileIcons));
  BOOL_MENU_ITEM(BRLocalizedString(@"Enable File Stacking", "Enable File Stacking"), kATVPrefEnableStacking, @selector(_toggleEnableFileStacking));
  BOOL_MENU_ITEM(BRLocalizedString(@"Enable Subtitles by Default", "Enable Subtitles by Default"), kATVPrefEnableSubtitlesByDefault, @selector(_toggleEnableSubtitlesByDefault));
  
  MENU_ITEM(BRLocalizedString(@"Resume Offset", "Resume Offset"), @selector(_adjustResumeOffset), nil);
  [SapphireFrontRowCompat setRightJustifiedText:[NSString stringWithFormat:@"%ds", [defaults integerForKey:kATVPrefResumeOffset]] forMenu:item];
 
  // FOLDER_MENU_ITEM(BRLocalizedString(@"Set Root Directory", "Set Root Directory"), @selector(_chooseNewRootDirectory), nil);
  
}

-(void)_toggleAC3Passthrough {
  [self _toggleBooleanPreference:kATVPrefEnableAC3Passthrough];
}
-(void)_toggleEnableFileDurations {
  [self _toggleBooleanPreference:kATVPrefEnableFileDurations];
}
-(void)_toggleShowFileExtensions {
  [self _toggleBooleanPreference:kATVPrefShowFileExtensions];
}
-(void)_toggleShowFileSizes {
  [self _toggleBooleanPreference:kATVPrefShowFileSize];
}
-(void)_toggleShowFileIcons {
  [self _toggleBooleanPreference:kATVPrefShowFileIcons];
}
-(void)_toggleShowUnplayedDot {
  [self _toggleBooleanPreference:kATVPrefShowUnplayedDot];
}
-(void)_toggleEnableFileStacking {
  [self _toggleBooleanPreference:kATVPrefEnableStacking];
}
-(void)_toggleEnableSubtitlesByDefault {
  [self _toggleBooleanPreference:kATVPrefEnableSubtitlesByDefault];
}

-(void)_toggleBooleanPreference:(NSString *)key {
  BOOL currentValue = [[ATVFPreferences preferences] boolForKey:key];
  LOG(@"Toggling bool pref %@: %d -> %d", key, currentValue, !currentValue);
  [[ATVFPreferences preferences] setBool:!currentValue forKey:key];
  [[ATVFPreferences preferences] synchronize];
  
  // refresh menu
  [self _buildMenu];
  [[self list] reload];
  [SapphireFrontRowCompat renderScene:[self scene]];
}

-(void)_chooseNewRootDirectory {
  
}

-(void)_adjustResumeOffset {
  // this just steps through 0-60s in 5s increments and resets
  ATVFPreferences *preferences = [ATVFPreferences preferences];
  
  int offset = [preferences integerForKey:kATVPrefResumeOffset];
  offset += 5;
  if(offset > 60) offset = 0;
  
  [preferences setInteger:offset forKey:kATVPrefResumeOffset];
  [preferences synchronize];
  
  [self _buildMenu];
  [[self list] reload];
  [SapphireFrontRowCompat renderScene:[self scene]];
}

@end
