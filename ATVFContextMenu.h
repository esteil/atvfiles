//
// ATVFContextMenu.h
// ATVFiles
//
// Created by Eric Steil III on 8/19/07.
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
#import <BackRow/BackRow.h>
#import "ATVFMediaAsset.h"
#import <SapphireCompatClasses/SapphireMenuController.h>

#define ATVFContextMenuControllerLabel @"net.ericiii.ATVFiles.ContextMenuController"

extern const double ATVFilesVersionNumber;
extern const unsigned char ATVFilesVersionString[];

@interface ATVFContextMenu : SapphireMenuController {
  ATVFMediaAsset *_asset;
  NSMutableArray *_items;
}

-(ATVFContextMenu *)initWithScene:(BRRenderScene *)scene forAsset:(ATVFMediaAsset *)asset;

@end

