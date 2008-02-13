//
// ATVFilesAppliance-BRAppliance.m
// ATVFiles appliance methods for ATV2.
//
// Created by Eric Steil III on 2/13/08.
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

#import "ATVFilesAppliance.h"
#import "ATVFCoreAudioHelper.h"
#import "ATVFDatabase.h"
#import "ATVFPreferences.h"
#import <objc/objc-class.h>
#import <SapphireCompatClasses/SapphireFrontRowCompat.h>

@interface BRApplianceInfo
+(id)infoForApplianceBundle:(id)bundle;
-(id)applianceCategoryDescriptors;
@end

@interface BRApplianceCategory
+(id)categoryWithName:(NSString *)name identifier:(NSString *)identifier preferredOrder:(float)order;
-(void)setIsStoreCategory:(BOOL)isStoreCategory;
-(void)setIsDefaultCategory:(BOOL)isDefaultCategory;
-(void)setShouldDisplayOnStartup:(BOOL)shouldDisplayOnStartup;
@end

/**
 * This implements the BRAppliance protocol from ATV2.
 */
@implementation ATVFilesAppliance (BRAppliance)

-(id)applianceInfo {
  return [BRApplianceInfo infoForApplianceBundle:[NSBundle bundleForClass:[self class]]];
}

-(id)applianceCategories {
  NSMutableArray *categories = [NSMutableArray array];
  
  NSEnumerator *enumerator = [[[self applianceInfo] applianceCategoryDescriptors] objectEnumerator];
  id obj;
  while((obj = [enumerator nextObject]) != nil) {
    BRApplianceCategory *category = [BRApplianceCategory categoryWithName:[obj valueForKey:@"name"] identifier:[obj valueForKey:@"identifier"] preferredOrder:[[obj valueForKey:@"preferred-order"] floatValue]];
    
    [categories addObject:category];
  }
  return categories;
}

-(id)identifierForContentAlias:(id)fp8 {
  return @"ATVFiles";
}

-(id)controllerForIdentifier:(id)fp8 {
  LOG(@"in -ATVFilesAppliance controllerForIdentifier:(%@)%@", [fp8 class], fp8);
  return [self applianceController];
}

@end
