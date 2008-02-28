//
//  ATVFContextMenu-MenuActions.m
//  ATVFiles
//
//  Created by Eric Steil III on 8/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFContextMenu-MenuActions.h"
#import "ATVFContextMenu-Private.h"
#import "ATVFSettingsController.h"
#import "ATVFInfoController.h"
#import "ATVFileBrowserController.h"

@implementation ATVFContextMenu (MenuActions)

-(void)_doAbout {
  NSString *shortVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  BRAlertController *alert = [BRAlertController alertOfType:0
      titled:BRLocalizedString(@"About ATVFiles", @"Caption for about screen")
        primaryText:[NSString stringWithFormat:BRLocalizedString(@"Version: %@ (%@)%@", "Label for version, replacements are: version number (0.5.0), short version number (22), and a tag indicating debug builds on the next line"), shortVersion, [NSNumber numberWithFloat:ATVFilesVersionNumber], 
#ifdef DEBUG
        @"\nDEBUG BUILD"
#else
        @""
#endif
      ]
      secondaryText:[NSString stringWithFormat:@"Copyright (C) 2007 Eric Steil III (ericiii.net)\n\nSpecial Thanks: alan_quatermain\n\n%s", ATVFilesVersionString]
          withScene:[self scene]];

  [_stack pushController:alert];
}


-(void)_doMarkAsPlayed {
  LOG(@"In MenuActions _doMarkAsPlayed");
  [_asset setHasBeenPlayed:YES];
  
  // refresh menu
  [self _buildContextMenu];
  [[self list] reload];
  [[self scene] renderScene];
}

-(void)_doMarkAsUnplayed {
  LOG(@"In MenuActions _doMarkAsUnplayed");
  [_asset setHasBeenPlayed:NO];
  
  // refresh menu
  [self _buildContextMenu];
  [[self list] reload];
  [[self scene] renderScene];
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
  BROptionDialog *dialog = [[[BROptionDialog alloc] initWithScene:[self scene]] autorelease];
  [dialog setTitle:[NSString stringWithFormat:BRLocalizedString(@"Delete %@?", "Delete Confirm dialog title (arg = filename)"), [_asset filename]]];
  [dialog setIcon:[self listIcon] horizontalOffset:0 kerningFactor:0];
  [dialog setPrimaryInfoText:[NSString stringWithFormat:BRLocalizedString(@"Are you sure you want to delete the file %@?", "Delete Confirmation dialog text (arg = filename)"), [_asset filename]]];

  [dialog addOptionText:BRLocalizedString(@"Yes", "Yes")];
  [dialog addOptionText:BRLocalizedString(@"No", "No")];

  [dialog setActionSelector:@selector(_handleDeleteConfirmChoice:) target:self];

  [[self stack] pushController:dialog];
}

-(void)_handleDeleteConfirmChoice:(id)evt {
  LOG(@"In _handleDeleteConfirmChpice: (%@)%@", [evt class], evt);
  
  switch([evt selectedIndex]) {
  case 0:
    LOG(@" Delete confirmed!");
    
    // put up a spinny thing while deleting
    NSString *title = [NSString stringWithFormat:BRLocalizedString(@"Deleting %@...", "Delete status dialog title (arg = filename)"), [_asset filename]];
    id controller = [[BRTextWithSpinnerController alloc] initWithScene:[self scene] title:title text:title showBack:NO isNetworkDependent:NO];
    [controller autorelease];
    [controller showProgress:YES];
    [[self stack] pushController:controller];
    
    // delete the file here
    [[NSFileManager defaultManager] removeFileAtPath:[[NSURL URLWithString:[_asset mediaURL]] path] handler:nil];
    
    [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
    break;
  case 1:
    LOG(@" Delete rejected!");
    [[self stack] popToControllerWithLabel:ATVFContextMenuControllerLabel];
    break;
  }
  
}

-(void)_doFileInfo {
  id controller = [[[ATVFInfoController alloc] initWithScene:[self scene]] autorelease];
  [controller setAsset:_asset];
  [controller doLayout];
  
  [[self stack] pushController:controller];
}

-(void)_doSettings {
  LOG(@"In MenuActions _doSettings");
  
  ATVFSettingsController *settings = [[[ATVFSettingsController alloc] initWithScene:[self scene]] autorelease];
  [[self stack] pushController:settings];
}

@end