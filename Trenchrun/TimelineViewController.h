//
//  TimelineViewController.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTimelineView.h"
#import "MocoTimelineHeaderListView.h"

@class MocoDocument;
@class MocoTimelineView;
@class MocoTimelineHeaderListView;

@interface TimelineViewController : NSViewController {
    __weak IBOutlet MocoDocument *document;
    IBOutlet MocoTimelineView *timelineView;
    IBOutlet MocoTimelineHeaderListView *headerList;
    
    IBOutlet NSScrollView *timelineScrollView;
}
@property (assign) int playheadPosition; // in frames
@property (assign) float scaleFactor;    // 0.0-1.0
@property (assign) int timelineLength;    // in frames

@property (readonly) NSString *frameProgress;
@property (readonly) NSString *playheadTime;

- (IBAction)refreshGraph:(id)sender;

- (void)movePlayheadToFrame:(int)frameNumber;

-(BOOL)playOneFrame;

@end
