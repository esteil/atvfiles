//
// ATVFPlacesContents.h
// ATVFiles
//
// Created by Eric Steil III on 12/15/07.
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
#import "ATVFilesAppliance.h"
#import "ATVFMediaAsset.h"
#import "ATVFDirectoryContents.h"

enum kATVFPlacesMode {
  kATVFPlacesModeFull = 1,
  kATVFPlacesModeVolumesOnly = 2,
  kATVFPlacesModePlacesOnly = 3 // For ATV2 main menu
};

@interface ATVFPlacesContents : ATVFDirectoryContents {
  enum kATVFPlacesMode _mode;
}

-(ATVFPlacesContents *)initWithScene:(BRRenderScene *)scene mode:(enum kATVFPlacesMode)mode;

// notification handler
-(void)_mountsDidChange:(NSNotification *)notification;

@end
