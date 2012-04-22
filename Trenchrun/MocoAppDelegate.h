//
//  MocoAppDelegate.h
//  Timmy Fell Down The Well
//
//  Created by Wil Gieseler on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoDriver.h"

@interface MocoAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet MocoDriver *mocoDriver;
}

@property (readonly) MocoDriver *mocoDriver;

@end
