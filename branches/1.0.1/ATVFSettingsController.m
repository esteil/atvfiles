//
// ATVFSettingsController.m
// ATVFiles
//
// Created by Eric Steil III on 9/4/07.
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

#import "ATVFSettingsController.h"
#import "ATVFilesAppliance.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>
#import "MenuMacros.h"

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
  
  BOOL_MENU_ITEM(BRLocalizedString(@"Automatically Enter ATVFiles on Startup", "Automatically Enter ATVFiles"), kATVPrefEnterAutomatically, @selector(_toggleEnterAutomatically));
  
  MENU_ITEM(BRLocalizedString(@"Enable Places", "Places Mode"), @selector(_toggleEnablePlaces), nil);
  NSString *placesValue = [defaults stringForKey:kATVPrefPlacesMode];
  NSString *right = nil;
  if([placesValue isEqualToString:kATVPrefPlacesModeEnabled])
    right = BRLocalizedString(@"Enabled", "Places mode: Enabled");
  else if([placesValue isEqualToString:kATVPrefPlacesModeVolumes])
    right = BRLocalizedString(@"Volumes Only", "Places mode: Volumes Only");
  else if([placesValue isEqualToString:kATVPrefPlacesModeOff])
    right = BRLocalizedString(@"Disabled", "Places mode: Disabled");
  [SapphireFrontRowCompat setRightJustifiedText:right forMenu:item];
  
  // FIXME: ATV only
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
-(void)_toggleEnterAutomatically {
  [self _toggleBooleanPreference:kATVPrefEnterAutomatically];
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

-(void)_toggleEnablePlaces {
  NSString *currentValue = [[ATVFPreferences preferences] stringForKey:kATVPrefPlacesMode];
  NSString *newValue = nil;
  
  if([currentValue isEqualToString:kATVPrefPlacesModeEnabled])
    newValue = kATVPrefPlacesModeVolumes;
  else if([currentValue isEqualToString:kATVPrefPlacesModeVolumes])
    newValue = kATVPrefPlacesModeOff;
  else
    newValue = kATVPrefPlacesModeEnabled;
  
  [[ATVFPreferences preferences] setValue:newValue forKey:kATVPrefPlacesMode];
  [[ATVFPreferences preferences] synchronize];
  
  [self _buildMenu];
  [[self list] reload];
  [SapphireFrontRowCompat renderScene:[self scene]];
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
