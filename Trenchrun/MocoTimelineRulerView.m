//
//  MocoTimelineRulerView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelineRulerView.h"

@implementation MocoTimelineRulerView

- (void)drawBackgroundInRect:(NSRect)rect
{
    [[NSColor colorWithCalibratedWhite: 0.55 alpha: 1.0] set];
    [NSBezierPath fillRect: rect];
}

@end
