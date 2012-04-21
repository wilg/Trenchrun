//
//  MocoTrack.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MocoFrame.h"
#import "MocoSharedSpec.h"

@interface MocoTrack : NSObject {
    
}
@property (copy)    NSMutableArray *frames;
@property (assign)  MocoAxis axis;
@property (readonly)  NSString *title;

@property (assign) BOOL recordEnabled;
@property (assign) BOOL muted;
@property (assign) BOOL soloed;

+(NSArray *)flattenedTracks:(NSArray *)tracks;

-(void)addFrame:(MocoFrame *)frame;
-(void)appendFrameWithPosition:(NSNumber *)position;
- (NSColor *)color;

@end
