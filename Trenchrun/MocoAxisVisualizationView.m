//
//  MocoAxisVisualizationView.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/22/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoAxisVisualizationView.h"
#import <QuartzCore/QuartzCore.h>

@interface MocoAxisVisualizationView() {
@private
    NSImageView *_horizonView;
    NSImageView *_axisView;
    
    MocoAxis _axis;
}

@end

@implementation MocoAxisVisualizationView
@synthesize position = _position;
@synthesize axisPosition = _axisPosition;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.wantsLayer = YES;
        
        // Initialization code here.
        _horizonView = [[NSImageView alloc] initWithFrame:self.bounds];
        _horizonView.image = [NSImage imageNamed:@"asis_visualization_horizon.png"];
        _horizonView.imageScaling = NSImageScaleAxesIndependently;
        _horizonView.wantsLayer = YES;

        [self addSubview:_horizonView];
        
        _axisView    = [[NSImageView alloc] initWithFrame:NSInsetRect(self.bounds, 5, 5)];
        _axisView.imageScaling = NSImageScaleProportionallyDown;
        _axisView.wantsLayer = YES;

        [self updatePosition:1.3];
        self.axis = MocoAxisCameraTilt;
        
        [self addSubview:_axisView];
        
    }
    
    return self;
}

- (MocoAxis)axis {
    return _axis;
}

-(void)updatePosition:(double)position {
    self.position = position;
    [self placeAtPosition];

}

-(MocoAxisPosition *)axisPosition {
    return _axisPosition;
}

-(void)setAxisPosition:(MocoAxisPosition *)axisPosition {
    _axisPosition = axisPosition;
    [self placeAtPosition];
}

-(void)placeAtPosition {
    
    // Modify any animatable properties
    //    [_axisView.animator setBoundsRotation:position * 360.0];
    
    //    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(5 * M_PI / 2.0);
    //    [_axisView.layer setAffineTransform:rotateTransform];
    //    [_axisView setNeedsDisplay];
//    NSLog(@"layer %@", _axisView.layer);
    
    [CATransaction begin];
    [CATransaction setValue:@0.00f
                     forKey:kCATransactionAnimationDuration];
    
    

    [_axisView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    _axisView.layer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2); 
    _axisView.layer.transform = CATransform3DMakeRotation(self.axisPosition.radiansPosition, 0.0, 0.0, 1.0);
    
    [CATransaction commit];

}

-(void)setAxis:(MocoAxis)axis {
    _axis = axis;
    if (_axis == MocoAxisCameraTilt) {
        _axisView.image = [NSImage imageNamed:@"axis_visualization_tilt_white.png"];
    }
    else {
        _axisView.image = [NSImage imageNamed:@"axis_visualization_tilt_white.png"];
    }
}

-(IBAction)setPositionFromSlider:(id)sender {
    [self updatePosition:[sender doubleValue]];
    
}

-(BOOL)isFlipped  {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
//    [_axisView.layer setAnchorPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)];

    _axisView.frame = NSInsetRect(self.bounds, 5, 5);
    [self fillFrame:self.bounds withView:_horizonView proportions:NSMakeSize(50, 50)];
    [self placeAtPosition];

 
}

- (void)fillFrame:(NSRect)frame withView:(NSView *)view proportions:(NSSize)proportions {

    float newWidth = frame.size.width;
    float newHeight = frame.size.height;
    float yoffset = 0;
    float xoffset = 0;
    if (frame.size.width > frame.size.height) {
        newHeight = frame.size.width;
        yoffset = (newHeight - frame.size.height) / 2;
    }
    else {
        newWidth = frame.size.height;
        xoffset = (newWidth - frame.size.width) / 2;
    }
    
    

    NSRect newFrame = NSMakeRect(frame.origin.x - xoffset, frame.origin.y - yoffset, newWidth, newHeight);
    
    view.frame = newFrame;
    
}

@end
