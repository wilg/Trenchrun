//
//  MocoTimelineView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelineView.h"
#import "MocoTimelineTrackView.h"

#define TRACK_HEIGHT 50.0f
#define PADDING_LEFT 15.0f
#define PADDING 15.0f
#define TRACK_BOTTOM_MARGIN 5.0f

#define PIXELS_PER_FRAME_AT_100_PERCENT 2.0f

@interface MocoTimelineView ( /* class extension */ ) {
@private
    NSImageView *playheadImageView;
    NSPoint clickPoint;
}
@property (retain) NSMutableArray *trackViews;

@end

// IMP


@implementation MocoTimelineView
@synthesize trackViews, playheadPosition, scaleFactor, dataSource;

- (BOOL) isFlipped
{
    return YES;
}


# pragma mark Base Drawing  Initialization

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.trackViews = [NSMutableArray array];
        
        [self updateBounds];
        
        self.scaleFactor = 1.0f;
        
        playheadImageView = [[NSImageView alloc] initWithFrame:[self playheadRect]];
        [playheadImageView setImage:[NSImage imageNamed:@"playhead.png"]];
        [playheadImageView setImageScaling:NSImageScaleAxesIndependently];
        
        [self addSubview:playheadImageView];
        
    }
    
    return self;
}

- (void)reload {
        
    for (MocoTimelineTrackView *trackView in self.trackViews) {
        [trackView removeFromSuperview];
    }
    
    [self.trackViews removeAllObjects];
    
    if (self.dataSource) {

        for (int i = 0; i < [self.dataSource numberOfTracks]; i++) {
            [self addTrackViewAtIndex:i];
        }
    }
    
    [self updateBounds];

    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    playheadImageView.frame = [self playheadRect];
    
//    [[NSColor redColor] set];
//    NSRectFill(NSMakeRect(clickPoint.x, clickPoint.y, 10, 10));

}

- (void)updateBounds {
    NSRect tracks = [self tracksRect];
    
    float h = tracks.size.height + PADDING * 2;
    float superViewHeight = [self superview].frame.size.height;
    if (superViewHeight > h)
        h = superViewHeight;
    
    float longestTrack = 50.0;
    for (int i = 0; i < [self.dataSource numberOfTracks]; i++) {
        float w = [self rectForTrackAtIndex:i].size.width;
        if (w > longestTrack)
            longestTrack = w;
    }
    
    self.frame = NSMakeRect(self.frame.origin.x,
                            self.frame.origin.y, 
                            longestTrack + PADDING + PADDING_LEFT,
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
    return PADDING_LEFT + (float)playheadPosition * [self pixelsPerFrame] - playheadImageView.bounds.size.width / 2;
}

- (float)pixelsPerFrame {
    return PIXELS_PER_FRAME_AT_100_PERCENT * self.scaleFactor;
}

- (void)movePlayheadToPoint:(NSPoint)viewPoint {
    
    
    int playheadPositionInFrames = (viewPoint.x - PADDING_LEFT + playheadImageView.bounds.size.width / 4.0f  ) / [self pixelsPerFrame];
    
    if (playheadPositionInFrames < 0)
        playheadPositionInFrames = 0;
    
    playheadPosition = playheadPositionInFrames;
    
    clickPoint = viewPoint;
    [self setNeedsDisplay:YES];
}

# pragma mark Drawing Tracks

- (void)addTrackViewAtIndex:(int)index {
    MocoTimelineTrackView *track = [[MocoTimelineTrackView alloc] initWithFrame:[self rectForTrackAtIndex:self.trackViews.count]];
    
    if (self.dataSource) {
        track.track = [self.dataSource trackAtIndex:index];
    }

    [self.trackViews addObject:track];
    [self addSubview:track positioned:NSWindowBelow relativeTo:nil];
}

- (NSRect)tracksRect {
    
    return NSMakeRect(PADDING_LEFT,
                      PADDING,
                      600.0, 
                      self.trackViews.count * TRACK_HEIGHT + ((self.trackViews.count) * TRACK_BOTTOM_MARGIN) - TRACK_BOTTOM_MARGIN
                      );
}

- (NSRect)rectForTrackAtIndex:(int)index {
    
    NSRect tracks = [self tracksRect];
    
    float trackWidth = 0;
    
    if (self.dataSource) {
        MocoTrack *track = [self.dataSource trackAtIndex:index];
        NSArray *frames = [track.frames copy];
        trackWidth = (float)frames.count * (float)[self pixelsPerFrame];
    }
    
    return NSMakeRect(tracks.origin.x, 
                      tracks.size.height + TRACK_BOTTOM_MARGIN + PADDING,
                      trackWidth - PADDING - PADDING_LEFT,
                      TRACK_HEIGHT
                      );
    
}

- (IBAction)updatePlayheadPosition:(id)sender {
    self.playheadPosition = [sender intValue];


    [self setNeedsDisplay:YES];
}

- (IBAction)updateScale:(id)sender {
    self.scaleFactor = [sender floatValue];
    
    [self reload];
}


@end
