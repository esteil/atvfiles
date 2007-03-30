//
//  ATVFileBrowserController.m
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATVFileBrowserController.h"


@implementation ATVFileBrowserController

-(ATVFileBrowserController *)initWithScene:(id)scene forDirectory:(NSString *)directory {
  [super initWithScene:scene];
  
  NSString *title = [directory lastPathComponent];
  [self setListTitle:title];
  
  _contents = [[ATVDirectoryContents alloc] initWithScene:scene forDirectory:directory];
  [[self list] setDatasource:_contents];
  
  return self;
}

- (void)itemSelected:(long)fp8 {
  id asset = [[[self list] datasource] mediaForIndex:fp8];
  
#ifdef DEBUG
  NSLog(@"Asset item selected: %@", [asset mediaURL]);
#endif  

  if([asset isDirectory]) { // asset is folder
    NSString *theDirectory = [[NSURL URLWithString:[asset mediaURL]] path];
    ATVFileBrowserController *folder = [[[ATVFileBrowserController alloc] initWithScene:[self scene] forDirectory:theDirectory] autorelease];
    
    [_stack pushController:folder];

  } else {
    // play it here
    NSError *error = nil;

/*    id player = [[[BRQTKitVideoPlayer alloc] init] autorelease];*/
    id player = [BRMediaPlayerManager playerForMediaAsset:asset error:&error];
    [player setMedia:asset error:&error];
/*    NSLog(@"Player: (%@)%@, error %@", [player class], player, error);*/

    // choose the right controller for video or other
    id controller;
    controller = [[[BRVideoPlayerController alloc] initWithScene:[self scene]] autorelease];
    [controller setVideoPlayer:player];
    [_stack pushController:controller];
  }
}

// this is called before redrawing it after something else has been shown.
// refresh the directory here.
-(void)willBeExhumed {
  [[[self list] datasource] refreshContents];
  [[self list] reload];
  [super willBeExhumed];
}
@end
