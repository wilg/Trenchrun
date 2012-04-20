//
//  MocoLineGraphView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoLineGraphView.h"

#define PADDING 8

#define SEGMENT_LENGTH 100
// in frames

@interface MocoLineGraphView () {
    NSArray *_paths;
}
@end


@implementation MocoLineGraphView
@synthesize controller;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code here.
        _paths = nil;
        
    }
    
    return self;
}


-(void)reloadData {
    
    NSMutableArray *tempPaths = [NSMutableArray array];

    if (self.controller && self.controller.track && self.controller.track.frames) {
        NSRange fullRange = NSMakeRange(0, self.controller.track.frames.count);
        [tempPaths addObject:[self pathForFrames:fullRange]];
    }
                              
    _paths = [tempPaths copy];

    [self setNeedsDisplay:YES];
}

-(NSBezierPath *)pathForFrames:(NSRange)range {
    NSBezierPath *path = [NSBezierPath bezierPath];
    path.flatness = 10.0;
    
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
    
    for (MocoFrame *frame in [self.controller.track.frames subarrayWithRange:range]) {
        
        float xPercentage = frame.frameNumber.floatValue / (float)frameCount;
        float yPercentage = frame.position.floatValue / maxPosition;
        
        float xPositionForFrame = usableBounds.size.width * xPercentage;
        float yPositionForFrame = usableBounds.size.height * yPercentage;
        
        NSPoint point = NSMakePoint(xPositionForFrame + PADDING / 2, yPositionForFrame + PADDING / 2);
        
        if (first) {
            lastPoint = point;
            first = NO;
        }
        
        [path moveToPoint:lastPoint];
        [path lineToPoint:point];
        
        lastPoint = point;
    }
            
    return path;
}


- (void)drawRect:(NSRect)dirtyRect
{
    
//    NSLog(@"MocoLineGraphView dirty: %@", NSStringFromRect(dirtyRect));


    [NSGraphicsContext saveGraphicsState];
//    [[NSGraphicsContext currentContext] setShouldAntialias:NO];

    [[NSColor whiteColor] set];

    
    for (NSBezierPath *path in _paths) {
        if ([self needsToDrawRect:[path bounds]]) {
            [path setLineWidth:2.0];
            [[NSColor whiteColor] set];
            [path stroke];
        }
    }

    [NSGraphicsContext restoreGraphicsState];

//    NSLog(@"line graph draw rect");
    
}


@end
