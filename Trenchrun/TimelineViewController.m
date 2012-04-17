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

@implementation TimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    
    }
    return self;
}

- (MocoTimelineView *)timelineView {
    return (MocoTimelineView *)self.view;
}

- (void)awakeFromNib {
    
    [self timelineView].dataSource = self;
    [[self timelineView] reload];
    
//    NSLog(@"FUCK FACE");
}

- (IBAction)refreshGraph:(id)sender {
    [[self timelineView] reload];
}

#pragma mark -
#pragma mark Track View Data Source

- (int)numberOfTracks {
    if (document && document.trackList){

    }
    else {
        return 0;
    }
    return document.trackList.count;
}

- (MocoTrack *)trackAtIndex:(int)index {
    return [document.trackList objectAtIndex:index];
}



@end
