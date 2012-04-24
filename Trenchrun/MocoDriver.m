//
//  MocoDriver.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoDriver.h"
#import "MocoDriverResponse.h"
#import "MocoAxisPosition.h"
#import "MocoTrack.h"

#define TIME_CONNECTION NO

@interface MocoDriver () {
@private
    
    MocoStatusCode _status;
    
        
    MocoSerialConnection *_serialConnection;
    
    BOOL killProcessorThread;
    
}
@property (assign) MocoStatusCode status;

@property (retain) NSArray *playbackTracks;
@property (assign) NSInteger playbackPosition;

@property (retain) NSMutableDictionary *axisResolutions;

@end

///// IMPLEMENTATION

@implementation MocoDriver
@synthesize playbackTracks, playbackPosition, axisResolutions;
//@synthesize port;

# pragma mark Initializer

-(id)init {
	self = [super init];
	if (self) {
        
        killProcessorThread = NO;

        
        self.axisResolutions = [NSMutableDictionary dictionary];
        
        self.status = MocoStatusDisconnected;
        
        
        [self establishConnection];
        
        
	}
	return self;
}

- (void)establishConnection {
    NSLog(@"intializing hardcoded port");

    
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(dataProcessorThread:)
                                                   object:nil];
    [myThread start];  // Actually create the thread
    
    _serialConnection = [[MocoSerialConnection alloc] init];
    _serialConnection.delegate = self;
    _serialConnection.responseThread = myThread;

    
    self.status = MocoStatusDisconnected;
    [_serialConnection openThreadedConnectionWithSerialPort:@"/dev/cu.usbserial-A6008RQE" baud:MocoProtocolBaudRate];
}

//- (void)dataProcessorThread: (NSThread *) parentThread {
//	
//    @autoreleasepool {
//        
//        
//        // assign a high priority to this thread
//        [NSThread setThreadPriority:1.0];
//                
//        NSLog(@"MocoDriver dataProcessorThread arrived!");
//        // this will loop unitl the serial port closes
//        while(killProcessorThread == NO) {
//
//            
//        }
//
//    }
//}

- (void)dataProcessorThread: (NSThread *) parentThread {
    @autoreleasepool {
       
        NSLog(@"hello from vegas");
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        BOOL running = YES;
        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        while (running && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]){
            //run loop spinned ones
        }
    
    }
}

- (void)beginPlaybackWithTracks:(NSArray *)tracks atFrame:(int)frameNumber {
    if (self.recordAndPlaybackOperational) {
        self.playbackTracks = tracks;
        self.playbackPosition = frameNumber;
        
        [self stopStreamingPositionData];
        
        NSLog(@"Asked device to start playback...");
        [_serialConnection writeIntAsByte:MocoProtocolStartPlaybackInstruction];
        self.status = MocoStatusPlaybackBuffering;
    }
}

- (void)pausePlayback {
    if (self.recordAndPlaybackOperational) {
        NSLog(@"Asked device to stop playback...");
        [_serialConnection writeIntAsByte:MocoProtocolStopPlaybackInstruction];
        [self beginStreamingPositionData];
        self.status = MocoStatusIdle;
    }
}

- (MocoTrack *)trackWithAxis:(MocoAxis)axis {
    for (MocoTrack *track in self.playbackTracks) {
        if (track.axis == axis)
            return track;
    }
    return nil;
}

- (MocoAxisPosition *)positionForAxis:(MocoAxis)axis atFrame:(NSInteger)frameNumber {
    MocoTrack *track = [self trackWithAxis:axis];
    if ([track containsFrameNumber:frameNumber]) {
        MocoAxisPosition *ap = [track axisPositionAtFrameNumber:frameNumber];
        ap.resolution = [self.axisResolutions objectForKey:[NSNumber numberWithInt:axis]];
        return ap;
    }
    return nil;
}

- (void)requestAxisResolutionData {
    NSLog(@"Asking rig to start sending axis resolution...");
    [_serialConnection writeIntAsByte:MocoProtocolRequestAxisResolutionDataInstruction];
}

- (void)beginStreamingPositionData {
    NSLog(@"Asking rig to start sending axis position data...");
    [_serialConnection writeIntAsByte:MocoProtocolStartSendingAxisDataInstruction];
}

- (void)stopStreamingPositionData {
    NSLog(@"Asking rig to cease sending axis data...");
    [_serialConnection writeIntAsByte:MocoProtocolStopSendingAxisDataInstruction];
}

- (void)requestHandshake {
    NSLog(@"MocoDriver - Requesting handshake...");
    [_serialConnection writeIntAsByte:MocoProtocolRequestHandshakeInstruction];
}

- (void)notifyDeviceOfHostDisconnection {
    NSLog(@"Notifying device of host disconnection...");
    [_serialConnection writeIntAsByte:MocoProtocolHostWillDisconnectNotificationInstruction];
}

- (void)openSerialConnectionSuccessful {
    self.status = MocoStatusAwaitingControl;
    [NSTimer scheduledTimerWithTimeInterval:MocoProtocolPortOpenedWaitTime
                                     target:self 
                                   selector:@selector(requestHandshake) 
                                   userInfo:nil 
                                    repeats:NO];
}

- (void)openSerialConnectionFailedWithMessage:(NSString *)string {
    self.status = MocoStatusDisconnected;
    NSLog(@"MocoDriver - Couldn't open connection - %@", string);
}

- (void)serialMessageReceived:(NSData *)data {
    NSDate *methodStart;
    if (TIME_CONNECTION) {
        methodStart = [NSDate date];
    }

    MocoDriverResponse *driverResponse = [MocoDriverResponse responseWithData:data];
    
    if (driverResponse.type != MocoProtocolAxisPositionResponseType &&
        driverResponse.type != MocoProtocolNewlineDelimitedDebugStringResponseType) {
        NSLog(@"Serial Message Received: %@", driverResponse);
    }
    
    if (driverResponse.type == MocoProtocolAxisPositionResponseType) {
        
//        NSLog(@"Axis position received.");

        MocoAxisPosition *axisPosition = [[MocoAxisPosition alloc] init];
        
        NSNumber *axisNumber = [driverResponse.payload objectForKey:@"axis"];
        NSNumber *resolution = [self.axisResolutions objectForKey:axisNumber];
        if (resolution) {
            axisPosition.axis = [axisNumber intValue];
            axisPosition.resolution = resolution;
            axisPosition.rawPosition = [driverResponse.payload objectForKey:@"rawPosition"];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoAxisPositionUpdated"
//                                                                object:axisPosition];

            [self postNotificationOnMainThread:@"MocoAxisPositionUpdated" object:axisPosition];

        }
        else {
            NSLog(@"Position data received for unnormalizable axis.");
        }
        
        
    }
    else if (driverResponse.type == MocoProtocolAxisResolutionResponseType) {
        
        [self.axisResolutions setObject:[driverResponse.payload objectForKey:@"resolution"] 
                             forKey:[driverResponse.payload objectForKey:@"axis"]];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoAxisResolutionUpdated"
//                                                            object:driverResponse];
        
        [self postNotificationOnMainThread:@"MocoAxisResolutionUpdated" object:driverResponse];

        
    }
    else if (driverResponse.type == MocoProtocolAdvancePlaybackRequestType) {
        
//        for (int i = 0; i < 10; i++) {
            MocoAxis axis = [[driverResponse.payload objectForKey:@"axis"] intValue];
            [self writeNextPlaybackFrameToConnectionOnAxis:axis];
//        }

//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoPlaybackAdvanced"
//                                                            object:driverResponse];
        
        [self postNotificationOnMainThread:@"MocoPlaybackAdvanced" object:driverResponse];

        
    }
    else if (driverResponse.type == MocoProtocolHandshakeResponseType) {
        NSLog(@"right tytpe");
        if ([[driverResponse.payload objectForKey:@"successful"] boolValue] == YES) {
            [self handshakeSuccessful];
        }
        else {
            [self handshakeFailed];
        }
    }
    else if (driverResponse.type == MocoProtocolNewlineDelimitedDebugStringResponseType) {
        NSLog(@"Device Message: %@", [driverResponse.payload objectForKey:@"message"]);
    }
    else if (driverResponse.type == MocoProtocolPlaybackCompleteNotificationResponseType) {
        self.status = MocoStatusIdle;
    }
    else if (driverResponse.type == MocoProtocolPlaybackStartingNotificationResponseType) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoRigPlaybackStarted"
//                                                            object:driverResponse];
        
        [self postNotificationOnMainThread:@"MocoRigPlaybackStarted" object:driverResponse];

        
        self.status = MocoStatusPlayback;
    }
    else {
        NSLog(@"Serial message recieved but not understood.");
    }
        
    if (TIME_CONNECTION) {
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"serialMessageReceived took %f ms", executionTime * 1000); 
    }
}

-(void)postNotificationOnMainThread:(NSString *)name object:(id)object {
    NSNotification *note = [NSNotification notificationWithName:name  object:object userInfo:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) 
                                                           withObject:note 
                                                        waitUntilDone:NO];

}

-(void)writeNextPlaybackFrameToConnectionOnAxis:(MocoAxis)axis {
    if (self.status == MocoStatusPlayback ||
        self.status == MocoStatusPlaybackBuffering) {
        MocoAxisPosition *position = [self positionForAxis:axis atFrame:self.playbackPosition];
        
        if (position) {
            [_serialConnection writeIntAsByte:MocoProtocolPlaybackFrameDataHeader];
            [_serialConnection writeIntAsByte:axis];
            [_serialConnection writeLongAsFourBytes:[position.rawPosition longValue]];
            
            self.playbackPosition = self.playbackPosition + 1;
            
            NSLog(@"Sent playback frame: header=%i axis=%i rawPosition=%li)", MocoProtocolPlaybackFrameDataHeader, axis, [position.rawPosition longValue]);
        }
        else {
            NSLog(@"Couldn't write next frame. Possibly out of bounds.");
        }
    }
    else {
        NSLog(@"Device requested playback but it has already finished.");
    }
}

-(void)handshakeSuccessful {
    self.status = MocoStatusIdle;
    
    [self requestAxisResolutionData];
    [self beginStreamingPositionData];
}

-(void)handshakeFailed {
    NSLog(@"MocoDriver - Handshake failed.");
    
    [self severConnections];
    [_serialConnection closePort];
    
    self.status = MocoStatusDisconnected;
}

- (void)severConnections {
    killProcessorThread = YES;
    [self notifyDeviceOfHostDisconnection];
}

# pragma mark Status

-(void)setStatus:(MocoStatusCode)newStatus {
    _status = newStatus;
//    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MocoDriverStatusDidChange" object:[NSNumber numberWithInt:self.status]];
    [self postNotificationOnMainThread:@"MocoDriverStatusDidChange" object:[NSNumber numberWithInt:self.status]];
//    NSLog(@"Status updated: %@", [self statusDescription]);
}

-(MocoStatusCode)status {
    return _status;
}

+(NSString *)statusDescriptionForStatusCode:(MocoStatusCode)code {
    if (code == MocoStatusDisconnected) {
        return @"No Devices Found";
    } else if (code == MocoStatusSearchingForDevice) {
        return @"Searching for Devices...";
    } else if (code == MocoStatusAwaitingControl) {
        return @"Assuming Direct Control...";
    } else if (code == MocoStatusIdle) {
        return @"Idle";
    } else if (code == MocoStatusSeeking) {
        return @"Seeking...";
    } else if (code == MocoStatusPlayback) {
        return @"Playing Back";
    }
    return nil;
}

-(NSString *)statusDescription {
    return [MocoDriver statusDescriptionForStatusCode:self.status];
}

-(NSImage *)imageForStatus {
    if (self.status == MocoStatusIdle || 
        self.status == MocoStatusSeeking ||
        self.status == MocoStatusPlayback ) {
        return [NSImage imageNamed:@"rig_status_green.png"];
    }
    if (self.status == MocoStatusSearchingForDevice || 
        self.status == MocoStatusAwaitingControl ) {
        return [NSImage imageNamed:@"rig_status_yellow.png"];
    }
    return [NSImage imageNamed:@"rig_status_red.png"];
}

-(BOOL)recordAndPlaybackOperational {
    if (self.status == MocoStatusIdle || 
        self.status == MocoStatusSeeking ||
        self.status == MocoStatusPlaybackBuffering ||
        self.status == MocoStatusPlayback ) {
        return YES;
    }
    return NO;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"recordAndPlaybackOperational"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"status",nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    if ([key isEqualToString:@"imageForStatus"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:@"status",nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }

    return keyPaths;
}


@end
