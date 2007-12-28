//
//  ATVFSettingsController.h
//  ATVFiles
//
//  Created by Eric Steil III on 9/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>
#import "ATVFPreferences.h"
#import "SapphireMenuController.h"

@interface ATVFSettingsController : SapphireMenuController {
  NSMutableArray *_items;
}

-(void)_buildMenu;

@end
