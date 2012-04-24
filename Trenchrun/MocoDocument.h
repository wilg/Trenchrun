//
//  MocoDocument.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/13/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimelineViewController.h"
#import "MocoTimelinePlaybackAnimation.h"

@interface MocoDocument : NSDocument<MocoTimelinePlaybackAnimationDelegate> {
    
    IBOutlet NSArrayController *trackArrayController;
    IBOutlet NSArrayController    *flattenedFrameArrayController;
    
    IBOutlet TimelineViewController *timelineViewController;
    
    IBOutlet NSView *timelineContainer;

    IBOutlet NSView *listView;
    
    IBOutlet NSSegmentedControl *viewSwapControl;

    IBOutlet NSButton *playButton;
    IBOutlet NSButton *recordButton;
    
    IBOutlet NSWindow *documentWindow;
        
}

@property BOOL rigPlaybackEngaged;
@property BOOL recording;
@property BOOL playing;
@property (retain) NSMutableArray *trackList;
@property (assign) int fps;

-(IBAction)record:(id)sender;
-(IBAction)updateFakeTabs:(id)sender;
-(IBAction)swapViews:(id)sender;

@end
