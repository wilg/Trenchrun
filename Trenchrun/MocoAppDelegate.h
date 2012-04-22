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

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSProgressIndicator *panWheel;
@property (assign) IBOutlet NSProgressIndicator *tiltWheel;
@property (assign) IBOutlet NSTextField *panText;
@property (assign) IBOutlet NSTextField *tiltText;

@end
