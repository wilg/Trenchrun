//
//  MocoLineGraphView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoLineGraphView.h"

#define PADDING 8

#define SEGMENT_LENGTH 25
// in frames

@interface MocoLineGraphView () {
}
@property (retain) NSMutableArray *paths;
@end


@implementation MocoLineGraphView
@synthesize controller;
@synthesize paths = _paths;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.canDrawConcurrently = YES;
        
        // Initialization code here.
        _paths = [NSMutableArray array];
        
    }
    
    return self;
}

-(void)reloadDataForChangedFrames:(NSIndexSet *)changedFramesSet {
    
//    [self reloadData];
//    return;
    
    // Loop through the changed frames.
    NSUInteger currentIndex = [changedFramesSet firstIndex];
    while (currentIndex != NSNotFound) {
        //use the currentIndex

        
        int affectedSubpath = [self subpathIndexForFrameNumber:currentIndex];
//        NSLog(@"trying to changed frame %lu on subpath %i", currentIndex, affectedSubpath);
        
        NSBezierPath *replacementPath = [self subpathForIndex:affectedSubpath];
        if (affectedSubpath + 1 > _paths.count) {
            [_paths addObject:replacementPath];
        }
        else {
            [_paths replaceObjectAtIndex:affectedSubpath withObject:replacementPath];
        }
        [self setNeedsDisplayInRect:replacementPath.bounds];
        
        //increment
        currentIndex = [changedFramesSet indexGreaterThanIndex: currentIndex];
    }

}


-(void)reloadData {
    
//    NSLog(@"line graph frame %@", NSStringFromRect(self.frame));

    NSMutableArray *tempPaths = [NSMutableArray array];
    
    if (self.controller && self.controller.track && self.controller.track.frames) {
        
        for (int i = 0; i < [self numberOfSubpaths]; i++) {
            [tempPaths addObject:[self subpathForIndex:i]];
        }
        
    }
                              
    self.paths = tempPaths;

    [self setNeedsDisplayInRect:self.bounds];
}

-(int)subpathIndexForFrameNumber:(int)frameNumber {
    for (int i = 0; i < [self numberOfSubpaths]; i++) {
        int subpathMin = SEGMENT_LENGTH * i;
        int subPathMax = SEGMENT_LENGTH * (i + 1);
        if (frameNumber >= subpathMin && frameNumber <= subPathMax) {
            return i;
        }
    }
    return [self numberOfSubpaths] + 1;
}

- (int)numberOfSubpaths {
    return (int)ceil((float)[self currentFrameCount] / (float)SEGMENT_LENGTH);
}

- (int)currentFrameCount {
    return self.controller.track.frames.count;
}

-(NSBezierPath *)subpathForIndex:(int)i {
    
    int totalFrameCount = [self currentFrameCount];

    int location = SEGMENT_LENGTH * i;
    
    int length = SEGMENT_LENGTH;
    int endValue = SEGMENT_LENGTH * (i + 1);
    if (endValue >= totalFrameCount)
        length = totalFrameCount - location;
    else {
        length++;
    }
    
    NSRange subPathRange = NSMakeRange(location, length);
    return [self pathForFrames:subPathRange];
}

-(NSBezierPath *)pathForFrames:(NSRange)range {
    NSBezierPath *path = [NSBezierPath bezierPath];
    path.flatness = 10.0;
    
    NSRect usableBounds = NSInsetRect(self.bounds, 0, PADDING);
    
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
        
        double xPercentage = frame.frameNumber.floatValue / (float)frameCount;
        double yPercentage = frame.position.floatValue / maxPosition;
        
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

    [[NSColor colorWithDeviceWhite:1.0 alpha:0.9] set];

    
    for (NSBezierPath *path in _paths) {
        if ([self needsToDrawRect:[path bounds]]) {
            [path setLineWidth:2.0];
            [path stroke];
        }
    }

    [NSGraphicsContext restoreGraphicsState];

//    NSLog(@"line graph draw rect");
    
}


@end
