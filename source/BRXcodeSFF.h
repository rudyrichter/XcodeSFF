//
//  BRXcodeSFF.h
//  XcodeSFF
//
//  Created by Rudy Richter on 11/24/09.
//  Copyright 2009 Rudy Richter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRXcodeSFF : NSObject
{
	
}

+ (void)load;
+ (BRXcodeSFF*)sharedInstance;

- (id)init;
- (IBAction)singleFileFind:(id)sender;
- (NSMenuItem*)findFind:(NSMenu*)menu;

@end

