//
//  MocoAxisPosition.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MocoProtocolConstants.h"

@interface MocoAxisPosition : NSObject

@property MocoAxis axis;
@property (retain) NSNumber *position;
@property (retain) NSNumber *resolution;

// Must set resolution before setting rawPosition;
@property (retain) NSNumber *rawPosition;

@end
