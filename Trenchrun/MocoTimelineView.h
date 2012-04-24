//
//  MocoTimelineView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTrack.h"
#import "MocoTimelineTrackView.h"
#import "TimelineViewController.h"

@class TimelineViewController;
@class MocoTimelineTrackView;

@interface MocoTimelineView : NSView {
}

@property (assign) TimelineViewController *controller;

- (void)reloadData;
- (void)relayout;

- (void)addTrackView:(MocoTimelineTrackView *)trackView;
- (void)removeAllTrackViews;
-(void)playheadMoved;
-(void)scrollToPlayhead;

-(void)startPulsingPlayhead;
-(void)stopPulsingPlayhead;


@end
