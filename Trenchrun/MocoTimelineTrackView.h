//
//  MocoTimelineTrackView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTimelineTrackViewController.h"

@class TimelineViewController;
@class MocoLineGraphView;
@class MocoTimelineTrackViewController;

@interface MocoTimelineTrackView : NSView 
@property (retain) MocoTimelineTrackViewController *controller;
@property (readonly) MocoLineGraphView *lineGraphView;

-(void)reloadData;
-(void)reloadDataForChangedFrames:(NSIndexSet *)changedFramesSet;

@end
