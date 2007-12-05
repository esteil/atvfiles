//
//  ATVFContextMenu-MenuActions.h
//  ATVFiles
//
//  Created by Eric Steil III on 8/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ATVFContextMenu.h>
#import <BackRow/BackRow.h>

@interface ATVFContextMenu (MenuActions)

-(void)_doAbout;
-(void)_doMarkAsPlayed;
-(void)_doMarkAsUnplayed;
-(void)_doPlayFolder;
-(void)_doPlaylistInfo;
-(void)_doDelete;
-(void)_doFileInfo;
-(void)_doSettings;

@end
