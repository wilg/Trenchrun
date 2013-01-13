//
//  MocoGameControllerManager.h
//  Trenchrun
//
//  Created by Wil Gieseler on 1/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Xbox360ControllerManager.h"
#import "MocoDriver.h"

@interface MocoGameControllerManager : NSObject <Xbox360ControllerDelegate> {
    BOOL _pollingThreadRunning;
    IBOutlet MocoDriver *mocoDriver;
    float _lastKnownYPosition;
}

@end
