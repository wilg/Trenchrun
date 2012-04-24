//
//  MocoTimelinePlaybackAnimation.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/23/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MocoTimelinePlaybackAnimationDelegate <NSObject>
@required;
- (NSTimeInterval)durationOfTimelinePlaybackAnimation;
- (void)timelinePlaybackAnimationDidAdvanceToTime:(NSTimeInterval)seconds;
- (NSTimeInterval)currentPlayheadTimeForTimelineAnimation;
@end

@interface MocoTimelinePlaybackAnimation : NSAnimation
@property NSTimeInterval startTime;

+ (MocoTimelinePlaybackAnimation *)playTimelineAnimatedWithDelegate:(id)delegate;

@end
