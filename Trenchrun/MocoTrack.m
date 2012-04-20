//
//  MocoTrack.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoTrack.h"
#import "MocoFrame.h"

@implementation MocoTrack
@synthesize frames = _frames;
@synthesize axis = _axis;

- init {
	if (self = [super init]) {
        _frames = [NSMutableArray array];
	}
	return self;	
}

+(NSArray *)flattenedTracks:(NSArray *)tracks {
    
    //let's assume all tracks are the same length right now
    NSMutableArray *flattenedArray = [NSMutableArray array];
    
    for (int i = 0; i < [[(MocoTrack *)[tracks objectAtIndex:0] frames] count]; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        int frameNumber = -1;
        for (MocoTrack *track in tracks) {
            MocoFrame *thisFrame = [track.frames objectAtIndex:i];
            if (frameNumber == -1 || [thisFrame.frameNumber intValue] == frameNumber) {
                [dict setObject:thisFrame.position forKey:[[NSNumber numberWithInt:track.axis] stringValue]];
                frameNumber = [thisFrame.frameNumber intValue];
            }
        }
        [flattenedArray addObject:[dict copy]];
    }
    
    return [flattenedArray copy];
}

-(void)addFrame:(MocoFrame *)frame {
    // KVO compliance    
    NSMutableArray *frames = [self mutableArrayValueForKey:@"frames"];
    [frames addObject:frame];
}

-(void)appendFrameWithPosition:(NSNumber *)position {
    int nextFrame = self.frames.count;
    nextFrame++;
    
    MocoFrame *frame = [[MocoFrame alloc] init];
    frame.frameNumber = [NSNumber numberWithInt:nextFrame];
    frame.position = position;
    [self addFrame:frame];
}

- (NSString *)title {
    if (self.axis == MocoAxisCameraPan) {
        return @"Camera Pan";
    }
    else if (self.axis == MocoAxisCameraTilt) {
        return @"Camera Tilt";
    }
    else if (self.axis == MocoAxisJibLift) {
        return @"Jib Lift";
    }
    else if (self.axis == MocoAxisJibSwing) {
        return @"Jib Swing";
    }
    else if (self.axis == MocoAxisDollyPosition) {
        return @"Dolly Position";
    }
    else if (self.axis == MocoAxisFocus) {
        return @"Focus";
    }
    else if (self.axis == MocoAxisIris) {
        return @"Iris";
    }
    else if (self.axis == MocoAxisZoom) {
        return @"Zoom";
    }
    return @"Unknown Track";
}

#pragma mark ======== Archiving and unarchiving methods =========

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeObject:self.frames forKey:@"frames"];
    [coder encodeObject:[NSNumber numberWithInt:self.axis] forKey:@"axis"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
    if (self = [super init])
	{
        self.frames = [coder decodeObjectForKey:@"frames"];
        self.axis   = [[coder decodeObjectForKey:@"axis"] intValue];
    }
    return self;
}

@end
