//
//  BRXcodeSFF.m
//  XcodeSFF
//
//  Created by Rudy Richter on 11/24/09.
//  Copyright 2009 Rudy Richter. All rights reserved.
//

#import "BRXcodeSFF.h"
#import <objc/runtime.h>

static Class PBXSimpleFinder = Nil;
static Class DVWindow = Nil;

@implementation BRXcodeSFF

+ (IBAction) singleFileFind:(id)sender
{
#pragma unused(sender)
	
	BOOL isDocWindow = [[NSApp keyWindow] isKindOfClass:DVWindow];
	if (isDocWindow)
	{
		[NSApp sendAction:@selector(showIncrementalFindBar:) to:nil from:self];
	}
	else
	{
		id sharedInstance = [PBXSimpleFinder performSelector:@selector(sharedSimpleFinder)];
		[sharedInstance performSelector:@selector(showSimpleFind:)];
	}
}

+ (NSMenuItem *) findFind:(NSMenu *)menu
{
	NSMenuItem *result = nil;
	
	NSInteger findIndex = [menu indexOfItemWithTarget:NULL andAction:@selector(showIncrementalFindBar:)];
	if (findIndex != -1)
		result = [menu itemAtIndex:findIndex];
	else 
	{
		for (NSMenuItem *item in [menu itemArray])
		{
			//NSLog(@"item: %@ %@ %s", [item title], [item target], sel_getName([item action]));
			if ([item submenu])
				result = [self findFind:[item submenu]];
			if (result)
				break;
		}
	}
	
	return result;
}

+ (BOOL) install
{
	PBXSimpleFinder = NSClassFromString(@"PBXSimpleFinder");
	DVWindow = NSClassFromString(@"DVWindow");
	Method sharedSimpleFinder = class_getClassMethod(PBXSimpleFinder, @selector(sharedSimpleFinder));
	Method showSimpleFind = class_getInstanceMethod(PBXSimpleFinder, @selector(showSimpleFind:));
	if (PBXSimpleFinder && sharedSimpleFinder && showSimpleFind)
	{
		NSMenu *mainMenu = [NSApp mainMenu];
		
		NSMenuItem *item = [self findFind:mainMenu];
		if (item)
		{
			[item setAction:@selector(singleFileFind:)];
			[item setTarget:self];
			return YES;
		}
	}
	
	return NO;
}

+ (void) pluginDidLoad:(NSBundle *)plugin
{
	BOOL success = [self install];
	
	NSString *pluginName = [[[plugin bundlePath] lastPathComponent] stringByDeletingPathExtension];
	NSString *version = [plugin objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (success)
		NSLog(@"%@ %@ loaded successfully", pluginName, version);
	else
		NSLog(@"%@ %@ failed to load", pluginName, version);
}

@end
