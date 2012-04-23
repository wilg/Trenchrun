//
//  MocoDriver.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MocoProtocolConstants.h"
#import "MocoSerialConnection.h"

typedef enum {
    MocoStatusDisconnected,       // The rig is disconnected.
    MocoStatusSearchingForDevice, // The driver is still waiting for a positive response from each
                                  // plausible port option.
    MocoStatusAwaitingControl,    // The rig is connected but hasn't yet responded with control.
    MocoStatusIdle,               // The rig is connected but stationary.
    MocoStatusSeeking,            // The rig has been given a target position but is still moving towards it.
    MocoStatusPlayback            // The driver is playing back data to the rig.
} MocoStatusCode;

@interface MocoDriver : NSObject <MocoSerialConnectionDelegate> {
    MocoStatusCode status;
}

// Returns the current status code
@property(readonly) MocoStatusCode status;
@property(readonly) NSString *statusDescription;
@property(readonly) BOOL recordAndPlaybackOperational;
@property(readonly) NSImage *imageForStatus;

// Driver is asynchronous. You can request the following notifications.
// MocoDriverStatusDidChange
// MocoDriverAxisStatusDidChange
// MocoDriverPositionDidChange
// MocoDriverError

// 1. Computer initiates serial connection.
// 2. Computer sends ID request byte to MCU.
// 3. MCU sends ID byte to the computer.
// 4. If ID matches what it wants, the computer sends the axis status request byte.
// Places driver in MocoStatusIdle
- (void)establishConnection;

// Move a specified axis to a position.
// This will put the driver in MocoStatusSeeking
- (void)moveAxis:(MocoAxis)axis toPosition:(int)position;

// Starts playback.
// This should probably be a special wrapper class that contains data
// that is optimized for the device.
// Places driver in MocoStatusPlayback.
// When playback is concluded, the driver reverts to MocoStatusIdle.
// This will cause a MocoDriverStatusDidChange notification to be issued. 
- (void)beginPlaybackWithTracks:(NSArray *)tracks atFrame:(int)frameNumber;

// Still in MocoStatusPlayback. Just stops updating the MCU.
- (void)pausePlayback;

// Seeks the playback to a specified position.
- (void)seekPlaybackToTime:(int)position;

- (void)severConnections;

+(NSString *)statusDescriptionForStatusCode:(MocoStatusCode)code;

@end
