//
//  BRXcodeSFF.m
//  XcodeSFF
//
//  Created by Rudy Richter on 11/24/09.
//  Copyright 2009 Rudy Richter. All rights reserved.
//

#import "BRXcodeSFF.h"
#import <objc/runtime.h>

static BRXcodeSFF *shared = nil;
static Class BRpbxsimplefinder = nil;
@implementation BRXcodeSFF

+ (void)load 
{
	//the only reason we perform this check is because we don't want to load our menu hacking into xcodebuild
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Xcode"])
		[BRXcodeSFF sharedInstance];
}

+ (BRXcodeSFF*)sharedInstance
{
	if(!shared)
		shared = [[BRXcodeSFF alloc] init];
	return shared;
}

- (id)init
{
	if((self = [super init]))
	{
		BRpbxsimplefinder = NSClassFromString(@"PBXSimpleFinder");
		Method sharedSimpleFinder = class_getClassMethod(BRpbxsimplefinder, @selector(sharedSimpleFinder));
		Method showSimpleFind = class_getInstanceMethod(BRpbxsimplefinder, @selector(showSimpleFind:));
		if(BRpbxsimplefinder && sharedSimpleFinder && showSimpleFind)
		{
			NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
		
			NSMenuItem *item = [self findFind:mainMenu];
			if(item)
			{
				[item setAction:@selector(singleFileFind:)];
				[item setTarget:self];		
			}
			else 
			{
				NSLog(@"%s: couldn't find the find menu item", __PRETTY_FUNCTION__);
			}

		}
		else 
		{
			NSLog(@"%s: respondsTo(sharedSimpleFinder):%p respondsTo(showSimpleFind:):%p", __PRETTY_FUNCTION__, sharedSimpleFinder, showSimpleFind);		 
		}

	}
	return self;
}

- (IBAction)singleFileFind:(id)sender
{
#pragma unused(sender)
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	id sharedInstance = [BRpbxsimplefinder performSelector:@selector(sharedSimpleFinder)];
	[sharedInstance performSelector:@selector(showSimpleFind:)];
}

- (NSMenuItem*)findFind:(NSMenu*)menu
{
	NSMenuItem *result = nil;

	NSInteger findIndex = [menu indexOfItemWithTarget:NULL andAction:@selector(showIncrementalFindBar:)];
	if(findIndex != -1)
		result = [menu itemAtIndex:findIndex];
	else 
	{
		for(NSMenuItem *item in [menu itemArray])
		{
			//NSLog(@"item: %@ %@ %s", [item title], [item target], sel_getName([item action]));
			if([item submenu])
				result = [self findFind:[item submenu]];
			if(result)
				break;
		}
	}

	return result;
}
@end
