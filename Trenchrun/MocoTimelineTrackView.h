//
//  MocoTimelineTrackView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTimelineTrackViewController.h"

@class TimelineViewController;
@class MocoLineGraphView;

@interface MocoTimelineTrackView : NSView 
@property (assign) MocoTimelineTrackViewController *controller;
@property (readonly) MocoLineGraphView *lineGraphView;

-(void)reloadData;

@end
