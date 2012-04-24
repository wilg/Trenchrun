
//
//  MocoAppDelegate.m
//  Timmy Fell Down The Well
//
//  Created by Wil Gieseler on 1/25/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "MocoAppDelegate.h"

@implementation MocoAppDelegate

@synthesize mocoDriver;

- (void)applicationWillTerminate:(NSNotification *)notification {
    [mocoDriver severConnections];
}

@end
