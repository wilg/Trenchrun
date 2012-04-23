//
//  MocoTimelinePlaybackAnimation.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTimelinePlaybackAnimation.h"

@implementation MocoTimelinePlaybackAnimation
@synthesize startTime;

+ (MocoTimelinePlaybackAnimation *)playTimelineAnimatedWithDelegate:(id)delegate
{
    
    NSTimeInterval duration = [(id<MocoTimelinePlaybackAnimationDelegate>)delegate durationOfTimelinePlaybackAnimation];
    
    MocoTimelinePlaybackAnimation *animation = [[MocoTimelinePlaybackAnimation alloc] initWithDuration:duration 
                                                                                        animationCurve:NSAnimationLinear];
    
    animation.delegate = delegate;
    animation.startTime = [(id<MocoTimelinePlaybackAnimationDelegate>)delegate currentPlayheadTimeForTimelineAnimation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [animation startAnimation];
    });

    return animation;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    
    [super setCurrentProgress:progress];

//    typedef float (^MyAnimationCurveBlock)(float, float, float);
//    MyAnimationCurveBlock cubicEaseInOut = ^ float (float t, float start, float end) {
//        t *= 2.;
//        if (t < 1.) return end/2 * t * t * t + start - 1.f;
//        t -= 2;
//        return end/2*(t * t * t + 2) + start - 1.f;
//    };
    
    NSTimeInterval seconds = self.startTime + self.currentProgress * self.duration;
        
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [(id<MocoTimelinePlaybackAnimationDelegate>)self.delegate timelinePlaybackAnimationDidAdvanceToTime:seconds];
//        NSPoint progressPoint = self.originPoint;
//        progressPoint.x += cubicEaseInOut(progress, 0, self.targetPoint.x - self.originPoint.x);
//        progressPoint.y += cubicEaseInOut(progress, 0, self.targetPoint.y - self.originPoint.y);
//        
//        [self.scrollView.documentView scrollPoint:progressPoint];
//        [self.scrollView displayIfNeeded];
    });
}

@end
