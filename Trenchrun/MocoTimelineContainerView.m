//
//  MocoTimelineContainerView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelineContainerView.h"

@interface MocoTimelineContainerView ( /* class extension */ ) {
@private
    NSColor *noiseColor;
}

@end

@implementation MocoTimelineContainerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        noiseColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"noise.png"]];
        self.canDrawConcurrently = YES;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRec {
    
    // Fill view with a top-down gradient
    // from startingColor to endingColor
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor: [NSColor colorWithCalibratedWhite:0.35 alpha:1.0]
                             endingColor: [NSColor colorWithCalibratedWhite:0.15 alpha:1.0]];
    [aGradient drawInRect:[self bounds] angle:-90];

    [noiseColor set];
    NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);

}

@end
