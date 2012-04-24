//
//  MocoLineGraphView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTimelineTrackViewController.h"

@interface MocoLineGraphView : NSView
@property (retain) MocoTimelineTrackViewController *controller;

-(void)reloadData;
-(void)reloadDataForChangedFrames:(NSIndexSet *)changedFramesSet;

@end
