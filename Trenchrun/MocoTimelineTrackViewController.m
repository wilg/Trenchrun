//
//  MocoTimelineTrackViewController.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/18/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "TimelineViewController.h"
#import "MocoTimelineTrackView.h"
#import "MocoTimelineTrackViewController.h"
#import "MocoLineGraphView.h"
#import "MocoTimelineViewConstants.h"

@interface MocoTimelineTrackViewController () {
    BOOL kvoRegistered;
}
@end

@implementation MocoTimelineTrackViewController
@synthesize track, timelineController;

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (MocoTimelineTrackView *)trackView {
    return (MocoTimelineTrackView *)self.view;
}

- (void)loadView {
    [super loadView];
        
    MocoTimelineTrackView *tv = [[MocoTimelineTrackView alloc] initWithFrame:NSMakeRect(0, 0, 100, TRACK_HEIGHT)];
    tv.controller = self;
    self.view = tv;
    
    tv.lineGraphView.controller = self;

    [track addObserver:self
            forKeyPath:@"frames"
               options: (NSKeyValueObservingOptionNew)
               context:@"MocoTimelineTrackViewControllerObserveFrames"];
        
}
         
- (void)dealloc {
    [track removeObserver:self forKeyPath:@"frames"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    NSKeyValueChange changeKind = [change[NSKeyValueChangeKindKey] intValue];
    
    if (changeKind == NSKeyValueChangeInsertion) {        
        NSIndexSet *changedIndexes = change[NSKeyValueChangeIndexesKey];
        [[self trackView] reloadDataForChangedFrames:changedIndexes];
    }
    else {
        [[self trackView] reloadData];

    }
    
    
    
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end
