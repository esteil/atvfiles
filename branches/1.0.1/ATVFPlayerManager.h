//
// ATVFPlayerManager.h
// ATVFiles
//
// Created by Eric Steil III on 7/8/07.
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
#import "ATVFMusicPlayer.h"
#import "ATVFMediaAsset.h"
#import "ATVFVideoPlayer.h"

enum ATVFPlayerType {
  kATVFPlayerMusic = 0,
  kATVFPlayerVideo = 1,
  kATVFPlayerPlaylist = 2
};

typedef enum ATVFPlayerType ATVFPlayerType;

@interface ATVFPlayerManager : NSObject {
}

+(ATVFMusicPlayer *)musicPlayer;
+(BRQTKitVideoPlayer *)videoPlayer;
+(id)playerForType:(enum ATVFPlayerType)type;
+(enum ATVFPlayerType)playerTypeForAsset:(ATVFMediaAsset *)asset;

@end
