//
//  MocoTimelineHeaderListView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoTimelineHeaderListView.h"
#import "TimelineViewController.h"
#import "MocoTimelineHeaderView.h"
#import "MocoTimelineViewConstants.h"

@interface MocoTimelineHeaderListView ( /* class extension */ ) {
}
@property (retain) NSMutableArray *headerViews;

@end

// IMPLEMENTATION

@implementation MocoTimelineHeaderListView
@synthesize headerViews, controller;

- (BOOL)isFlipped {
    return YES;
}


# pragma mark Base Drawing  Initialization

- (void)awakeFromNib {
    self.headerViews = [NSMutableArray array];
    
    self.wantsLayer = YES;
    
    [self updateBounds];    
}

- (void)removeAllHeaderViews {
    for (MocoTimelineHeaderView *headerView in self.headerViews) {
        [headerView removeFromSuperview];
    }
    [self.headerViews removeAllObjects];
}

- (void)drawRect:(NSRect)dirtyRect {

    [self updateBounds];
    
    [[NSColor colorWithCalibratedWhite:0.3 alpha:1.0] set];
    NSRectFill(self.bounds);
    
//    [[NSColor blueColor] set];
//    NSRectFill([self tracksRect]);
    

    
}

- (void)updateBounds {
    
    for (int i = 0; i < headerViews.count; i++) {
        MocoTimelineHeaderView *headerView = (MocoTimelineHeaderView *)headerViews[i];
        headerView.frame = [self rectForTrackAtIndex:i];
    }
    
}


# pragma mark Drawing Tracks

- (void)addHeaderView:(MocoTimelineHeaderView *)headerView {
    
    int idx = self.headerViews.count;
    [self.headerViews addObject:headerView];
    headerView.frame = [self rectForTrackAtIndex:idx];
    [self addSubview:headerView positioned:NSWindowBelow relativeTo:nil];
    
    
    [headerView setNeedsDisplay:YES];
    
    [self updateBounds];
    [self setNeedsDisplay:YES];
}

- (NSRect)tracksRect {
    
    float tracksRectHeight = (self.headerViews.count) * TRACK_HEIGHT + ((self.headerViews.count - 1) * TRACK_BOTTOM_MARGIN);
    
    
    return NSMakeRect(0,
                      PADDING,
                      self.bounds.size.width, 
                      tracksRectHeight
                      );
}

- (NSRect)rectForTrackAtIndex:(int)index {
    
    NSRect tracks = [self tracksRect];
        
    return NSMakeRect(tracks.origin.x, 
                      TRACK_HEIGHT * index + TRACK_TOP_PADDING + TRACK_BOTTOM_MARGIN * index,
                      self.frame.size.width,
                      TRACK_HEIGHT
                      );
    
}


@end
