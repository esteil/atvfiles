//
//  ATVFilesAppliance.h
//  ATVFiles
//
//  Created by Eric Steil III on 3/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BRAppliance.h>
#import <BRApplianceManager.h>
#import "ATVFileBrowserController.h"

// this just makes the warnings shut up
@interface NSException (PrivateAddExceptionHandlerStackTrace)
-(void)_addExceptionHandlerStackTrace;
@end

@interface ATVFilesAppliance : BRAppliance {

}

@end
