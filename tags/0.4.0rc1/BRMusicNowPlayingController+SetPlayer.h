//
//  BRMusicNowPlayingController+SetPlayer.h
//  ATVFiles
//
//  Created by Eric Steil III on 6/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BRMusicNowPlayingController.h>

@interface BRMusicNowPlayingMonitor (ATVFSetPlayer)
-(BRMusicPlayer *)player;
-(void)setPlayer:(BRMusicPlayer *)player;
@end

@interface BRMusicNowPlayingController (ATVFSetPlayer)
-(BRMusicPlayer *)player;
-(void)setPlayer:(BRMusicPlayer *)player;
@end
