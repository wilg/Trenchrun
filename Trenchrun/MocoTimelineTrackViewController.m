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
    BOOL kvoRegistered;
}
@end

@implementation MocoTimelineTrackViewController
@synthesize track;

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
    
    MocoTimelineTrackView *tv = [[MocoTimelineTrackView alloc] initWithFrame:NSMakeRect(0, 0, 500, 500)];
    tv.controller = self;
    self.view = tv;
    
    tv.lineGraphView.controller = self;
    
    NSLog(@"regster");
    [track addObserver:self
            forKeyPath:@"frames"
               options:0
               context:@"MocoTimelineTrackViewControllerObserveFrames"];
        
}
         
- (void)dealloc {
    NSLog(@"unregister");
    [track removeObserver:self forKeyPath:@"frames"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    NSLog(@"change observed");
    [[self trackView] reloadData];
    
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end
