//
//  MocoAxisPosition.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoAxisPosition.h"

@implementation MocoAxisPosition
@synthesize axis, position, resolution;

- (NSNumber *)rawPosition {
    return [NSNumber numberWithDouble: [self.position doubleValue] * [self.resolution doubleValue] ];
}

- (void)setRawPosition:(NSNumber *)newRaw {
    self.position = [NSNumber numberWithDouble: [newRaw doubleValue] / [self.resolution doubleValue]];
}

@end
