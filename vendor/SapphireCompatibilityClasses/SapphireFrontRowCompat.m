/*
 * SapphireFrontRowCompat.m
 * Sapphire
 *
 * Created by Graham Booker on Oct. 29, 2007.
 * Copyright 2007 Sapphire Development Team and/or www.nanopi.net
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 3 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "SapphireFrontRowCompat.h"
#import <ExceptionHandling/NSExceptionHandler.h>
#import "SapphireButtonControl.h"

/*Yes, this is the wrong class, but otherwise gcc gripes about BRImage class not existing; this removes warnings so no harm*/
@interface SapphireFrontRowCompat (compat)
+ (id)imageWithPath:(NSString *)path;
- (id)downsampledImageForMaxSize:(NSSize)size;
+ (id)imageWithCGImageRef:(CGImageRef)ref;
- (CGImageRef)image;
@end

NSData *CreateBitmapDataFromImage(CGImageRef image, unsigned int width, unsigned int height);

/*Yes, wrong class and other wrong things, just to shut up warnings*/
@interface BRAdornedMenuItemLayer (compat)
+ (id)folderMenuItem;
+ (id)menuItem;
- (void)setTitle:(NSString *)title;
- (void)setRightJustifiedText:(NSString *)text;
- (void)setLeftIconInfo:(BRTexture *)icon;
- (void)setRightIconInfo:(BRTexture *)icon;
@end

@interface BRThemeInfo (compat)
- (id)selectedSettingImage;
@end

@interface BRButtonControl (compat)
- (id)initWithMasterLayerSize:(NSSize)fp8;
@end

@interface BRTextControl (compat)
- (void)setText:(NSString *)text withAttributes:(NSDictionary *)attr;
- (NSRect)controllerFrame;  /*technically wrong; it is really a CGRect*/
@end

@interface NSException (compat)
- (NSArray *)callStackReturnAddresses;
@end

@implementation SapphireFrontRowCompat

static BOOL usingFrontRow = NO;

+ (void)initialize
{
	if(NSClassFromString(@"BRAdornedMenuItemLayer") == nil)
		usingFrontRow = YES;
}

+ (BOOL)usingFrontRow
{
	return usingFrontRow;
}

+ (id)imageAtPath:(NSString *)path
{
	Class cls = NSClassFromString(@"BRImage");
	return [cls imageWithPath:path];
}

+ (BRAdornedMenuItemLayer *)textMenuItemForScene:(BRRenderScene *)scene folder:(BOOL)folder
{
	if(usingFrontRow)
	{
		if(folder)
			return [NSClassFromString(@"BRTextMenuItemLayer") folderMenuItem];
		else
			return [NSClassFromString(@"BRTextMenuItemLayer") menuItem];		
	}
	else
	{
		if(folder)
			return [NSClassFromString(@"BRAdornedMenuItemLayer") adornedFolderMenuItemWithScene:scene];
		else
			return [NSClassFromString(@"BRAdornedMenuItemLayer") adornedMenuItemWithScene:scene];		
	}
}

+ (void)setTitle:(NSString *)title forMenu:(BRAdornedMenuItemLayer *)menu
{
	if(usingFrontRow)
		[menu setTitle:title];
	else
		[[menu textItem] setTitle:title];
}

+ (void)setRightJustifiedText:(NSString *)text forMenu:(BRAdornedMenuItemLayer *)menu
{
	if(usingFrontRow)
		[menu setRightJustifiedText:text];
	else
		[[menu textItem] setRightJustifiedText:text];
}

+ (void)setLeftIcon:(BRTexture *)icon forMenu:(BRAdornedMenuItemLayer *)menu
{
	if(usingFrontRow)
		[menu setLeftIconInfo:[NSDictionary dictionaryWithObjectsAndKeys:
							   icon, @"BRMenuIconImageKey",
							   nil]];
	else
		[menu setLeftIcon:icon];
}

+ (void)setRightIcon:(BRTexture *)icon forMenu:(BRAdornedMenuItemLayer *)menu
{
	if(usingFrontRow)
		 [menu setRightIconInfo:[NSDictionary dictionaryWithObjectsAndKeys:
								 icon, @"BRMenuIconImageKey",
								 nil]];
	else
		[menu setRightIcon:icon];
}

+ (id)selectedSettingImageForScene:(BRRenderScene *)scene
{
	if(usingFrontRow)
		return [[BRThemeInfo sharedTheme] selectedSettingImage];
	else
		return [[BRThemeInfo sharedTheme] selectedSettingImageForScene:scene];
}

+ (NSRect)frameOfController:(id)controller
{
	if(usingFrontRow)
	{
		return [controller controllerFrame];
	}
	else
		return [[controller masterLayer] frame];
}

+ (void)setText:(NSString *)text withAtrributes:(NSDictionary *)attributes forControl:(BRTextControl *)control
{
	if(usingFrontRow)
		[control setText:text withAttributes:attributes];
	else
	{
		if(attributes != nil)
			[control setTextAttributes:attributes];
		[control setText:text];
	}
}

+ (void)addDividerAtIndex:(int)index toList:(BRListControl *)list
{
	if(usingFrontRow)
		[list addDividerAtIndex:index withLabel:@""];
	else
		[list addDividerAtIndex:index];
}

+ (void)addSublayer:(id)sub toControl:(id)controller
{
	if(usingFrontRow)
		[[controller layer] addSublayer:sub];
	else
		[[controller masterLayer] addSublayer:sub];
}

+ (BRHeaderControl *)newHeaderControlWithScene:(BRRenderScene *)scene
{
	if(usingFrontRow)
		return [[BRHeaderControl alloc] init];
	else
		return [[BRHeaderControl alloc] initWithScene:scene];
}

+ (BRButtonControl *)newButtonControlWithScene:(BRRenderScene *)scene  masterLayerSize:(NSSize)size;
{
	if(usingFrontRow)
		return [[SapphireButtonControl alloc] initWithMasterLayerSize:size];
	else
		return [[BRButtonControl alloc] initWithScene:scene masterLayerSize:size];
}

+ (BRTextControl *)newTextControlWithScene:(BRRenderScene *)scene
{
	if(usingFrontRow)
		return [[BRTextControl alloc] init];
	else
		return [[BRTextControl alloc] initWithScene:scene];
}

+ (BRProgressBarWidget *)newProgressBarWidgetWithScene:(BRRenderScene *)scene
{
	if(usingFrontRow)
		return [[BRProgressBarWidget alloc] init];
	else
		return [[BRProgressBarWidget alloc] initWithScene:scene];
}

+ (BRMarchingIconLayer *)newMarchingIconLayerWithScene:(BRRenderScene *)scene
{
	if(usingFrontRow)
		return [[BRMarchingIconLayer alloc] init];
	else
		return [[BRMarchingIconLayer alloc] initWithScene:scene];
}

+ (void)renderScene:(BRRenderScene *)scene
{
	if(!usingFrontRow)
		[scene renderScene];
}

+ (NSArray *)callStackReturnAddressesForException:(NSException *)exception
{
	if([exception respondsToSelector:@selector(callStackReturnAddresses)])
	{
		NSArray *ret = [exception callStackReturnAddresses];
		if([ret count])
			return ret;
	}
	return [[exception userInfo] objectForKey:NSStackTraceKey];
}
@end
