//
//  TimelineViewController.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoDocument.h"
#import "TimelineViewController.h"
#import "MocoTimelineView.h"
#import "MocoTimelineTrackView.h"
#import "MocoTimelineTrackViewController.h"
#import "MocoTimelineHeaderViewController.h"
#import "MocoTimelineRulerView.h"
#import "MocoProtocolConstants.h"
#import "MocoTimelineViewConstants.h"

@interface TimelineViewController ( /* class extension */ ) {
@private

}
@property (retain) NSMutableArray *trackViewControllers;
@property (retain) NSMutableArray *headerViewControllers;

@end


@implementation TimelineViewController
@synthesize trackViewControllers, headerViewControllers;
@synthesize playheadPosition, scaleFactor, timelineLength;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}



- (void)awakeFromNib {
    
    self.playheadPosition = 0;
    self.scaleFactor = 0.5;
    self.timelineLength = 0;

    timelineView.controller = self;

    if (document)
        [self setupTracks];
    else {
        NSLog(@"no document attached to timeline view controller");
    }

    for (MocoTrack *track in document.trackList) {
        [track addObserver:self
                   forKeyPath:@"frames"
                      options:0
                      context:@"MocoTimelineTrackViewControllerObserveTrackList"];
    }

    [self addObserver:self
            forKeyPath:@"scaleFactor"
               options:0
               context:@"MocoTimelineTrackViewControllerObserveTrackList"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"scaleFactor"]) {
        [timelineView reloadData];

    }
    else {
        [self calculateTimelineLength];
    }
}

-(void)zoomInOneStep{
    [self zoomToLevel:self.scaleFactor + 0.2];
}

-(void)zoomOutOneStep {
    [self zoomToLevel:self.scaleFactor - 0.2];
}

- (void)zoomToLevel:(float)zoomLevel {
    if (zoomLevel <= 0)
        zoomLevel = 0.1;
    if (zoomLevel > 3)
        zoomLevel = 3;
    self.scaleFactor = zoomLevel;
}

- (IBAction)refreshGraph:(id)sender {
    
//    [self resetTrackViews];
    [timelineView reloadData];

}

- (void)setupTracks {
    
    [self calculateTimelineLength];
    [self resetTrackViews];
    [self setupHeaderViews];

}

- (void)calculateTimelineLength {
    int newLength = 0;
    for (MocoTrack *track in document.trackList) {
        int trackLength = track.frames.count;
        if (trackLength > newLength)
            newLength = trackLength;
    }
    self.timelineLength = newLength;
}

- (void)resetTrackViews {
        
    [timelineView removeAllTrackViews];
    
    for (MocoTrack *track in document.trackList) {        
        MocoTimelineTrackViewController *trackViewController = [[MocoTimelineTrackViewController alloc] initWithNibName:nil bundle:nil];
        trackViewController.track = track;
        trackViewController.timelineController = self;
        [trackViewControllers addObject:trackViewController];
        [timelineView addTrackView:(MocoTimelineTrackView *)trackViewController.view];
    }
    
}


- (void)setupHeaderViews {
    
//    [headerList remove];
        
    for (MocoTrack *track in document.trackList) {
        
        MocoTimelineHeaderViewController *headerViewController = [[MocoTimelineHeaderViewController alloc] initWithNibName:@"MocoTimelineHeaderViewController" bundle:[NSBundle mainBundle]];
        headerViewController.track = track;
        [headerViewControllers addObject:headerViewController];
        [headerList addHeaderView:(MocoTimelineHeaderView *)headerViewController.view];

    }
    
}

- (void)movePlayheadToFrame:(int)frameNumber {
    if (frameNumber < 0)
        frameNumber = 0;
    if (frameNumber >= self.timelineLength)
        frameNumber = self.timelineLength - 1;
    self.playheadPosition = frameNumber;
    [timelineView playheadMoved];
}

- (void)followPlayheadToFrame:(int)frameNumber {
    [self movePlayheadToFrame:frameNumber];
    [timelineView scrollToPlayhead];
}

-(BOOL)playOneFrame {
    int currentPos = self.playheadPosition;
    if (currentPos + 1 > timelineLength) {
        return NO;
    }
    else {
        [self followPlayheadToFrame:currentPos + 1];
        return YES;
    }
    return NO;
}

-(BOOL)playToTime:(NSTimeInterval)seconds {
    NSInteger desiredPos = [self frameAtTime:seconds];
    if (desiredPos > timelineLength) {
        return NO;
    }
    else {
        [self followPlayheadToFrame:desiredPos];
        return YES;
    }
    return NO;
}

-(void)forwardBySeconds:(float)seconds {
    [self followPlayheadToFrame: self.playheadPosition + seconds * (float)document.fps];
}

-(void)backBySeconds:(float)seconds {
    [self followPlayheadToFrame: self.playheadPosition - seconds * (float)document.fps];
}

-(int)fps {
    return document.fps;
}

- (NSInteger)frameAtTime:(NSTimeInterval)seconds {
    return round((NSTimeInterval)self.fps * seconds);
}

-(NSInteger)framesRemaining {
    return self.timelineLength - self.playheadPosition;
}

- (NSTimeInterval)timeRemaining {
    return (NSTimeInterval)self.framesRemaining / (NSTimeInterval)self.fps;
}

- (NSTimeInterval)totalTimeInterval {
    return (NSTimeInterval)self.timelineLength / (NSTimeInterval)self.fps;
}


- (NSString *)frameProgress {
    
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    numberFormat.usesGroupingSeparator = YES;
    numberFormat.groupingSeparator = @",";
    numberFormat.groupingSize = 3;   
    
    NSInteger formattedPlayhead = playheadPosition + 1;
    if (timelineLength == 0) {
        formattedPlayhead = 0;
    }

    NSString *currentFrame = [numberFormat stringFromNumber:[NSNumber numberWithInt:formattedPlayhead]];
    NSString *length = [numberFormat stringFromNumber:[NSNumber numberWithInt:timelineLength]];

    return [NSString stringWithFormat:@"%@ / %@ frames",currentFrame, length];
}


- (NSTimeInterval)playheadTimeInterval {
    return (NSTimeInterval)self.playheadPosition / (NSTimeInterval)self.fps;
}

- (NSString *)playheadTime {
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:self.playheadTimeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss.SSS"];
    return [NSString stringWithFormat:@"%@s", [formatter stringFromDate: date1]];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"playheadTime"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"playheadPosition",nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    if ([key isEqualToString:@"frameProgress"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"playheadPosition", @"timelineLength", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }

    return keyPaths;
}

- (float)pixelsPerFrame {
    return round(PIXELS_PER_FRAME_AT_100_PERCENT * self.scaleFactor);
}

- (float)pixelsPerSecond {
    return (float)[self pixelsPerFrame] * (float)self.fps;
}

-(void)startPulsingPlayhead {
    [timelineView startPulsingPlayhead];
}

-(void)stopPulsingPlayhead {
    [timelineView stopPulsingPlayhead];
}


@end
