//
//  MocoTimelineTrackView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTrack.h"
#import "MocoTimelineTrackView.h"
#import "MocoLineGraphView.h"

@interface MocoTimelineTrackView ( /* class extension */ ) {
@private

}

@end


@implementation MocoTimelineTrackView
@synthesize controller, lineGraphView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        lineGraphView = [[MocoLineGraphView alloc] initWithFrame:self.bounds];
        [self addSubview:lineGraphView positioned:NSWindowAbove relativeTo:nil];

//        self.canDrawConcurrently = YES;

//        self.wantsLayer = YES;
//        self.layer.shouldRasterize = YES;

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    lineGraphView.frame = self.bounds;
//    NSLog(@"track view draw rect");
    [lineGraphView setNeedsDisplay:YES];
        
    [NSGraphicsContext saveGraphicsState];
//    
//    // Create the shadow below and to the right of the shape.
//    NSShadow* theShadow = [[NSShadow alloc] init];
//    [theShadow setShadowOffset:NSMakeSize(10.0, -10.0)];
//    [theShadow setShadowBlurRadius:3.0];
//    
//    // Use a partially transparent color for shapes that overlap.
//    [theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
//    
//    [theShadow set];
    
    NSBezierPath* thePath = [NSBezierPath bezierPath];
    [thePath appendBezierPathWithRoundedRect:self.bounds xRadius:0 yRadius:0];
    
    
    
    NSGradient* aGradient = [[NSGradient alloc]
                              initWithColorsAndLocations:[NSColor colorWithCalibratedHue:0.622 saturation:0.785 brightness:0.940 alpha:1.000], (CGFloat)0.0,
                              [NSColor colorWithCalibratedHue:0.622 saturation:0.785 brightness:0.740 alpha:1.000], (CGFloat)0.75,
                              nil];
    
    [aGradient drawInBezierPath:thePath angle:-90.0];

    [[NSColor colorWithCalibratedHue:0.601 saturation:0.739 brightness:0.090 alpha:1.000] setStroke];
    [thePath stroke];

    
    // Draw your custom content here. Anything you draw
    // automatically has the shadow effect applied to it.
    
    [NSGraphicsContext restoreGraphicsState];

//    
//    [[NSColor yellowColor] set];
//    NSRectFill(self.bounds);

}

@end
