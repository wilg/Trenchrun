//
//  MocoLineGraphView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoLineGraphView.h"

#define PADDING 8

@interface MocoLineGraphView () {
    NSBezierPath *_graphPath;
}
@end


@implementation MocoLineGraphView
@synthesize controller;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _graphPath = nil;
//        self.canDrawConcurrently = YES;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
//    NSLog(@"MocoLineGraphView dirty: %@", NSStringFromRect(dirtyRect));


    [NSGraphicsContext saveGraphicsState];
//    [[NSGraphicsContext currentContext] setShouldAntialias:NO];

    [[NSColor whiteColor] set];

    NSBezierPath *line = [self graphLine];

    [line setLineWidth:2.0];
    [[NSColor whiteColor] set];
    
    [line stroke];

    [NSGraphicsContext restoreGraphicsState];

//    NSLog(@"line graph draw rect");
    
}

- (NSBezierPath *) graphLine {
    
//    if (_graphPath != nil) {
//        return _graphPath;
//    }
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.flatness = 1.0;
    
    if (self.controller && self.controller.track && self.controller.track.frames) {
        
        NSRect usableBounds = NSInsetRect(self.bounds, PADDING, PADDING);
        
        int frameCount = self.controller.track.frames.count;
        
        float maxPosition = 0;
        for (MocoFrame *frame in self.controller.track.frames) {
            float thisPosition = [frame.position floatValue];
            if (thisPosition > maxPosition)
                maxPosition = thisPosition;
        }
        
        NSPoint lastPoint = NSZeroPoint;
        BOOL first = YES;
        
        for (MocoFrame *frame in self.controller.track.frames) {
            
            float xPercentage = frame.frameNumber.floatValue / (float)frameCount;
            float yPercentage = frame.position.floatValue / maxPosition;
            
            float xPositionForFrame = usableBounds.size.width * xPercentage;
            float yPositionForFrame = usableBounds.size.height * yPercentage;
            
            NSPoint point = NSMakePoint(xPositionForFrame + PADDING / 2, yPositionForFrame + PADDING / 2);
            
            if (first) {
                lastPoint = point;
                first = NO;
            }
            
            [line moveToPoint:lastPoint];
            [line lineToPoint:point];
            
            lastPoint = point;
        }
        
    }
    
    _graphPath = [line copy];
    
    return line;
}

@end
