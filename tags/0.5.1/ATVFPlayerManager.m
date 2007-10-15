//
//  ATVFPlayerManager.m
//  ATVFiles
//
//  Created by Eric Steil III on 7/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
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
