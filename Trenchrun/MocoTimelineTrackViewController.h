//
//  MocoTimelineTrackViewController.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTrack.h"
#import "TimelineViewController.h"

@class TimelineViewController;

@interface MocoTimelineTrackViewController : NSViewController
@property (assign) MocoTrack *track;
@property (assign) TimelineViewController *timelineController;

@end
