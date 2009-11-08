//
//  ATVFTheme.m
//  ATVFiles
//
//  Created by Eric Steil III on 2/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATVFTheme.h"

static ATVFTheme *__ATVFTheme_singleton = nil;

@implementation ATVFTheme

-(ATVFTheme *)init {
  [super init];
  disabledMenuItemAttributes = nil;
  return self;
}

-(NSDictionary *)disabledMenuItemAttributes {
  // preapre our own
  if(!disabledMenuItemAttributes) {
    disabledMenuItemAttributes = [[[BRThemeInfo sharedTheme] menuItemTextAttributes] mutableCopy];
    
    LOG_ARGS(@"Color: %@", [disabledMenuItemAttributes valueForKey:@"NSColor"]);
    
    NSDictionary *greyInput;
    if([[BRThemeInfo sharedTheme] respondsToSelector:@selector(textEntryGlyphGrayAttributes)]) {
      greyInput = [[BRThemeInfo sharedTheme] textEntryGlyphGrayAttributes];
    } else {
      // ATV3
      greyInput = [[BRThemeInfo sharedTheme] metadataLabelAttributes];
    }
    
    [disabledMenuItemAttributes setValue:[greyInput valueForKey:@"NSColor"] forKey:@"NSColor"];
    [disabledMenuItemAttributes retain];
  }
  
  return disabledMenuItemAttributes;
}


+(id)singleton {
  return __ATVFTheme_singleton;
}

+(void)setSingleton:(id)singleton {
  __ATVFTheme_singleton = (ATVFTheme *)singleton;
}


@end
