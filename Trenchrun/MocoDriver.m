//
//  MocoDriver.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoDriver.h"
#import "MocoDriverResponse.h"
#import "MocoTrack.h"
#import <ORSSerialPort/ORSSerialPort.h>
#import <ORSSerialPort/ORSSerialPortManager.h>

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

@property (strong) ORSSerialPort *currentPort;

@end

///// IMPLEMENTATION

@implementation MocoDriver
@synthesize playbackTracks, playbackPosition, axisResolutions;

# pragma mark Initializer

-(id)init {
	self = [super init];
	if (self) {
        
        killProcessorThread = NO;

        
        self.axisResolutions = [NSMutableDictionary dictionary];
        self.status = MocoStatusDisconnected;
        
        
        
        NSArray *availablePorts = [ORSSerialPortManager.sharedSerialPortManager availablePorts];
        if (availablePorts.count > 0) {
            self.currentPort = availablePorts[0];
        }

        if (self.currentPort) {
            [self establishConnection];
        }
        else {
            NSLog(@"MocoDriver - No serial ports available");
        }
        
	}
	return self;
}

- (void)establishConnection {
    NSLog(@"MocoDriver - Attempting to establish connection with %@", self.currentPort.path);
    
    // Set the intitial status.
    self.status = MocoStatusDisconnected;
    
    // Spin up a background thread to process data
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(dataProcessorThread:)
                                                   object:nil];
    [myThread start];
    
    // Open a serial connection.
    _serialConnection = [[MocoSerialConnection alloc] init];
    _serialConnection.delegate = self;
    _serialConnection.responseThread = myThread;
    [_serialConnection openThreadedConnectionWithSerialPort:self.currentPort.path baud:MocoProtocolBaudRate];
}

- (void)dataProcessorThread: (NSThread *) parentThread {
    @autoreleasepool {
        NSLog(@"MocoDriver - Data processing thread started.");
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
        
        NSLog(@"MocoDriver - Instructed device to start playback.");
        [_serialConnection writeIntAsByte:MocoProtocolStartPlaybackInstruction];
        long maxLength = 0;
        for (MocoTrack *track in self.playbackTracks) {
            if ([track length] > maxLength)
                maxLength = track.length;
        }
        long duration = maxLength - frameNumber;
        [_serialConnection writeLongAsFourBytes:duration];
        self.status = MocoStatusPlaybackBuffering;
    }
}

- (void)pausePlayback {
    if (self.recordAndPlaybackOperational) {
        NSLog(@"MocoDriver - Instructed device to stop playback.");
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
        ap.resolution = (self.axisResolutions)[[NSNumber numberWithInt:axis]];
        return ap;
    }
    return nil;
}

- (void)setPosition:(MocoAxisPosition *)position forAxis:(MocoAxis)axis {
    if (position) {
        [_serialConnection writeIntAsByte:MocoProtocolSeekPositionDataHeader];
        [_serialConnection writeIntAsByte:axis];
        [_serialConnection writeLongAsFourBytes:[position.rawPosition longValue]];
        NSLog(@"MocoDriver - Sent seek position: header=%i axis=%i rawPosition=%li", MocoProtocolSeekPositionDataHeader, axis, [position.rawPosition longValue]);
    }
}

- (void)requestAxisResolutionData {
    NSLog(@"MocoDriver - Instructed device to send axis resolution data.");
    [_serialConnection writeIntAsByte:MocoProtocolRequestAxisResolutionDataInstruction];
}

- (void)beginStreamingPositionData {
    NSLog(@"MocoDriver - Instructed device to start sending axis position data.");
    [_serialConnection writeIntAsByte:MocoProtocolStartSendingAxisDataInstruction];
}

- (void)stopStreamingPositionData {
    NSLog(@"MocoDriver - Instructed device to stop sending axis data.");
    [_serialConnection writeIntAsByte:MocoProtocolStopSendingAxisDataInstruction];
}

- (void)requestHandshake {
    NSLog(@"MocoDriver - Requesting handshake...");
    [_serialConnection writeIntAsByte:MocoProtocolRequestHandshakeInstruction];
}

- (void)notifyDeviceOfHostDisconnection {
    NSLog(@"MocoDriver - Notifying device of host disconnection.");
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
    NSLog(@"MocoDriver - Couldn't open connection. Error: %@", string);
}

- (void)serialMessageReceived:(NSData *)data {
    NSDate *methodStart;
    if (TIME_CONNECTION) {
        methodStart = [NSDate date];
    }

    MocoDriverResponse *driverResponse = [MocoDriverResponse responseWithData:data];
    
    if (driverResponse.type != MocoProtocolAxisPositionResponseType &&
        driverResponse.type != MocoProtocolNewlineDelimitedDebugStringResponseType) {
        NSLog(@"MocoDriver - Serial Message Received: %@", driverResponse);
    }
    
    if (driverResponse.type == MocoProtocolAxisPositionResponseType) {
        
        MocoAxisPosition *axisPosition = [[MocoAxisPosition alloc] init];
        
        NSNumber *axisNumber = (driverResponse.payload)[@"axis"];
        NSNumber *resolution = (self.axisResolutions)[axisNumber];
        if (resolution) {
            axisPosition.axis = [axisNumber intValue];
            axisPosition.resolution = resolution;
            axisPosition.rawPosition = (driverResponse.payload)[@"rawPosition"];
            
            [self postNotification:@"MocoAxisPositionUpdated" object:axisPosition];
        }
        else {
            NSLog(@"MocoDriver - Position data received for unnormalizable axis.");
        }
        
        
    }
    else if (driverResponse.type == MocoProtocolAxisResolutionResponseType) {
        
        (self.axisResolutions)[(driverResponse.payload)[@"axis"]] = (driverResponse.payload)[@"resolution"];
                
        [self postNotification:@"MocoAxisResolutionUpdated" object:driverResponse];

    }
    else if (driverResponse.type == MocoProtocolAdvancePlaybackRequestType) {

        MocoAxis axis = [(driverResponse.payload)[@"axis"] intValue];
        [self writeNextPlaybackFrameToConnectionOnAxis:axis];
        
        [self postNotification:@"MocoPlaybackAdvanced" object:driverResponse];
    }
    else if (driverResponse.type == MocoProtocolHandshakeResponseType) {
        if ([(driverResponse.payload)[@"successful"] boolValue] == YES) {
            [self handshakeSuccessful];
        }
        else {
            [self handshakeFailed];
        }
    }
    else if (driverResponse.type == MocoProtocolNewlineDelimitedDebugStringResponseType) {
        NSLog(@"MocoDriver - Device Message: %@", (driverResponse.payload)[@"message"]);
    }
    else if (driverResponse.type == MocoProtocolPlaybackCompleteNotificationResponseType) {
        [self postNotification:@"MocoRigPlaybackComplete" object:driverResponse];        
        self.status = MocoStatusIdle;
    }
    else if (driverResponse.type == MocoProtocolPlaybackStartingNotificationResponseType) {
        [self postNotification:@"MocoRigPlaybackStarted" object:driverResponse];        
        self.status = MocoStatusPlayback;
    }
    else if (driverResponse.type == MocoProtocolPlaybackAbortedNotificationResponseType) {
        [self postNotification:@"MocoRigPlaybackAborted" object:driverResponse];        
        self.status = MocoStatusIdle;
    }
    else {
        NSLog(@"MocoDriver - The serial message was received and processed but no action was taken.");
    }
        
    if (TIME_CONNECTION) {
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"MocoDriver - serialMessageReceived took %fms.", executionTime * 1000); 
    }
}

-(void)postNotification:(NSString *)name object:(id)object {
    // Always posts on main thread.
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
            
            NSLog(@"MocoDriver - Sent playback frame: header=%i axis=%i rawPosition=%li", MocoProtocolPlaybackFrameDataHeader, axis, [position.rawPosition longValue]);
        }
        else {
            NSLog(@"MocoDriver - Couldn't write next frame. Possibly out of bounds.");
        }
        
        if (self.playbackPosition >= [[self trackWithAxis:axis] length]) {
            NSLog(@"MocoDriver - Notified device that it has received the last playback frame.");
            [_serialConnection writeIntAsByte:MocoProtocolPlaybackLastFrameSentNotificationInstruction];
        }

    }
    else {
        NSLog(@"MocoDriver - Device requested playback but it has already finished.");
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
    [self postNotification:@"MocoDriverStatusDidChange" object:[NSNumber numberWithInt:self.status]];
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
    } else if (code == MocoStatusPlaybackBuffering) {
        return @"Initializing Playback";
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
        self.status == MocoStatusAwaitingControl ||
        self.status == MocoStatusPlaybackBuffering ) {
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
