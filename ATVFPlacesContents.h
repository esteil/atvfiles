//
//  ATVFPlacesContents.h
//  ATVFiles
//
//  Created by Eric Steil III on 12/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFilesAppliance.h"
#import "ATVFMediaAsset.h"
#import "ATVFDirectoryContents.h"

enum kATVFPlacesMode {
  kATVFPlacesModeFull = 1,
  kATVFPlacesModeVolumesOnly = 2
};

@interface ATVFPlacesContents : ATVFDirectoryContents {
  enum kATVFPlacesMode _mode;
}

-(ATVFPlacesContents *)initWithScene:(BRRenderScene *)scene mode:(enum kATVFPlacesMode)mode;

// notification handler
-(void)_mountsDidChange:(NSNotification *)notification;

@end
