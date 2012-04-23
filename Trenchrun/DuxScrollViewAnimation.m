//
//  DuxScrollViewAnimation.m
//  Dux
//
//  Created by Abhi Beckert on 2011-11-30.
//  
//  This is free and unencumbered software released into the public domain.
//  For more information, please refer to <http://unlicense.org/>
//

#import "DuxScrollViewAnimation.h"

@implementation DuxScrollViewAnimation

@synthesize scrollView;
@synthesize originPoint;
@synthesize targetPoint;

+ (void)animatedScrollPointToCenter:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView
{
  NSRect visibleRect = scrollView.documentVisibleRect;
  
  targetPoint = NSMakePoint(targetPoint.x - (NSWidth(visibleRect) / 2), targetPoint.y - (NSHeight(visibleRect) / 2));
  
  [self animatedScrollToPoint:targetPoint inScrollView:scrollView];
}

+ (void)animatedScrollToPoint:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView duration:(NSTimeInterval)dur {
    DuxScrollViewAnimation *animation = [[DuxScrollViewAnimation alloc] initWithDuration:dur animationCurve:NSAnimationEaseInOut];
    
    animation.scrollView = scrollView;
    animation.originPoint = scrollView.documentVisibleRect.origin;
    animation.targetPoint = targetPoint;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [animation startAnimation];
    });
}

+ (void)animatedScrollToPoint:(NSPoint)targetPoint inScrollView:(NSScrollView *)scrollView
{
    [self animatedScrollToPoint:targetPoint inScrollView:scrollView duration:0.4];
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
  typedef float (^MyAnimationCurveBlock)(float, float, float);
  MyAnimationCurveBlock cubicEaseInOut = ^ float (float t, float start, float end) {
    t *= 2.;
    if (t < 1.) return end/2 * t * t * t + start - 1.f;
    t -= 2;
    return end/2*(t * t * t + 2) + start - 1.f;
  };
  
  
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    
    NSPoint progressPoint = self.originPoint;
    progressPoint.x += cubicEaseInOut(progress, 0, self.targetPoint.x - self.originPoint.x);
    progressPoint.y += cubicEaseInOut(progress, 0, self.targetPoint.y - self.originPoint.y);
    
    [self.scrollView.documentView scrollPoint:progressPoint];
    [self.scrollView displayIfNeeded];
  });
}

@end
