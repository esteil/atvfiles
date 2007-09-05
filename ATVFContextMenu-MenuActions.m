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
  
}

-(void)_doPlaylistInfo {
  
}

-(void)_doDelete {
  
}

-(void)_doFileInfo {
  
}

-(void)_doSettings {
  LOG(@"In MenuActions _doSettings");
  
  ATVFSettingsController *settings = [[[ATVFSettingsController alloc] initWithScene:[self scene]] autorelease];
  [_stack pushController:settings];
}

@end
