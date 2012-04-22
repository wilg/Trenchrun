//
//  MocoDocument.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimelineViewController.h"

@interface MocoDocument : NSDocument {
    
    IBOutlet NSArrayController *trackArrayController;
    IBOutlet NSArrayController    *flattenedFrameArrayController;
    
    IBOutlet TimelineViewController *timelineViewController;
    
    IBOutlet NSView *timelineContainer;

    IBOutlet NSView *listView;
    
    IBOutlet NSSegmentedControl *viewSwapControl;

    BOOL recording;

    IBOutlet NSButton *playButton;
    
    IBOutlet NSWindow *documentWindow;
        
}

@property BOOL rigPlaybackEngaged;
@property (copy) NSMutableArray *trackList;
@property (copy) NSMutableArray *flattenedFrameArray;

-(IBAction)record:(id)sender;
-(IBAction)updateFakeTabs:(id)sender;
-(IBAction)swapViews:(id)sender;

@end
