//
//  MocoTimelineTrackView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoTrack.h"
#import "MocoTimelineTrackView.h"
#import "MocoLineGraphView.h"
#import "MocoTimelineView.h"
#import "NSColor+M3Extensions.h"

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
        
        lineGraphView = [[MocoLineGraphView alloc] initWithFrame:NSInsetRect(self.bounds, 1, 1)];
        [self addSubview:lineGraphView positioned:NSWindowAbove relativeTo:nil];

//        self.canDrawConcurrently = YES;

        self.wantsLayer = YES;
//        self.layer.shouldRasterize = YES;

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    lineGraphView.frame = NSInsetRect(self.bounds, 1, 1);
        
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
    
    [thePath appendBezierPathWithRoundedRect:NSInsetRect(self.bounds, 0.5, 0.5) xRadius:0 yRadius:0];
    
    NSColor *trackColor = [self.controller.track color];
    
    //[NSColor colorWithCalibratedHue:0.622 saturation:0.785 brightness:0.940 alpha:1.000]
    //[NSColor colorWithCalibratedHue:0.622 saturation:0.785 brightness:0.740 alpha:1.000]
    
    NSGradient* aGradient = [[NSGradient alloc]
                              initWithColorsAndLocations:[trackColor lighterColourBy:0.03], (CGFloat)0.0,
                              [trackColor darkerColourBy:0.14], (CGFloat)0.75,
                              nil];
    
    [aGradient drawInBezierPath:thePath angle:-90.0];

    

    [thePath setLineWidth:1];
    
    [[trackColor darkerColourBy:0.7] setStroke];
    [thePath stroke];

    [[trackColor lighterColourBy:0.15] setStroke];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(1, self.bounds.size.height - 1.5)
                              toPoint:NSMakePoint(self.bounds.size.width-1, self.bounds.size.height - 1.5)];

    
    // Draw your custom content here. Anything you draw
    // automatically has the shadow effect applied to it.
    
    [NSGraphicsContext restoreGraphicsState];

//    
//    [[NSColor yellowColor] set];
//    NSRectFill(self.bounds);

}

-(void)reloadData {
    [(MocoTimelineView *)self.superview relayout];
    [lineGraphView reloadData];
}

-(void)reloadDataForChangedFrames:(NSIndexSet *)changedFramesSet {
    [(MocoTimelineView *)self.superview relayout];
    [lineGraphView reloadDataForChangedFrames:changedFramesSet];
}

@end
