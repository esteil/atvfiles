//
//  ATVFPlaylistPlayer.m
//  ATVFiles
//
//  Created by Eric Steil III on 9/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFPlaylistPlayer.h"
#import "ATVFPlayerManager.h"
#import "ATVFileBrowserController.h"

@implementation ATVFPlaylistPlayer

-(ATVFPlaylistPlayer *)initWithScene:(BRRenderScene *)scene playlist:(ATVFPlaylistAsset *)playlist {
  [super initWithScene:scene];
  
  _currentPlaylist = [playlist retain];
  _playlistPosition = 0;
  _currentlyInPlaylist = NO;
  
  return self;
}

-(void)dealloc {
  LOG(@"ATVFPlaylistPlayer -dealloc - %@", [_currentPlaylist mediaURL]);
  [_currentPlaylist release];
  [super dealloc];
}

// this starts playback
-(void)wasPushed {
  _playlistPosition = 0;
  _currentlyInPlaylist = YES;
  
  id asset = [[_currentPlaylist playlistContents] objectAtIndex:0];
  [self playAsset:asset];
}

// this is called after the menu has been popped and just before redraw
-(void)wasExhumedByPoppingController:(BRLayerController *)controller {
// -(void)willBeExhumed {
  LOG(@"wasExhumedByPoppingController:(%@)%@ -> %d(%d)", [controller class], controller, _currentlyInPlaylist, _playlistPosition);
  
  // if we're currently in a playlist, we want to get the next asset and go play it
  _playlistPosition++;
  NSArray *contents = [_currentPlaylist playlistContents];
  if(_playlistPosition < [[_currentPlaylist playlistContents] count]) {
    LOG(@"in playlist check, position %d", _playlistPosition);
    ATVFMediaAsset *asset = [[_currentPlaylist playlistContents] objectAtIndex:_playlistPosition];
    LOG(@"Playing asset at position %d of %d: %@", _playlistPosition, [[_currentPlaylist playlistContents] count], [asset mediaURL]);
    
    // BOOL wasInPlaylist = _currentlyInPlaylist;
    // if(_playlistPosition == [[_currentPlaylist playlistContents] count] - 1) {
    //   _currentlyInPlaylist = NO;
    // }

    [self playAsset:asset];
    // [super wasExhumedByPoppingController:controller];
  } else {
    [super wasExhumedByPoppingController:controller];
    [[self stack] popToControllerWithLabel:ATVFileBrowserControllerLabel];
    // [super willBeExhumed];
  }

}

// -(void)wasExhumedByPoppingController:(BRLayerController *)controller {
//   // we're done, go back
//   [[self stack] popController];
// }

// -(BOOL)popsOnBury {
//   LOG(@"ATVFPlaylistPlayer -popsOnBury: %d", !_currentlyInPlaylist);
//   return !_currentlyInPlaylist;
// }

-(void)playAsset:(ATVFMediaAsset *)asset {
  // play it here
  NSError *error = nil;
  
  // get the player for this asset
  ATVFPlayerType playerType = [ATVFPlayerManager playerTypeForAsset:asset];
  id player = [ATVFPlayerManager playerForType:playerType];
  LOG(@"Player type: %d, player: (%@)%@", playerType, [player class], player);
  
  id controller;
  if(playerType == kATVFPlayerMusic) {
    // set up music player here
    controller = [[[BRMusicNowPlayingController alloc] initWithScene:[self scene]] autorelease];
    [player setMedia:asset inTracklist:[NSMutableArray arrayWithObject:asset] error:&error];
    if(error) {
      LOG(@"Unable to set player with error: %@", error);
      return;
    } else {
      [controller setPlayer:player];
      if(error) LOG(@"Error initiating playback: %@", error);
    }
  } else if(playerType == kATVFPlayerVideo) {
    // set up video player here
    [player setMedia:asset error:&error];
    controller = [[[BRVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    [controller setAllowsResume:NO];
    [controller setVideoPlayer:player];
    
    // stop audio playback
    [[ATVFPlayerManager musicPlayer] stop];
  }
  
  // if(_currentlyInPlaylist)
  //   [[self stack] swapController:controller];
  // else
    [[self stack] pushController:controller];
  
  if(playerType == kATVFPlayerMusic) 
    [player initiatePlayback:&error];
}

@end
