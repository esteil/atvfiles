//
// ATVFTheme.h
// ATVFiles theme info (mainly, Disabled stuff)
//
// Created by Eric Steil III on 2/18/08.
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

#import <Cocoa/Cocoa.h>
#import <BackRow/BackRow.h>

@interface ATVFTheme : BRSingleton {
  NSDictionary *disabledMenuItemAttributes;
}

-(NSDictionary *)disabledMenuItemAttributes;

@end
