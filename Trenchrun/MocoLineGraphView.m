//
//  MocoLineGraphView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoLineGraphView.h"

#define PADDING 6

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

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{

    [[NSColor whiteColor] set];

    NSBezierPath *line = [self graphLine];

    [line setLineWidth:2.0];
    [[NSColor whiteColor] set];
    
    [line stroke];


//    NSLog(@"line graph draw rect");
    
}

- (NSBezierPath *) graphLine {
    
//    if (_graphPath) {
//        return _graphPath;
//    }
//    
    NSBezierPath *line = [NSBezierPath bezierPath];
    
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
    
    return line;
}

@end
