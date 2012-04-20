//
//  MocoTimelineTrackViewController.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelineTrackView.h"
#import "MocoTimelineTrackViewController.h"
#import "MocoLineGraphView.h"

@interface MocoTimelineTrackViewController () {
}
@end

@implementation MocoTimelineTrackViewController
@synthesize track;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    MocoTimelineTrackView *tv = [[MocoTimelineTrackView alloc] initWithFrame:NSMakeRect(0, 0, 500, 500)];
    tv.controller = self;
    self.view = tv;
    
    tv.lineGraphView.controller = self;

}

@end
