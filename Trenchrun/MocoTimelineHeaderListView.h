//
//  MocoTimelineHeaderListView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TimelineViewController;
@class MocoTimelineHeaderView;

@interface MocoTimelineHeaderListView : NSView

@property (assign) TimelineViewController *controller;

- (void)addHeaderView:(MocoTimelineHeaderView *)headerView;

@end
