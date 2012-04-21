//
//  MocoTimelineView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelineView.h"
#import "MocoTimelineTrackView.h"
#import "MocoTimelineViewConstants.h"


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
    
    NSLog(@"removeAllTrackViews");
    for (MocoTimelineTrackView *trackView in self.trackViews) {
        [trackView removeFromSuperview];
    }
    [self.trackViews removeAllObjects];
}

- (void)drawRect:(NSRect)dirtyRect {
    
//    if ([self needsToDrawRect:[self playheadRect]]) {
//        playheadImageView.frame = [self playheadRect];
//    }
    
    
//    NSLog(@"%@", NSStringFromRect([self frame]));

//    [[NSColor redColor] set];
//    NSRectFill(self.bounds);

    
//    for (MocoTimelineTrackView *trackView in self.trackViews) {
//        [trackView setNeedsDisplay:YES];
//    }
    

}

- (void)updateBounds {
    NSRect tracks = [self tracksRect];
    
    float h = tracks.size.height + PADDING * 2;
    float superViewHeight = [self superview].frame.size.height;
    if (superViewHeight > h)
        h = superViewHeight;
    
    
    self.frame = NSMakeRect(self.frame.origin.x,
                            self.frame.origin.y, 
                            self.controller.timelineLength * [self pixelsPerFrame] + PADDING + PADDING_LEFT,
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

- (void)mouseDown:(NSEvent *)event {
    NSPoint center = [self convertPoint:[event locationInWindow] fromView:nil];
    [self movePlayheadToPoint:center];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint center = [self convertPoint:[event locationInWindow] fromView:nil];
    [self movePlayheadToPoint:center];
    [self autoscroll:event];

}

-(void)playheadMoved {
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.05f]
                     forKey:kCATransactionAnimationDuration];

    playheadImageView.layer.frame = [self playheadRect];

    [CATransaction commit];
}


# pragma mark Drawing Playhead

- (NSRect)playheadRect {
    return NSMakeRect([self absolutePlayheadPosition], 0, 12.0, self.bounds.size.height);
}

- (float)absolutePlayheadPosition {
    return PADDING_LEFT + (float)self.controller.playheadPosition * [self pixelsPerFrame] - playheadImageView.bounds.size.width / 2;
}

- (float)pixelsPerFrame {
    return PIXELS_PER_FRAME_AT_100_PERCENT * self.controller.scaleFactor;
}

- (void)movePlayheadToPoint:(NSPoint)viewPoint {
    
    int playheadPositionInFrames = (viewPoint.x - PADDING_LEFT + playheadImageView.bounds.size.width / 4.0f  ) / [self pixelsPerFrame];
    
    [self.controller movePlayheadToFrame:playheadPositionInFrames];
    
    clickPoint = viewPoint;
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
                      self.controller.timelineLength * [self pixelsPerFrame], 
                      (count) * TRACK_HEIGHT + ((count) * TRACK_BOTTOM_MARGIN)
                      );
}

- (NSRect)rectForTrackAtIndex:(int)index {
    
    NSRect tracks = [self tracksRectForTrackCount:index];
    
    float trackWidth = 0;
    
    // How long is this track?
    MocoTimelineTrackView *trackView = [trackViews objectAtIndex:index];
    NSArray *frames = [trackView.controller.track.frames copy];
    trackWidth = (float)frames.count * (float)[self pixelsPerFrame];
            
    return NSMakeRect(tracks.origin.x, 
                      tracks.size.height + PADDING,
                      trackWidth,
                      TRACK_HEIGHT
                      );
    
}


@end
