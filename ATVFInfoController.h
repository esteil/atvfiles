//
// ATVFInfoController.h
// ATVFiles
//
// Created by Eric Steil III on 9/15/07.
// Copyright (C) 2007 Eric Steil III
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
#import <ATVFMediaAsset.h>
#import "SapphireLayerController.h"

@interface ATVFInfoController : SapphireLayerController {
  BRHeaderControl *_header;
  BRVerticalScrollControl *_document;
  ATVFMediaAsset *_asset;
}

-(void)doLayout;
-(void)setAsset:(ATVFMediaAsset *)asset;
-(ATVFMediaAsset *)asset;

@end
