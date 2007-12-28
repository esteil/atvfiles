//
//  BRMusicNowPlayingController+SetPlayer.m
//  ATVFiles
//
//  Created by Eric Steil III on 6/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BRMusicNowPlayingController+SetPlayer.h"
#include <objc/objc-class.h>

@implementation BRMusicNowPlayingMonitor (ATVFSetPlayer)

-(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
  
	return *(BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
}

-(void)setPlayer:(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
	BRMusicPlayer * *thePlayer = (BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
	
	[*thePlayer release];
	*thePlayer = [player retain];
}

@end

@implementation BRMusicNowPlayingController (ATVFSetPlayer)

-(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");

	return *(BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
}

-(void)setPlayer:(BRMusicPlayer *)player {
	Class myClass = [self class];
	Ivar ret = class_getInstanceVariable(myClass, "_player");
	BRMusicPlayer * *thePlayer = (BRMusicPlayer * *)(((char *)self)+ret->ivar_offset);	
	
	[*thePlayer release];
	*thePlayer = [player retain];
}

@end
