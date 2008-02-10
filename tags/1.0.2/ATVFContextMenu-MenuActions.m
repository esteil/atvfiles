//
// ATVFContextMenu-MenuActions.m
// ATVFiles
//
// Created by Eric Steil III on 8/24/07.
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

#import "ATVFContextMenu-MenuActions.h"
#import "ATVFContextMenu-Private.h"
#import "ATVFSettingsController.h"
#import "ATVFInfoController.h"
#import "ATVFileBrowserController.h"
#import "ATVFMediaAsset-Private.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>

@interface BRAlertController (FRCompat)
+(id)alertOfType:(int)type titled:(id)title primaryText:(id)primaryText secondaryText:(id)secondaryText;
@end

@implementation ATVFContextMenu (MenuActions)

-(void)_doAbout {
  NSString *shortVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#ifdef DEBUG
  BOOL debug = YES;
#else
  BOOL debug = NO;
#endif
  NSString *title = BRLocalizedString(@"About ATVFiles", "Caption for about screen");
  NSString *primary = [NSString stringWithFormat:BRLocalizedString(@"Version: %@ (%@)%@", "Label for version, replacements are: version number (0.5.0), short version number (22), and a tag indicating debug builds on the next line"), shortVersion, [NSNumber numberWithFloat:ATVFilesVersionNumber], debug ? @"\nDEBUG BUILD" : @""];
  NSString *secondary = [NSString stringWithFormat:@"Copyright (C) 2007-2008 Eric Steil III (ericiii.net)\n\nSpecial Thanks:\nalan_quatermain\nThe Sapphire Team\n\n%s", ATVFilesVersionString];
  
  BRAlertController *alert = [SapphireFrontRowCompat alertOfType:0
                                                          titled:title
                                                     primaryText:primary
                                                   secondaryText:secondary
                                                       withScene:[self scene]];
  
  [[self stack] pushController:alert];
}


-(void)_doMarkAsPlayed {
  LOG(@"In MenuActions _doMarkAsPlayed");
  [_asset setHasBeenPlayed:YES];
  
  // refresh menu
  [self _buildContextMenu];
  [[self list] reload];
  [SapphireFrontRowCompat renderScene:[self scene]];
}

-(void)_doMarkAsUnplayed {
  LOG(@"In MenuActions _doMarkAsUnplayed");
  [_asset setHasBeenPlayed:NO];
  
  // refresh menu
  [self _buildContextMenu];
  [[self list] reload];
  [SapphireFrontRowCompat renderScene:[self scene]];
}

-(void)_doPlayFolder {
  LOG(@"In doPlayFolder");
  NSURL *pathURL = [NSURL URLWithString:[_asset mediaURL]];
  NSString *path = [pathURL path];
  LOG(@"Path: %@ %@", pathURL, path);
  
  // get the directory contents
  ATVFDirectoryContents *contents = [[[ATVFDirectoryContents alloc] initWithScene:[self scene] forDirectory:path includeDirectories:NO playlists:NO] autorelease];
  
  // create our asset with the first one
  ATVFPlaylistAsset *playlist = [[[ATVFPlaylistAsset alloc] initWithMediaURL:[NSURL URLWithString:@"x-atvfiles-playlist://temporary"]] autorelease];
  [playlist setTemporary:YES];
  
  int i = 0;
  int num = [contents itemCount];
  ATVFMediaAsset *asset;
    
  // add each asset to the playlist
  for(i = 0; i < num; i++) {
    asset = [contents mediaForIndex:i];
    [playlist appendToPlaylist:asset];
  }
  
  // remove ourself from the stack and poke the file browser that launched us to start playing
  id controller = [[self stack] controllerLabelled:ATVFileBrowserControllerLabel deepest:NO];
  [controller playPlaylist:playlist];
  [[self stack] removeController:self];
}

-(void)_doPlaylistInfo {
  [self _doFileInfo];
}

-(void)_doDelete {
  BROptionDialog *dialog = [[SapphireFrontRowCompat optionDialogWithScene:[self scene]] autorelease];

  [dialog setTitle:[NSString stringWithFormat:BRLocalizedString(@"Delete %@?", "Delete Confirm dialog title (arg = filename)"), [_asset filename]]];
  [dialog setIcon:[self listIcon] horizontalOffset:0 kerningFactor:0];
  [SapphireFrontRowCompat setOptionDialogPrimaryInfoText:[NSString stringWithFormat:BRLocalizedString(@"Are you sure you want to delete the file %@?", "Delete Confirmation dialog text (arg = filename)"), [_asset filename]] withAttributes:nil optionDialog:dialog];

  [dialog addOptionText:BRLocalizedString(@"Yes", "Yes")];
  [dialog addOptionText:BRLocalizedString(@"No", "No")];

  [dialog setActionSelector:@selector(_handleDeleteConfirmChoice:) target:self];

  [[self stack] pushController:dialog];
}

-(void)_handleDeleteConfirmChoice:(id)evt {
  NSFileManager *manager = [NSFileManager defaultManager];
  NSString *temp;

  LOG(@"In _handleDeleteConfirmChoice: (%@)%@", [evt class], evt);
  
  switch([evt selectedIndex]) {
  case 0:
    LOG(@" Delete confirmed!");
    
    // put up a spinny thing while deleting
    NSString *title = [NSString stringWithFormat:BRLocalizedString(@"Deleting %@...", "Delete status dialog title (arg = filename)"), [_asset filename]];
    id controller = [SapphireFrontRowCompat textWithSpinnerControllerTitled:title text:title isNetworkDependent:NO scene:[self scene]];
    [controller autorelease];
    //[controller showProgress:YES];
    [[self stack] pushController:controller];
    
    // delete metadata file
    temp = [_asset _metadataXmlPath];
    if([manager fileExistsAtPath:temp]) {
      LOG(@"Deleting metadata XML: %@", temp);
      [manager removeFileAtPath:temp handler:nil];
    }

    // and cover art
    temp = [_asset _coverArtPath];
    if([manager fileExistsAtPath:temp]) {
      LOG(@"Deleting cover art: %@", temp);
      [manager removeFileAtPath:temp handler:nil];
    }
    
    // delete the file here
    if([_asset isStack]) {
      // many files
      int i = 0;
      int count = [[_asset stackContents] count];
      for(i = 0; i < count; i++) {
        [manager removeFileAtPath:[[[_asset stackContents] objectAtIndex:i] path] handler:nil];
      }
    } else {
      // only one file plus covers
      [manager removeFileAtPath:[[NSURL URLWithString:[_asset mediaURL]] path] handler:nil];
    }
    
    [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
    break;
  case 1:
    LOG(@" Delete rejected!");
    [[self stack] popToControllerWithLabel:ATVFContextMenuControllerLabel];
    break;
  }
  
}

-(void)_doFileInfo {
  LOG(@"In -ATVFContextMenu(MenuActions)_doFileInfo");
  
  id controller = [[ATVFInfoController alloc] initWithScene:[self scene]];
  LOG(@"Setting file info asset");
  [controller setAsset:_asset];
  LOG(@"Doing file info layout");
  [controller doLayout];
  
  LOG(@"Pushing file info controller");
  [[self stack] pushController:controller];
}

-(void)_doSettings {
  LOG(@"In MenuActions _doSettings");
  
  ATVFSettingsController *settings = [[[ATVFSettingsController alloc] initWithScene:[self scene]] autorelease];
  [[self stack] pushController:settings];
}

-(void)_doAddToPlaces {
  NSURL *pathURL = [NSURL URLWithString:[_asset mediaURL]];
  NSString *path = [pathURL path];
  
  LOG(@"Adding to places: %@", path);
  
  NSMutableArray *newPlaces = [[[ATVFPreferences preferences] arrayForKey:kATVPrefPlaces] mutableCopy];
  [newPlaces addObject:path];
  
  [[ATVFPreferences preferences] setObject:newPlaces forKey:kATVPrefPlaces];
  [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
}

-(void)_doRemoveFromPlaces {
  NSURL *pathURL = [NSURL URLWithString:[_asset mediaURL]];
  NSString *path = [pathURL path];

  LOG(@"Removing from places: %@", path);
  
  NSMutableArray *newPlaces = [[[ATVFPreferences preferences] arrayForKey:kATVPrefPlaces] mutableCopy];
  [newPlaces removeObject:path];
  
  [[ATVFPreferences preferences] setObject:newPlaces forKey:kATVPrefPlaces];
  [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
}

-(void)_doEject {
  NSURL *pathURL = [NSURL URLWithString:[_asset mediaURL]];
  NSString *path = [pathURL path];
  
  LOG(@"ejecting %@", path);

  NSString *title = [NSString stringWithFormat:BRLocalizedString(@"Ejecting %@...", "Eject status dialog title (arg = filename)"), [_asset filename]];
  id controller = [[BRTextWithSpinnerController alloc] initWithScene:[self scene] title:title text:title showBack:NO isNetworkDependent:NO];
  [controller autorelease];
  [controller showProgress:YES];
  [[self stack] pushController:controller];
  
  BOOL ejected = [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:path];
  
  if(ejected) {
    LOG(@"Ejected!");
    [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
  } else {
    LOG(@"Unable to eject");
    [[self stack] popToControllerWithLabel:ATVFContextMenuControllerLabel];
  }
}

-(void)_doShowPlaces {
  ATVFileBrowserController *mainMenu = [[[ATVFileBrowserController alloc] initWithScene:[self scene] usePlacesTitle:YES] autorelease];
  [[self stack] pushController:mainMenu];
}

// stupid test
-(void)_dropDisplay {
  LOG(@"In _dropDisplay");
  
  LOG(@"FRController: %@", NSClassFromString(@"FRController"));
  
  id frc = [NSClassFromString(@"FRController") sharedController];
  LOG(@" (%@)%@", [frc class], frc);
  
  [[self scene] setOpaque:NO];
  [[self scene] renderScene];
  [[BRDisplayManager sharedInstance] fadeOutDisplay];
  [[BRDisplayManager sharedInstance] releaseAllDisplays];
  
  sleep(10);
  
  [[self scene] setOpaque:YES];
  [[self scene] renderScene];
  [[BRDisplayManager sharedInstance] captureAllDisplays];
  [[BRDisplayManager sharedInstance] fadeInDisplay];
}
@end
