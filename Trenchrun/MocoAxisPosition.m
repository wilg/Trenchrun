//
//  MocoAxisPosition.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/21/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoAxisPosition.h"

@implementation MocoAxisPosition
@synthesize axis, position, resolution;

- (NSNumber *)rawPosition {
//    return self.position;
    return @([self.position doubleValue] * [self.resolution doubleValue]);
}

- (void)setRawPosition:(NSNumber *)newRaw {
//    self.position = newRaw;
    self.position = @([newRaw doubleValue] / [self.resolution doubleValue]);
}

-(NSInteger)rotationNumber {
    return (NSInteger)round([self.position doubleValue]);
}

-(double)degreesPosition {
    return [self.position doubleValue] * 360.0;
}

-(double)radiansPosition {
    return ([self.position doubleValue] * 360.0) / 180.0 * M_PI;
}

@end
