//
//  MocoAxisVisualizationView.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/22/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MocoProtocolConstants.h"
#import "MocoAxisPosition.h"

@interface MocoAxisVisualizationView : NSView
@property MocoAxis axis;
@property double position;
@property MocoAxisPosition *axisPosition;

-(IBAction)setPositionFromSlider:(id)sender;

@end
