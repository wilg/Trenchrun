//
//  TimelineViewController.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoDocument.h"
#import "TimelineViewController.h"
#import "MocoTimelineView.h"
#import "MocoTimelineTrackView.h"
#import "MocoTimelineTrackViewController.h"
#import "MocoTimelineHeaderViewController.h"
#import "MocoTimelineRulerView.h"

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

    [document addObserver:self
            forKeyPath:@"trackList"
               options:0
               context:@"MocoTimelineTrackViewControllerObserveTrackList"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self calculateTimelineLength];
}


- (IBAction)refreshGraph:(id)sender {
    
    [self resetTrackViews];

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
    timelineLength = newLength;
}

- (void)resetTrackViews {
        
    [timelineView removeAllTrackViews];
    
    for (MocoTrack *track in document.trackList) {        
        MocoTimelineTrackViewController *trackViewController = [[MocoTimelineTrackViewController alloc] initWithNibName:nil bundle:nil];
        trackViewController.track = track;
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

//
//#pragma mark -
//#pragma mark Track View Data Source
//
//- (int)numberOfTracks {
//    if (document && document.trackList){
//
//    }
//    else {
//        return 0;
//    }
//    return document.trackList.count;
//}
//
//- (MocoTrack *)trackAtIndex:(int)index {
//    return [document.trackList objectAtIndex:index];
//}



@end
