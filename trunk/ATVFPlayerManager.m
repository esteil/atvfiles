//
// ATVFPlayerManager.m
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

#import "ATVFPlayerManager.h"
#import "ATVFilesAppliance.h"
#import "ATVFPreferences.h"

@implementation ATVFPlayerManager

+(ATVFMusicPlayer *)musicPlayer {
  static ATVFMusicPlayer *_musicPlayer;
  
  // initialize our player
  if(!_musicPlayer) {
    _musicPlayer = [[[ATVFMusicPlayer alloc] init] retain];
  }
  
  return _musicPlayer;
}

+(BRQTKitVideoPlayer *)videoPlayer {
  return [[[ATVFVideoPlayer alloc] init] autorelease];
}

+(id)playerForType:(enum ATVFPlayerType)type {
  switch(type) {
    case kATVFPlayerMusic:
      return [self musicPlayer];
      break;
    case kATVFPlayerVideo:
      return [self videoPlayer];
      break;
    default:
      return nil;
      break;
  }
}

// return the player type we need, this only looks at the asset's extension for now
+(enum ATVFPlayerType)playerTypeForAsset:(ATVFMediaAsset *)asset {
  NSArray *videoExtensions = [[ATVFPreferences preferences] arrayForKey:kATVPrefVideoExtensions];
  NSArray *audioExtensions = [[ATVFPreferences preferences] arrayForKey:kATVPrefAudioExtensions];
  NSArray *playlistExtensions = [[ATVFPreferences preferences] arrayForKey:kATVPrefPlaylistExtensions];
  
  NSString *extension = [[[asset mediaURL] pathExtension] lowercaseString];
  
  if([videoExtensions containsObject:extension]) {
    return kATVFPlayerVideo;
  } else if([audioExtensions containsObject:extension]) {
    return kATVFPlayerMusic;
  } else if([playlistExtensions containsObject:extension]) {
    return kATVFPlayerPlaylist;
  } else {
    return kATVFPlayerVideo;
  }
}

@end
