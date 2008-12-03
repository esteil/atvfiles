//
// ATVFileBrowserController.m
// ATVFiles
//
// Created by Eric Steil III on 3/29/07.
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

#import "ATVFileBrowserController.h"
#import "ATVBRMetadataExtensions.h"
#import "ATVFCoreAudioHelper.h"
#import "ATVFMusicPlayer.h"
#import "ATVFPlayerManager.h"
#import "BRMusicNowPlayingController+SetPlayer.h"
#import "ATVFMediaAsset.h"
#import "ATVFPlaylistAsset.h"
#import "config.h"
#import <BackRow/BREvent.h>
#import "ATVFContextMenu.h"
#import "ATVFPreferences.h"
#import "ATVFPlaylistPlayer.h"
#import "ATVFMetadataPreviewController.h"
#import "ATVFPlacesContents.h"
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>
#import <SapphireCompatClasses/SapphireDVDLoadingController.h>
#import "ATVFVideoPlayerMenu.h"
#import "ATVFMusicNowPlayingController.h"

@interface ATVFileBrowserController (Private)
-(BOOL)getUISounds;
-(void)setUISounds:(BOOL)sounds;
-(void)_resetDividers;
@end

// compatilbility
@interface BRSettingsFacade (AppleTV11Compatibility)
-(BOOL)UISoundsEnabled;
-(void)setUISoundsEnabled:(BOOL)fp8;
+(id)sharedInstance;
@end

@interface BRMediaPreviewControllerFactory (FRCompat)
+(id)previewControlForAssets:assets withDelegate:delegate;
@end

@interface BRMusicPlaybackStartupController
+(id)alloc;
@end

@interface BRMediaPreviewControlFactory
+(id)factory;
-(id)previewControlForAssets:(id)fp8;
@end

// ATV 2.2 compats
@interface BRMediaPlayerController (ATV22Compat)
+(id)controllerForPlayer:(id)player;
-(void)setPlayerDelegate:(id)delegate;
-(void)setResumeMenuDisabled:(BOOL)disabled;
@end

@interface BRMediaPlayer (ATV22Compat)
-(double)elapsedTime;
-(BOOL)setMedia:(id)asset inTrackList:(id)tracklist error:(NSError **)error;
@end

@interface BRMediaMenuController (compat)
-(void)controlWasActivated;
@end

@implementation ATVFileBrowserController

// create our menu!
-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory {
  return [self initWithScene:scene forDirectory:directory useNameForTitle:YES];
}

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory useNameForTitle:(BOOL)useFolderName {
  //LOG(@"In ATVFileBrowserController for Directory: %@", directory);
  [super initWithScene:scene];
  
  [self addLabel:ATVFileBrowserControllerLabel];
  
  if(useFolderName) {
    NSString *title = [directory lastPathComponent];
    [self setListTitle:title];
    _initialController = NO;
  } else {
    [self setListTitle:BRLocalizedString(@"Files", "ATVFiles app name (should match CFBundleName)")];
    _initialController = YES;
  }
  
  _directory = directory;
  [_directory retain];
  _contents = [[ATVFDirectoryContents alloc] initWithScene:scene forDirectory:directory];
  [[self list] setDatasource:_contents];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMountsDidChangeNotification:) name:ATVFMountsDidChangeNotification object:[[self list] datasource]];

  // reset the dividers
  [self _resetDividers];
  
  _restoreSampleRate = NO;

  _currentPlaylist = nil;
  _currentPlaylistIndex = 0;
  _inPlaylistPlayback = NO;

  return self;
}

// Initialize with places menu
-(ATVFileBrowserController *)initWithScene:(id)scene usePlacesTitle:(BOOL)usePlacesTitle {
  [super initWithScene:scene];
  [self addLabel:ATVFileBrowserControllerLabel];
  
  NSString *title;
  enum kATVFPlacesMode mode;
  
  if(usePlacesTitle) {
    title = BRLocalizedString(@"Places", "Places menu title and option");
    mode = kATVFPlacesModeFull;
    _initialController = NO;
  } else {
    title = BRLocalizedString(@"Files", "ATVFiles app name (should match CFBundleName)");
    
    NSString *modePref = [[ATVFPreferences preferences] stringForKey:kATVPrefPlacesMode];
    if([modePref isEqual:kATVPrefPlacesModeVolumes]) {
      mode = kATVFPlacesModeVolumesOnly;
    } else if([modePref isEqual:kATVPrefPlacesModeEnabled]) {
      mode = kATVFPlacesModeFull;
    }
    _initialController = YES;
  }
  
  [self setListTitle:title];
  
  _directory = @"x-atvfiles-places://";
  [_directory retain];
  _contents = [[ATVFPlacesContents alloc] initWithScene:scene mode:mode];
  [[self list] setDatasource:_contents];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMountsDidChangeNotification:) name:ATVFMountsDidChangeNotification object:[[self list] datasource]];

  // reset the dividers
  [self _resetDividers];
  
  _restoreSampleRate = NO;
  
  _currentPlaylist = nil;
  _currentPlaylistIndex = 0;
  _inPlaylistPlayback = NO;

  return self;
}

// -(BOOL)isVolatile {
//   LOG(@"In -ATVFileBrowserController isVolatile");
//   return YES;
// }

-(void)setInitialController:(BOOL)initial {
  _initialController = initial;
}

-(void)dealloc {
  //LOG(@"In ATVFileBrowserController -dealloc, %@", _directory);
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  //LOG(@"Contents release");
  [_contents release];
  //LOG(@"Directory release");
  [_directory release];
  //LOG(@"Super release");
  
  [_currentPlaylist release];
  
  [super dealloc];  
}

-(long)defaultIndex {
  return [[[self list] datasource] defaultIndex];
}

// handler when a menu item is clicked
- (void)itemSelected:(long)index {
  // get the ATVFMediaAsset for the index
  id asset = [[[self list] datasource] mediaForIndex:index];
  
  LOG(@"Asset item selected: %@", [asset mediaURL]);

  // either go to a folder or play
  if([asset isDirectory]) { // asset is folder
    // QUICK AND DIRTY HACK HERE
#ifdef ENABLE_VIDEO_TS
    if([[[asset mediaURL] lastPathComponent] isEqualToString:@"VIDEO_TS"]) {
      LOG(@"DVD VIDEO_TS: %@", asset);
      [self playAsset:asset];
    } else {
#endif // ENABLE_VIDEO_TS
      // load the next controller
      NSString *theDirectory = [[NSURL URLWithString:[asset mediaURL]] path];
      ATVFileBrowserController *folder = [[[ATVFileBrowserController alloc] initWithScene:[self scene] forDirectory:theDirectory] autorelease];
      [folder setListIcon:[self listIcon]];
      [[self stack] pushController:folder];
#ifdef ENABLE_VIDEO_TS
    }
#endif ENABLE_VIDEO_TS
  } else if([asset isPlaylist]) {
    _inPlaylistPlayback = YES;
    [self playPlaylist:asset];
  } else {
    _inPlaylistPlayback = NO;
    [self playAsset:asset];
  }
}

-(void)playPlaylist:(ATVFPlaylistAsset *)asset {
  LOG_MARKER;
  
  ATVFPlayerType playerType = [ATVFPlayerManager playerTypeForAsset:[[asset playlistContents] objectAtIndex:0]];
  if(playerType == kATVFPlayerMusic) {
    // just tell the player it's a playlist
    id player = [ATVFPlayerManager playerForType:kATVFPlayerMusic];
    [player setPlaylist:asset];
    id controller;

    if([SapphireFrontRowCompat usingFrontRow])
      controller = [[[ATVFMusicNowPlayingController alloc] init] autorelease];
    else
      controller = [[[BRMusicNowPlayingController alloc] initWithScene:[self scene]] autorelease];
    
    [controller setPlayer:player];
    [[self stack] pushController:controller];
    [player initiatePlayback:nil];
    [player setDelegate:self];
    [(BRMediaPlayer *)player play];
    
  } else {
    // set up video player here
    id player = [ATVFPlayerManager playerForType:kATVFPlayerVideo];
    id controller;
    NSError *error = nil;
    
    // set up video player here
    ATV_22 {
      LOG(@"ATV2.2 Video Playlist playback");
      _inPlaylistPlayback = YES;
      _currentPlaylistIndex = 0;
      _currentPlaylist = [asset retain];
      
      [self playAsset:[[_currentPlaylist playlistContents] objectAtIndex:0] withResume:NO];
      return;
      
    } else {
      LOG(@"Video playback without TrackList");
      [player setMedia:asset error:&error];
    }
    
    if(error) {
      ELOG(@"Error setting player asset: %@", error);
    }
    
    LOG_MARKER;
    
    // find the right class
    ATV_22 {
      LOG_MARKER;
      
      // ATV 2.2
      controller = [BRMediaPlayerController controllerForPlayer:player];
    } else {
      LOG_MARKER;
      
      if([SapphireFrontRowCompat usingFrontRow])
        controller = [[[BRVideoPlayerController alloc] init] autorelease];
      else
        controller = [[[BRVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    }
    
    LOG(@"Controller: %@", controller);
    
    LOG_MARKER;
    
    [controller addLabel:@"atvfiles-video-player"];
    
    ATV_22 [controller setPlayerDelegate:self];
    else   [controller setDelegate:self];
    
    ATV_22 [controller setResumeMenuDisabled:NO]; // ATV22
    else   [controller setAllowsResume:YES];
    
    NOT_ATV_22 [controller setVideoPlayer:player];
    
    LOG_MARKER;
    
    // stop audio playback
    //[[ATVFPlayerManager musicPlayer] stop];
    
    [[self stack] pushController:controller];
  }
}

-(void)controlWasActivated {
  LOG_MARKER;
  
  // ATV22 hack in playlist next offset stuff here.
  ATV_22 {
    if(_inPlaylistPlayback) {
      NSArray *contents = [_currentPlaylist playlistContents];

      _currentPlaylistIndex++;
      if(_currentPlaylistIndex < [contents count]) {
        id asset = [contents objectAtIndex:_currentPlaylistIndex];
        
        if(asset) {
          LOG(@"Playlist playback: %d, %@", _currentPlaylistIndex, asset);
          [self playAsset:asset withResume:NO];
          return;
        }
      } 
      
      LOG(@"Done playback of playlist!");
      [_currentPlaylist release];
      _currentPlaylist = nil;
      _inPlaylistPlayback = NO;
    }
  }

  [super controlWasActivated];
}

#if 0 // ATV2.2 DEMO
-(void)newPlayAsset:(ATVFMediaAsset *)asset {
  NSError *error = nil;
  
  // player
  id player = [[BRQTKitVideoPlayer alloc] init];
  BOOL result = [player setMedia:asset inTrackList:[NSArray arrayWithObject:asset] error:&error];
  LOG(@"Player: (%@)%@, result=%d, error=%@", [player class], player, result, error);
  
  // controller
  id controller = [BRMediaPlayerController controllerForPlayer:player];
  LOG(@"Controller: (%@)%@", [controller class], controller);
  
  // push it!
  [[self stack] pushController:controller];
  LOG(@"Pushed!");
}
#endif

// handle playback of an asset
-(void)playAsset:(ATVFMediaAsset *)asset {
  [self playAsset:asset withResume:YES];
}

-(void)playAsset:(ATVFMediaAsset *)asset withResume:(BOOL)withResume{
  LOG_MARKER;
  
  // play it here
  NSError *error = nil;

#if 0
  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) {
    //LOG(@"Enabling AC3 Passthrough...");
    // set the audio output sample rate as appropriate
    // _previousPassthroughPreference = [ATVFCoreAudioHelper getPassthroughPreference];
    _previousSoundEnabled = [self getUISounds];
    [self setUISounds:NO];
    // [ATVFCoreAudioHelper setPassthroughPreference:kCFBooleanTrue];
  } // ac3 passthrough setup
#endif
  
  // get the player for this asset
  ATVFPlayerType playerType = [ATVFPlayerManager playerTypeForAsset:asset];
  id player = [ATVFPlayerManager playerForType:playerType];
  LOG(@"Player type: %d, player: (%@)%@", playerType, [player class], player);
  
  id controller;
#ifdef ENABLE_VIDEO_TS
  if(playerType == kATVFPlayerDVD) {
    // we ignore whatever player is here...
    // borrowed from Sapphire :)
    NSString *assetPath = [[[NSURL URLWithString:[asset mediaURL]] path] stringByDeletingLastPathComponent];
    LOG(@"Asset Path: %@", assetPath);
    BRDVDMediaAsset *dvdAsset = [[BRDVDMediaAsset alloc] initWithPath:assetPath];
    LOG(@"Asset: %@", dvdAsset);
    LOG(@" _urlToPreview: %@", [dvdAsset _urlToPreview]);
    controller = [[SapphireDVDLoadingController alloc] initWithScene:[self scene] forAsset:dvdAsset];
    [dvdAsset release];
    [[self stack] pushController:controller];
    [controller retain];
    LOG(@"Controller: %@", controller);
  } else 
#endif // ENABLE_VIDEO_TS
  
    LOG_MARKER;
  
  if(playerType == kATVFPlayerMusic) {
    LOG_MARKER;
    
    // set up music player here
    if([SapphireFrontRowCompat usingFrontRow])
      controller = [[[ATVFMusicNowPlayingController alloc] init] autorelease];
    else
      controller = [[[BRMusicNowPlayingController alloc] initWithScene:[self scene]] autorelease];

    [controller setPlayer:player];
    
    // We call inTracklist and not inTrackList here because a music player is our own custom class.
    [player setMedia:asset inTracklist:[NSMutableArray arrayWithObject:asset] error:&error];
    [player setDelegate:self];
    if(error) {
      ELOG(@"Unable to set player with error: %@", error);
      return;
    } else {
      [player initiatePlayback:&error];
      if(error) ELOG(@"Error initiating playback: %@", error);
    }
  } else if(playerType == kATVFPlayerVideo) {
    NSError *error = nil;
    if([asset isStack]) [asset _prepareStack:&error];
    LOG(@"Stacked: %@", error);
    
    // set up video player here
    ATV_22 {
      LOG(@"Video playback with TrackList");
      [player setMedia:asset inTrackList:[NSArray arrayWithObject:asset] error:&error];
    } else {
      LOG(@"Video playback without TrackList");
      [player setMedia:asset error:&error];
    }
    
    LOG_MARKER;
    
    // find the right class
    ATV_22 {
      LOG_MARKER;
      
      // ATV 2.2
      controller = [BRMediaPlayerController controllerForPlayer:player];
    } else {
      LOG_MARKER;
      
      if([SapphireFrontRowCompat usingFrontRow])
        controller = [[[BRVideoPlayerController alloc] init] autorelease];
      else
        controller = [[[BRVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    }
    
    LOG(@"Controller: %@", controller);
    
    LOG_MARKER;
    
    [controller addLabel:@"atvfiles-video-player"];

    ATV_22 [controller setPlayerDelegate:self];
    else   [controller setDelegate:self];
    
    ATV_22 [controller setResumeMenuDisabled:!withResume]; // ATV22
    else   [controller setAllowsResume:withResume];
    
    NOT_ATV_22 [controller setVideoPlayer:player];
    
    LOG_MARKER;
    
    // stop audio playback
    //[[ATVFPlayerManager musicPlayer] stop];
  }
  
  [[self stack] pushController:controller];
  
  LOG_MARKER;
  
  // id result = [controller blurredVideoFrame];
  // LOG(@"Blurred Video Frame: (%@)%@", [result class], result);
  
  if(playerType == kATVFPlayerMusic) 
    [(ATVFMusicPlayer *)player play];
}

// ATV2.2 delegates, just call below
-(void)menuActionForPlayer:(BRMediaPlayer *)player {
  LOG_MARKER;

  double elapsedTime = [player elapsedTime];
  [[player media] setBookmarkTimeInSeconds:(long)elapsedTime];
  
  id controller = [[self stack] peekController];
  [self menuEventActionForPlayerController:controller];
}

-(void)playerEndedForPlayer:(BRMediaPlayer *)player {
  LOG_ARGS(@"player:(%@)%@", [player class], player);

  double elapsedTime = [player elapsedTime];
  [[player media] setBookmarkTimeInSeconds:(long)elapsedTime];
}

// video player delegates
-(void)playerStopped:(BRVideoPlayerController *)controller {
  LOG(@"In -playerStopped");
  [controller _updateResumeTime];
  
  [[self stack] popToController:self];
}

-(void)menuEventActionForPlayerController:(BRVideoPlayerController *)controller {
  if([controller respondsToSelector:@selector(_updateResumeTime)])
    [controller _updateResumeTime];
  
  if([[ATVFPreferences preferences] boolForKey:kATVPrefUsePlaybackMenu]) {
    // show the menu
    // get the menu
    ATVFVideoPlayerMenu *menu;
    BRMediaPlayer *player;
    ATV_22 player = [controller player];
    else   player = [controller videoPlayer];
    
    if([self respondsToSelector:@selector(scene)]) // ATV
      menu = [[[ATVFVideoPlayerMenu alloc] initWithScene:[self scene] player:player controller:controller] autorelease];
    else // 10.5
      menu = [[[ATVFVideoPlayerMenu alloc] initWithScene:[BRRenderScene sharedInstance] player:player controller:controller] autorelease];
    
    [menu addLabel:@"net.ericiii.atvfiles.playback-context-menu"];
    
//    if([SapphireFrontRowCompat usingTakeTwoDotTwo])
    ATV_22 [player pause];
    
    [[self stack] swapController:menu];
  } else {
    [[self stack] popToController:self];
  }
}

#if 0
// this just restores the sample rate and passthrough preference
-(void)resetSampleRate {
  if(_restoreSampleRate) {
    //LOG(@"Restoring sample rate to %f", _previousSampleRate);
    // reset sample rate
    if(![ATVFCoreAudioHelper setSystemSampleRate:_previousSampleRate]) {
      ELOG(@"Unable to restore sample rate");
    }
    
    // restore preference
    [ATVFCoreAudioHelper setPassthroughPreference:_previousPassthroughPreference];
    if(_previousPassthroughPreference) {
      CFRelease(_previousPassthroughPreference);
      _previousPassthroughPreference = nil;
    }
    
    _restoreSampleRate = NO;
  }
}
#endif

// 10.5
-(id)previewControlForItem:(long)index {
  LOG(@"In previeWControlForItem:%d", index);
  return [self previewControllerForItem:index];
}

// method to display a preview controller
-(id)previewControllerForItem:(long)index {
  LOG(@"In previewControllerForItem:%d", index);
  //return nil; // FIXME
  
  ATVFMediaAsset *asset = [[[self list] datasource] mediaForIndex:index];
  
  if(([asset isDirectory] && ![asset hasCoverArt]) || [asset isPlaylist]) {
    LOG(@" *** Directory or playlist asset, getting asset list for parade...");
    // asset parade
    NSArray *contents = nil;
    
    if([asset isPlaylist]) {
      contents = [(ATVFPlaylistAsset *)asset playlistContents];
    } else if([asset isDirectory]) {
      if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableFolderParades]) {
        NSString *theDirectory = [[NSURL URLWithString:[asset mediaURL]] path];
        contents = [[[[ATVFDirectoryContents alloc] initWithScene:[self scene] forDirectory:theDirectory includeDirectories:NO playlists:NO withSorting:NO] autorelease] assets];
      }
    }
    
    if(contents) {
      LOG(@" *** -> Contents: %@", contents);
      
      id result = nil;
      
      NSArray *filteredContents = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hasCoverArt == YES"]];
      LOG(@"Filtered contents: %@", filteredContents);
      
      // Only show if it's not an empty folder
      if([filteredContents count] > 0) {
        LOG(@"@@A");
        
        // ATV2.1: This is now BRMediaPreviewControlFactory, and it's not a singleton, and doesn't take a delegate.
        Class klass;
        if(klass = NSClassFromString(@"BRMediaPreviewControlFactory"))
          result = [[klass factory] previewControlForAssets:filteredContents];
        else if([SapphireFrontRowCompat usingFrontRow])
          result = [BRMediaPreviewControllerFactory previewControlForAssets:filteredContents withDelegate:self];
        else
          result = [BRMediaPreviewControllerFactory previewControllerForAssets:filteredContents withDelegate:self scene:[self scene]];
        // result = [BRMediaPreviewControllerFactory _paradeControllerForAssets:contents delegate:self scene:[self scene]];
        LOG(@"@@B");
        
        if(![SapphireFrontRowCompat usingFrontRow]) {
          if([result isKindOfClass:NSClassFromString(@"BRCoverArtPreviewController")]) {
            // NOTE: BUG WORKAROUND
            // This is a workaround for the ATV 1.1 BackRow bug(?) that will not refresh images in the
            // asset list of this controller, but instead just duplicate the list.  This basically
            // forces a refresh of the preview controller on an appropriate notification.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePreviewController) name:@"BRAssetImageUpdated" object:nil];
          }
        } else {
          [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BRAssetImageUpdated" object:nil];
        }
      }
      
      LOG(@"@@C");
      
      LOG(@" *** Done cover art gathering : (%@)%@", [result class], result);
      return result;
    } else {
      LOG(@" *** Done cover art gathering -> nothing ");
      return nil;
    }
  } else {
    //LOG(@"Normal asset without parade...");
    // traditional display
    ATVFMetadataPreviewController *result = [[[ATVFMetadataPreviewController alloc] initWithScene:[self scene]] autorelease];
    //id result = [[[ATVFMetadataPreviewController alloc] init] autorelease];
    [result setAsset:[[[self list] datasource] mediaForIndex:index]];
    //[result activate];
    
    return result;
  }
}

// Hook for right menu click
-(BOOL)brEventAction:(BREvent *)action {
  //LOG(@"in -brEventAction:(%@)%@", [action class], action);
  switch((uint32_t)([action page] << 16 | [action usage])) {
    BREVENT_RIGHT:; 
      if([[self stack] peekController] != self)
        return NO;
      
      // context menu
      BRListControl *list = [self list];
      ATVFMediaAsset *asset = [_contents mediaForIndex:[list selection]];

      //LOG(@"Context menu button pressed!");
      //LOG(@" List: (%@)%@", [list class], list);
      //LOG(@"  Selected: %d", [list selection]);
      
      //LOG(@" Selected asset: (%@)%@ <%@>", [asset class], asset, [asset mediaURL]);
      
      ATVFContextMenu *contextMenu = [[[ATVFContextMenu alloc] initWithScene:[self scene] forAsset:asset] autorelease];
      [contextMenu setListIcon:[self listIcon]];
      [[self stack] pushController:contextMenu];
      
      return YES;
      break;
  }
  
  
  return [super brEventAction:action];
}

// this is called before redrawing it after something else has been shown.
// the other controller is still on top of the stack now
// refresh the directory here.
-(void)willBeExhumed {
  [self refreshMenu];

#if 0
  [self resetSampleRate];

  if([[ATVFPreferences preferences] boolForKey:kATVPrefEnableAC3Passthrough]) {
    [self setUISounds:_previousSoundEnabled];
    // [ATVFCoreAudioHelper setPassthroughPreference:_previousPassthroughPreference];
  } // ac3 passthrough setup
#endif
  
# ifdef DEBUG
  [self _addDebugTag];
# endif
  [super willBeExhumed];

}

-(void)wasExhumed {
  ATV_23 {
    [self refreshMenu];
    [super wasExhumed];
  }
}

#ifdef DEBUG
// called before hiding the menu
// just remove our test overlay
-(void)willBeBuried {
  [self _removeDebugTag];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[[self list] datasource]];
  
  [super willBeBuried];
}

-(void)willBePushed {
  [self _addDebugTag];
  [super willBePushed];
}

-(void)willBePopped {
  if(_initialController) {
    LOG(@"In willBePopped, stopping music playback");
    
    // stop playing
    //[[ATVFPlayerManager musicPlayer] stop];
  }
  [self _removeDebugTag];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[[self list] datasource]];
  
  [super willBePopped];
}

-(void)_addDebugTag {
  return;
  
  // atv only, outdated.
  if(!_debugTag) {
    // create the tag
    _debugTag = [BRTextLayer layerWithScene:[self scene]];
    NSString *lblText = [[NSString stringWithString:@"DEBUG BUILD\n"] stringByAppendingString:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSAttributedString *lbl = [[[NSAttributedString alloc] initWithString:lblText attributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]] autorelease];
    [_debugTag setAttributedString:lbl];
/*    LOG(@"DEBUG TAG: %@, size: %@, max: %@", _debugTag, NSStringFromSize([_debugTag renderedSize]), NSStringFromSize([_debugTag maxSize]));*/
    [_debugTag retain];
    
    // figure out where to put it
    NSRect displayFrame = [[self masterLayer] frame];
    NSSize labelSize = [_debugTag renderedSize];
    float height = labelSize.height;
    float width = labelSize.width;
    float x = (displayFrame.size.width * 0.05);
    float y = displayFrame.size.height - ((displayFrame.size.height * 0.05) + height);
    NSRect labelFrame = NSMakeRect(x, y, width, height);

    // and add it to the display
    [_debugTag setFrame:labelFrame];
    [[[self scene] root] insertSublayer:_debugTag above:[self masterLayer]];
  }
}

-(void)_removeDebugTag {
  return;
  
  if(_debugTag) {
    // rmeove it from the render scene
    [_debugTag removeFromSuperlayer];
    // and let go of it
    [_debugTag release];
    _debugTag = nil;
  }
}
#endif

#if 0
// helpers for toggling ui sounds.
// these changed in 1.0 to 1.1, from
//  [BRSettingsFacade settingsFacade] soundEnabled]
// to
//  [BRSettingsFacade sharedInstance] UISoundsEnabled]
-(BOOL)getUISounds {
#ifdef ENABLE_1_0_COMPATABILITY
  if([BRSettingsFacade respondsToSelector:@selector(settingsFacade)]) {
    // 1.0
    return [[BRSettingsFacade settingsFacade] soundEnabled];
    
  } else if([BRSettingsFacade instancesRespondToSelector:@selector(UISoundsEnabled)]) {
    // 1.1
#endif
    return [[BRSettingsFacade sharedInstance] UISoundsEnabled];
#ifdef ENABLE_1_0_COMPATABILITY
  } else {
    ELOG(@"Running on unknown Apple TV OS, can't get UI sound settings!");
    return YES;
  }
#endif
}

-(void)setUISounds:(BOOL)sounds {
#ifdef ENABLE_1_0_COMPATABILITY
  if([BRSettingsFacade respondsToSelector:@selector(settingsFacade)]) {
    // 1.0
    [[BRSettingsFacade settingsFacade] setSoundEnabled:sounds];
  } else if([BRSettingsFacade instancesRespondToSelector:@selector(UISoundsEnabled)]) {
#endif
    // 1.1
    [[BRSettingsFacade sharedInstance] setUISoundsEnabled:sounds];
#ifdef ENABLE_1_0_COMPATABILITY
  } else {
    ELOG(@"Running on unknown Apple TV OS, can't set UI sound settings!");
  }
#endif
}
#endif

-(void)refreshMenu {
  //id selectedObject = [self selectedObject];
  [[[self list] datasource] refreshContents];
  [[self list] reload];
  [self _resetDividers];
  //[SapphireFrontRowCompat renderScene:[self scene]];
  [self refreshControllerForModelUpdate];
  
  //[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[[self list] datasource]];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMountsDidChangeNotification:) name:ATVFMountsDidChangeNotification object:[[self list] datasource]];
  
  // reset the dividers

  // force a redraw
  //[self setSelectedObject:selectedObject];
  //[[self list] setRenderSelection:[[self list] renderSelection]];
  //[SapphireFrontRowCompat renderScene:[self scene]];
}

-(void)_handleMountsDidChangeNotification:(NSNotification *)notification {
  LOG(@"In -_handleMountsDidChangeNotification: %@", notification);
  
  [self refreshMenu];
}

-(void)_resetDividers {
  [[self list] removeDividers];
  long separatorIndex = [[[self list] datasource] separatorIndex];
  if(separatorIndex != -1) [SapphireFrontRowCompat addDividerAtIndex:separatorIndex toList:[self list]];
  // [[self list] addDividerAtIndex:separatorIndex];  
}

// MUSIC PLAYER DELEGATE
-(void)musicPlaybackStopped {
  LOG(@"In -ATVFileBrowserController musicPlaybackStopped");
  
  if([[[self stack] peekController] isMemberOfClass:[ATVFMusicNowPlayingController class]])
    [[self stack] popToController:self];
}
@end
