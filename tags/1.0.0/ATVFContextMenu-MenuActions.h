//
// ATVFContextMenu-MenuActions.h
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
-(void)_doAddToPlaces;
-(void)_doRemoveFromPlaces;
-(void)_doEject;
-(void)_doShowPlaces;
@end
