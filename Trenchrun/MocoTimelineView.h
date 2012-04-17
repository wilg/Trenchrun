//
//  MocoTimelineView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTrack.h"

@protocol MocoTimelineViewDataSource <NSObject>
@required;
- (int)numberOfTracks;
- (MocoTrack *)trackAtIndex:(int)index;
@end


@interface MocoTimelineView : NSView {
}

@property (assign) int playheadPosition; // in frames
@property (assign) float scaleFactor;    // 0.0-1.0
@property (assign) IBOutlet id<MocoTimelineViewDataSource> dataSource;

- (void)reload;


@end
