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
    
    
    self.trackViews = [NSMutableArray array];
        
    [self updateBounds];
        
    playheadImageView = [[NSImageView alloc] initWithFrame:[self playheadRect]];
    [playheadImageView setImage:[NSImage imageNamed:@"playhead.png"]];
    [playheadImageView setImageScaling:NSImageScaleAxesIndependently];
    
    [self addSubview:playheadImageView];
    
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
    
    if (playheadPositionInFrames < 0)
        playheadPositionInFrames = 0;
    
    self.controller.playheadPosition = playheadPositionInFrames;
    
    clickPoint = viewPoint;
    [self setNeedsDisplay:YES];
}

# pragma mark Drawing Tracks

- (void)addTrackView:(MocoTimelineTrackView *)trackView {
    
    int idx = self.trackViews.count;
    [self.trackViews addObject:trackView];
    trackView.frame = [self rectForTrackAtIndex:idx];
    [self addSubview:trackView positioned:NSWindowBelow relativeTo:nil];
    
    [trackView setNeedsDisplay:YES];
    
    [self updateBounds];
    [self setNeedsDisplay:YES];
}

- (NSRect)tracksRect {
    return NSMakeRect(PADDING_LEFT,
                      PADDING,
                      self.controller.timelineLength * [self pixelsPerFrame], 
                      (self.trackViews.count - 1) * TRACK_HEIGHT + ((self.trackViews.count - 1) * TRACK_BOTTOM_MARGIN)
                      );
}

- (NSRect)rectForTrackAtIndex:(int)index {
    
    NSRect tracks = [self tracksRect];
    
    float trackWidth = 0;
    
    // How long is this track?
    MocoTimelineTrackView *trackView = [trackViews objectAtIndex:index];
    NSArray *frames = [trackView.controller.track.frames copy];
    trackWidth = (float)frames.count * (float)[self pixelsPerFrame];
            
    return NSMakeRect(tracks.origin.x, 
                      tracks.size.height + PADDING,
                      trackWidth - PADDING - PADDING_LEFT,
                      TRACK_HEIGHT
                      );
    
}


@end
