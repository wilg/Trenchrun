//
//  TimelineViewController.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoTimelineView.h"

@class MocoDocument;

@interface TimelineViewController : NSViewController <MocoTimelineViewDataSource> {
    __weak IBOutlet MocoDocument *document;
}

@end
