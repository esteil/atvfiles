//
//  ATVFPlayerManager.h
//  ATVFiles
//
//  Created by Eric Steil III on 7/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
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
