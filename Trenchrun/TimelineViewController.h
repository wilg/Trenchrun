//
//  TimelineViewController.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
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
@property (assign) double scaleFactor;    // 0.0-1.0
@property (assign) int timelineLength;    // in frames

@property (readonly) NSString *frameProgress;
@property (readonly) NSString *playheadTime;
@property (readonly) double pointsPerFrame;

@property (readonly) NSTimeInterval totalTimeInterval;
@property (readonly) NSTimeInterval playheadTimeInterval;
@property (readonly) NSTimeInterval timeRemaining;
@property (readonly) NSInteger framesRemaining;

- (IBAction)refreshGraph:(id)sender;

- (void)movePlayheadToFrame:(int)frameNumber;
- (void)followPlayheadToFrame:(int)frameNumber;
- (void)movePlayheadToEnd;
- (void)movePlayheadToBeginning;

-(BOOL)playOneFrame;
-(BOOL)playToTime:(NSTimeInterval)seconds;

-(void)forwardBySeconds:(float)seconds;
-(void)backBySeconds:(float)seconds;

-(void)startPulsingPlayhead;
-(void)stopPulsingPlayhead;

-(void)zoomInOneStep;
-(void)zoomOutOneStep;

-(int)fps;
- (float)pixelsPerSecond;

@end
