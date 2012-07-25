//
//  MocoTimelineView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoTimelineView.h"
#import "MocoTimelineTrackView.h"
#import "MocoTimelineViewConstants.h"
#import "DuxScrollViewAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import "DuxScrollViewAnimation.h"

@interface MocoTimelineView ( /* class extension */ ) {
@private
    NSImageView *playheadImageView;
    NSPoint clickPoint;
}
@property (retain) NSMutableArray *trackViews;

@end

// IMPLEMENTATION

@implementation MocoTimelineView
@synthesize trackViews, controller;

- (BOOL)isFlipped {
    return YES;
}

# pragma mark Base Drawing  Initialization

- (void)awakeFromNib {
    
    self.wantsLayer = YES;
//    self.layer.shouldRasterize = YES;
    
    self.trackViews = [NSMutableArray array];
        
    [self updateBounds];
        
    playheadImageView = [[NSImageView alloc] initWithFrame:[self playheadRect]];
    [playheadImageView setImage:[NSImage imageNamed:@"playhead.png"]];
    [playheadImageView setImageScaling:NSImageScaleAxesIndependently];
    playheadImageView.wantsLayer = YES;
    
    [self addSubview:playheadImageView];
    
    [self.controller addObserver:self
                        forKeyPath:@"playheadPosition"
                           options:0
                           context:@"MocoTimelineObservePlayhead"];
    
}

- (void)dealloc {
    [self.controller removeObserver:self forKeyPath:@"playheadPosition"];
}

- (BOOL)mouseDownCanMoveWindow {
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    NSLog(@"plauyhead oved");

}


- (void)removeAllTrackViews {
    
    for (MocoTimelineTrackView *trackView in self.trackViews) {
        [trackView removeFromSuperview];
    }
    [self.trackViews removeAllObjects];
}



- (void)drawRect:(NSRect)dirtyRect {
    
    if ([self needsToDrawRect:[self playheadRect]]) {
        playheadImageView.frame = [self playheadRect];
    }
    
    
//    NSLog(@"%@", NSStringFromRect([self frame]));

//    [[NSColor redColor] set];
//    NSRectFill(self.bounds);

    
//    for (MocoTimelineTrackView *trackView in self.trackViews) {
//        [trackView setNeedsDisplay:YES];
//    }
    
    
    
    if (self.controller && self.controller.totalTimeInterval > 0) {
        for (int i = 0; i < (int)ceil(self.controller.totalTimeInterval); i++) {
            [self drawSecond:i];
        }
    }


}

-(void)drawSecond:(int)i {
    NSRect frameRect = NSMakeRect([self xPositionForTime:i],
                                  0, 
                                  [self.controller pixelsPerSecond], 
                                  self.bounds.size.height);
    
    [NSGraphicsContext saveGraphicsState];

    if ([self needsToDrawRect:frameRect]) {
        if (i % 2 != 0) {
            [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
            NSRectFill(frameRect);
            
            
            [[NSColor colorWithDeviceWhite:0 alpha:0.3] setStroke];
            [NSBezierPath setDefaultLineWidth:1];
            
            NSBezierPath *linePath = [NSBezierPath bezierPath];
            [linePath moveToPoint:NSMakePoint(frameRect.origin.x - 1, 0)];
            [linePath lineToPoint:NSMakePoint(frameRect.origin.x - 1, frameRect.origin.y + frameRect.size.height)];
            [linePath setLineWidth:1];
            [linePath stroke];
            
            
            float xposition2 = [self xPositionForTime:i+1];

            NSBezierPath *linePath2 = [NSBezierPath bezierPath];
            [linePath2 moveToPoint:NSMakePoint(xposition2 + 1, 0)];
            [linePath2 lineToPoint:NSMakePoint(xposition2 + 1, frameRect.origin.y + frameRect.size.height)];
            [linePath2 setLineWidth:1];
            [linePath2 stroke];

        }
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [NSColor colorWithDeviceWhite:0.3 alpha:1];
        shadow.shadowOffset = NSMakeSize(0, -30);
        shadow.shadowBlurRadius = 0.0;
        
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont fontWithName:@"Futura" size:13],
                                    NSShadowAttributeName: shadow,
                                    NSForegroundColorAttributeName: [NSColor colorWithDeviceWhite:0.25 alpha:1]};

        NSString *title = [NSString stringWithFormat:@"%is", i];
        [title drawAtPoint:NSMakePoint(frameRect.origin.x + 10, 5 - 30) withAttributes:attributes];

    }
    
    [NSGraphicsContext restoreGraphicsState];

}

-(float)xPositionForTime:(NSTimeInterval)seconds {
    return round(PADDING + [self.controller pixelsPerSecond] * seconds);
}

- (void)updateBounds {
    NSRect tracks = [self tracksRect];
    
    float h = tracks.size.height + PADDING * 2;
    float superViewHeight = [self superview].frame.size.height;
    if (superViewHeight > h)
        h = superViewHeight;
    
    
    self.frame = NSMakeRect(self.frame.origin.x,
                            self.frame.origin.y, 
                            self.controller.timelineLength * self.controller.pixelsPerFrame + PADDING + PADDING_LEFT,
                            h);
    
}

# pragma mark Interaction

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)keyDown:(NSEvent*)event {
    switch( [event keyCode] ) {
//        case 126:       // up arrow
//            break;
//        case 125:       // down arrow
//            break;
        case 124:       // right arrow
            [self.controller movePlayheadToFrame:self.controller.playheadPosition + 1];
            [self setNeedsDisplayInRect:[self playheadRect]];

            break;
        case 123:       // left arrow
            [self.controller movePlayheadToFrame:self.controller.playheadPosition - 1];
            [self setNeedsDisplayInRect:[self playheadRect]];

            break;
        default:
            [[self nextResponder] keyDown:event];
            break;
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (IBAction)zoomIn:(id)sender {
    [self.controller zoomInOneStep];
}

- (IBAction)zoomOut:(id)sender {
    [self.controller zoomOutOneStep];
}


- (void)mouseDown:(NSEvent *)event {
    NSPoint center = [self convertPoint:[event locationInWindow] fromView:nil];
    [self movePlayheadToPoint:center];
    [self becomeFirstResponder];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint center = [self convertPoint:[event locationInWindow] fromView:nil];
    [self movePlayheadToPoint:center];
    [self becomeFirstResponder];
    
    [self autoscroll:event];
}

-(void)playheadMoved {
    [CATransaction begin];
    [CATransaction setValue:@0.05f
                     forKey:kCATransactionAnimationDuration];

    playheadImageView.layer.frame = [self playheadRect];

    [CATransaction commit];
}

-(void)scrollToPlayhead {
    NSPoint destination = NSMakePoint([self playheadRect].origin.x - 100, 0);
    
    if (!CGRectIntersectsRect(self.visibleRect, [self playheadRect])  ) {
        [self scrollPoint:destination];
//        [DuxScrollViewAnimation animatedScrollToPoint:destination inScrollView:self.enclosingScrollView];
    }
    

}


# pragma mark Drawing Playhead

- (NSRect)playheadRect {
    return NSMakeRect([self absolutePlayheadPosition], 0, 12.0, self.bounds.size.height);
}

- (float)absolutePlayheadPosition {
    return PADDING_LEFT + (float)self.controller.playheadPosition * self.controller.pixelsPerFrame - playheadImageView.bounds.size.width / 2;
}

- (void)movePlayheadToPoint:(NSPoint)viewPoint {
    
    int playheadPositionInFrames = (viewPoint.x - PADDING_LEFT + playheadImageView.bounds.size.width / 4.0f  ) / self.controller.pixelsPerFrame;
    
    [self.controller movePlayheadToFrame:playheadPositionInFrames];
    
    clickPoint = viewPoint;
}


-(void)startPulsingPlayhead {
    // create the animation that will handle the pulsing.
    CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
    
    // over a one second duration, and run an infinite
    // number of times
    pulseAnimation.duration = 0.5;
    pulseAnimation.repeatCount = MAXFLOAT;
    
    // we want it to fade on, and fade off, so it needs to
    // automatically autoreverse.. this causes the intensity
    // input to go from 0 to 1 to 0
    pulseAnimation.autoreverses = YES;

    [pulseAnimation setFromValue:@0.0f];
    [pulseAnimation setToValue:@1.0f];
    
    [playheadImageView.layer addAnimation:pulseAnimation forKey:@"opacity"];

}

-(void)stopPulsingPlayhead {
    [playheadImageView.layer removeAllAnimations];
}


# pragma mark Drawing Tracks

- (void)reloadData {
        
    [self updateBounds];

    for (MocoTimelineTrackView *trackView in trackViews) {
        [trackView reloadData];
    }
    
    [self playheadMoved];
}

- (void)relayout {
    
    for (MocoTimelineTrackView *trackView in trackViews) {
        [self positionTrackView:trackView];
    }
    
    [self updateBounds];
    [self playheadMoved];

}


- (void)addTrackView:(MocoTimelineTrackView *)trackView {
    
    [self.trackViews addObject:trackView];
    [self addSubview:trackView positioned:NSWindowBelow relativeTo:nil];
    
    [self positionTrackView:trackView];
        
}

- (void)positionTrackView:(MocoTimelineTrackView *)trackView {
    int index = [self.trackViews indexOfObject:trackView];
    trackView.frame = [self rectForTrackAtIndex:index];

    [self updateBounds];
}

- (NSRect)tracksRect {
    return [self tracksRectForTrackCount:self.trackViews.count];
}

- (NSRect)tracksRectForTrackCount:(int)count {
    return NSMakeRect(PADDING_LEFT,
                      PADDING,
                      self.controller.timelineLength * self.controller.pixelsPerFrame, 
                      (count) * TRACK_HEIGHT + ((count - 1) * TRACK_BOTTOM_MARGIN) + TRACK_TOP_PADDING
                      );
}

- (NSRect)rectForTrackAtIndex:(int)index {
    
    NSRect tracks = [self tracksRectForTrackCount:index];
    
    float trackWidth = 0;
    
    // How long is this track?
    MocoTimelineTrackView *trackView = trackViews[index];
    NSArray *frames = [trackView.controller.track.frames copy];
    trackWidth = (float)frames.count * (float)self.controller.pixelsPerFrame;
            
    return NSMakeRect(tracks.origin.x, 
                      tracks.size.height + PADDING,
                      trackWidth,
                      TRACK_HEIGHT
                      );
    
}


@end
