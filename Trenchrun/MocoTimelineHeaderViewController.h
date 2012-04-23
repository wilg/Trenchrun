//
//  MocoTimelineHeaderViewController.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTrack.h"
#import "MocoAxisVisualizationView.h"

@class TimelineViewController;

@interface MocoTimelineHeaderViewController : NSViewController {
    IBOutlet NSTextField *titleField;
    IBOutlet MocoAxisVisualizationView *visualizationView;
}
@property (assign) MocoTrack *track;

@end
