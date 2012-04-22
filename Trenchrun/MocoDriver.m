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


@interface MocoDriver ( /* class extension */ ) {
@private
//	AMSerialPort *port;
    
    MocoStatusCode _status;
    
    NSMutableArray *_portPaths;
    int _currentPortPathIndex;
    BOOL _waitingForPortHandshakeResponse;
    NSString *_rigPortPath;
    
    NSMutableDictionary *_axisResolutions;
    
    MocoSerialConnection *_serialConnection;
    
    NSArray *_playbackTracks;
    NSInteger _playbackPosition;
}
//@property (retain) AMSerialPort *port;
@property (assign) MocoStatusCode status;

- (void)findMocoRig;
- (void)testNextPort;
@end

///// IMPLEMENTATION

@implementation MocoDriver
//@synthesize port;

# pragma mark Initializer

-(id)init {
	self = [super init];
	if (self) {

//        // Register for port list updated notifications.
//        [[NSNotificationCenter defaultCenter] addObserver:self 
//                                                 selector:@selector(didAddPorts:)
//                                                     name:AMSerialPortListDidAddPortsNotification 
//                                                   object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(didRemovePorts:) 
//                                                     name:AMSerialPortListDidRemovePortsNotification 
//                                                   object:nil];
        
        /// initialize port list to arm notifications
//        [AMSerialPortList sharedPortList];
        
        _axisResolutions = [NSMutableDictionary dictionary];
        
        self.status = MocoStatusDisconnected;
        
        // Search all available ports for moco rig.
//        [self findMocoRig];
        
        _serialConnection = [[MocoSerialConnection alloc] init];
        _serialConnection.delegate = self;
        
        NSLog(@"intializing hardcoded port");
        
        self.status = MocoStatusDisconnected;
        [_serialConnection openThreadedConnectionWithSerialPort:@"/dev/cu.usbserial-A800H22L" baud:MocoProtocolBaudRate];
        
        
        
	}
	return self;
}

- (void)beginPlaybackWithTracks:(NSArray *)tracks atFrame:(int)frameNumber {
    _playbackTracks = tracks;
    _playbackPosition = frameNumber;
    
    [_serialConnection writeIntAsByte:MocoProtocolStopSendingAxisDataInstruction];
    [_serialConnection writeIntAsByte:MocoProtocolStartPlaybackInstruction];
}

- (void)pausePlayback {
//    [_serialConnection writeIntAsByte:MocoProtocolStopPlaybackInstruction];
//    [_serialConnection writeIntAsByte:MocoProtocolStartSendingAxisDataInstruction];
}

- (MocoTrack *)trackWithAxis:(MocoAxis)axis {
    for (MocoTrack *track in _playbackTracks) {
        if (track.axis == axis)
            return track;
    }
    return nil;
}

- (MocoAxisPosition *)positionForAxis:(MocoAxis)axis atFrame:(NSInteger)frameNumber {
   MocoAxisPosition *ap = [[self trackWithAxis:axis] axisPositionAtFrameNumber:frameNumber];
    ap.resolution = [_axisResolutions objectForKey:[NSNumber numberWithInt:axis]];
    return ap;
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
    [NSTimer scheduledTimerWithTimeInterval:1.5f
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
    MocoDriverResponse *driverResponse = [MocoDriverResponse responseWithData:data];
    
    if (driverResponse.type != MocoProtocolAxisPositionResponseType) {
        NSLog(@"Serial Message Received: %@", driverResponse);
    }
    else {
        NSLog(@"---------");
    }
    
    if (driverResponse.type == MocoProtocolAxisPositionResponseType) {
        
        MocoAxisPosition *axisPosition = [[MocoAxisPosition alloc] init];
        
        NSNumber *axisNumber = [driverResponse.payload objectForKey:@"axis"];
        NSNumber *resolution = [_axisResolutions objectForKey:axisNumber];
        if (resolution) {
            axisPosition.axis = [axisNumber intValue];
            axisPosition.resolution = resolution;
            axisPosition.rawPosition = [driverResponse.payload objectForKey:@"rawPosition"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoAxisPositionUpdated"
                                                                object:axisPosition];
            
        }
        else {
            NSLog(@"Position data received for unnormalizable axis.");
        }
        
        
    }
    else if (driverResponse.type == MocoProtocolAxisResolutionResponseType) {
        
        [_axisResolutions setObject:[driverResponse.payload objectForKey:@"resolution"] 
                             forKey:[driverResponse.payload objectForKey:@"axis"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoAxisResolutionUpdated"
                                                            object:driverResponse];
        
    }
    else if (driverResponse.type == MocoProtocolAdvancePlaybackRequestType) {
        
        NSLog(@"Sending next frame to arduino...");
        
        MocoAxis axis = [[driverResponse.payload objectForKey:@"axis"] intValue];
        MocoAxisPosition *position = [self positionForAxis:axis atFrame:_playbackPosition];
        
        [_serialConnection writeIntAsByte:MocoProtocolPlaybackFrameDataHeader];
        [_serialConnection writeIntAsByte:axis];
        [_serialConnection writeLongAsFourBytes:[position.rawPosition longValue]];
        
        _playbackPosition++;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoPlaybackAdvanced"
                                                            object:driverResponse];
        
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
    [self notifyDeviceOfHostDisconnection];

//    NSLog(@"MocoDriver - Closing ports.");
//    [_serialConnection closePort];
}

# pragma mark Auto-discovery
//- (void)findMocoRig {
//    
//    // Switch into search mode
//    self.status = MocoStatusSearchingForDevice;
//    
//    
//    // Add all the ports to an array.
//    _portPaths = [NSMutableArray array];
//
//    NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
//    AMSerialPort *aPort;
//    [_portPaths removeAllObjects];
//    
//    while (aPort = [enumerator nextObject]) {
//        [_portPaths addObject:[aPort bsdPath]];
//    }
//    
//    // Now we're going to try to connect to each one.
//    _currentPortPathIndex = 0;
//    
//    [self testNextPort];
//}

//- (void)testNextPort {
//    
//    if (_rigPortPath) {
//        return;
//    }
//    
//    if (_currentPortPathIndex >= _portPaths.count) {
//        NSLog(@"MocoDriver - Out of options. There's no rig connected.");
//        self.status = MocoStatusDisconnected;
//        return;
//    }
//    
//    if ([self requestHandshakeForDeviceName:[_portPaths objectAtIndex:_currentPortPathIndex]]){
//        // this will set a timer
//    }
//    else {
//        // Couldn't send a handshake request.
//        // Try the next one.
//        
//        NSLog(@"MocoDriver - Couldn't establish connection. Trying another port...");
//
//        _currentPortPathIndex++;
//        [self testNextPort];
//    }
//}

//- (void)handshakeRequestCallback {
//    
//    if([port isOpen]) {
//        
////        [port writeData:[NSData dataWithBytes:&kMocoHandshakeRequest length:sizeof(kMocoHandshakeRequest)] error:NULL];
//        NSLog(@"MocoDriver - Connected and requested handshake with %@", [_portPaths objectAtIndex:_currentPortPathIndex]);
//        
//        // If we could send a handshake request to this device.
//        // We'll set a 200ms timeout to allow the device to respond.
//        // If it does, we'll stop searching and save that device.
//        // If not, we'll keep searching.
//        [NSTimer scheduledTimerWithTimeInterval:5.2f
//                                         target:self 
//                                       selector:@selector(handshakeTimeout) 
//                                       userInfo:nil 
//                                        repeats:NO];
//
//    }
//
//}

// YES if handshake could be sent, NO for any other reason.
//- (BOOL)requestHandshakeForDeviceName:(NSString *)deviceName {
//    
//    NSLog(@"MocoDriver - Attempting to open port with with %@", deviceName);
//
//    if (![self initPortWithDeviceName:deviceName])
//        return NO;
//    else {
//        // Allow port to open and then send info.
//        [NSTimer scheduledTimerWithTimeInterval:5.0f
//                                         target:self 
//                                       selector:@selector(handshakeRequestCallback) 
//                                       userInfo:nil 
//                                        repeats:NO];
//        return YES;
//    }
//    
//    
//    return NO;
//}

//- (void)receiveHandshakeConfirmation {
//    _rigPortPath = [_portPaths objectAtIndex:_currentPortPathIndex];
//    self.status = MocoStatusIdle;
//}
//
//- (void)handshakeTimeout {
//    if (!_rigPortPath) {
//        
//        NSLog(@"MocoDriver - Handshake timed out. Trying another port...");
//
//        // Close the port.
//        [port close];
//        self.port = nil;
//        
//        // Advance to the next option.
//        _currentPortPathIndex++;
//        [self testNextPort];
//        
//    }
//}

# pragma mark Status

-(void)setStatus:(MocoStatusCode)newStatus {
    _status = newStatus;
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MocoDriverStatusDidChange" object:[NSNumber numberWithInt:self.status]];
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
        return @"Assuming control...";
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

@end
