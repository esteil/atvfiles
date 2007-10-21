//
//  ATVFVideoPlayerController.h
//  ATVFiles
//
//  This subclasses BRVideoPlayerController and implements better
//  playlist playback and the YouTube-style menu.
//
//  Created by Eric Steil III on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>

@interface ATVFVideoPlayerController : BRVideoPlayerController {

}

-(BOOL)brEventAction:(BREvent *)event;

@end
