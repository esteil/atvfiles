//
// ATVFVLCAppController.h
// ATVFiles
//
// Created by Eric Steil III on 6/17/07.
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

#ifdef ENABLE_EXTERNAL_PLAYERS
#import <Cocoa/Cocoa.h>
#import <ATVFullscreenAppController.h>
#import <ATVFMediaAsset.h>

@interface ATVFVLCAppController : ATVFullscreenAppController {

}

-(ATVFVLCAppController *)initWithAsset:(ATVFMediaAsset *)asset;

@end
#endif
