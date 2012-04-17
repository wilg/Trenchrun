
//
//  MocoAppDelegate.m
//  Timmy Fell Down The Well
//
//  Created by Wil Gieseler on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "MocoDriver.h"
#import "MocoAppDelegate.h"

@implementation MocoAppDelegate

@synthesize window = _window;
@synthesize panWheel;
@synthesize tiltWheel;
@synthesize panText;
@synthesize tiltText;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thingMoved:) name:@"MocoDriverDidRecieveInput" object:nil];
    
//    mocoDriver = [[MocoDriver alloc] init];

}


- (void)applicationWillTerminate:(NSNotification *)notification {
    [mocoDriver severConnections];
}

- (float)normalizedPercentageFromEncoderValue:(int)encoderValue {
    return (float)(encoderValue % 4096) / 4096.f;
}


- (void)thingMoved:(NSNotification *)notification {
    
    NSLog(@"notification object: %@", notification.object);
    
//    float panPercent = [self normalizedPercentageFromEncoderValue:[[notification.object objectAtIndex:0] intValue]];
//    float tiltPercent = [self normalizedPercentageFromEncoderValue:[[notification.object objectAtIndex:1] intValue]];
//
//    
//    
//    self.panText.stringValue = [NSString stringWithFormat:@"%f", panPercent];
//    self.tiltText.stringValue = [NSString stringWithFormat:@"%f", tiltPercent];
//    
//    [self.panWheel setDoubleValue:panPercent * 100.0];
//    
//    [self.tiltWheel setDoubleValue:tiltPercent * 100.0];
//
    
}


@end
