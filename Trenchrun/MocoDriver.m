//
//  MocoDriver.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoDriver.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"
#import "MocoDriverResponse.h"



@interface MocoDriver ( /* class extension */ ) {
@private
	AMSerialPort *port;
    
    MocoStatusCode _status;
    
    NSMutableArray *_portPaths;
    int _currentPortPathIndex;
    BOOL _waitingForPortHandshakeResponse;
    NSString *_rigPortPath;
    
    
    MocoSerialConnection *_serialConnection;
}
@property (retain) AMSerialPort *port;
@property (assign) MocoStatusCode status;

- (void)findMocoRig;
- (void)testNextPort;
@end

///// IMPLEMENTATION

@implementation MocoDriver
@synthesize port;

# pragma mark Initializer

-(id)init {
	self = [super init];
	if (self) {

        // Register for port list updated notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didAddPorts:)
                                                     name:AMSerialPortListDidAddPortsNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRemovePorts:) 
                                                     name:AMSerialPortListDidRemovePortsNotification 
                                                   object:nil];
        
        /// initialize port list to arm notifications
        [AMSerialPortList sharedPortList];
        
        self.status = MocoStatusDisconnected;
        
        // Search all available ports for moco rig.
//        [self findMocoRig];
        
        _serialConnection = [[MocoSerialConnection alloc] init];
        _serialConnection.delegate = self;
        
        NSLog(@"intializing one port");
        
        [_serialConnection openThreadedConnectionWithSerialPort:@"/dev/cu.usbserial-A800H22L" baud:kMocoBaudRate];
        self.status = MocoStatusIdle;
        
        
        [NSTimer scheduledTimerWithTimeInterval:1.5f
                                         target:self 
                                       selector:@selector(beginStreaming) 
                                       userInfo:nil 
                                        repeats:NO];
        

        
        
	}
	return self;
}

- (void)beginStreaming {
    NSLog(@"begin stream");
    [_serialConnection writeIntAsByte:kMocoBeginSendingAxisDataInstruction];
}


- (void)serialMessageReceived:(NSData *)data {
    MocoDriverResponse *driverResponse = [MocoDriverResponse responseWithData:data];
    NSLog(@"serialMessageReceived: %@", driverResponse);
}

- (void)severConnections {
    NSLog(@"MocoDriver - Closing ports.");
    [port close];
}

# pragma mark Auto-discovery
- (void)findMocoRig {
    
    // Switch into search mode
    self.status = MocoStatusSearchingForDevice;
    
    
    // Add all the ports to an array.
    _portPaths = [NSMutableArray array];

    NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
    AMSerialPort *aPort;
    [_portPaths removeAllObjects];
    
    while (aPort = [enumerator nextObject]) {
        [_portPaths addObject:[aPort bsdPath]];
    }
    
    // Now we're going to try to connect to each one.
    _currentPortPathIndex = 0;
    
    [self testNextPort];
}

- (void)testNextPort {
    
    if (_rigPortPath) {
        return;
    }
    
    if (_currentPortPathIndex >= _portPaths.count) {
        NSLog(@"MocoDriver - Out of options. There's no rig connected.");
        self.status = MocoStatusDisconnected;
        return;
    }
    
    if ([self requestHandshakeForDeviceName:[_portPaths objectAtIndex:_currentPortPathIndex]]){
        // this will set a timer
    }
    else {
        // Couldn't send a handshake request.
        // Try the next one.
        
        NSLog(@"MocoDriver - Couldn't establish connection. Trying another port...");

        _currentPortPathIndex++;
        [self testNextPort];
    }
}

- (void)handshakeRequestCallback {
    
    if([port isOpen]) {
        
//        [port writeData:[NSData dataWithBytes:&kMocoHandshakeRequest length:sizeof(kMocoHandshakeRequest)] error:NULL];
        NSLog(@"MocoDriver - Connected and requested handshake with %@", [_portPaths objectAtIndex:_currentPortPathIndex]);
        
        // If we could send a handshake request to this device.
        // We'll set a 200ms timeout to allow the device to respond.
        // If it does, we'll stop searching and save that device.
        // If not, we'll keep searching.
        [NSTimer scheduledTimerWithTimeInterval:5.2f
                                         target:self 
                                       selector:@selector(handshakeTimeout) 
                                       userInfo:nil 
                                        repeats:NO];

    }

}

// YES if handshake could be sent, NO for any other reason.
- (BOOL)requestHandshakeForDeviceName:(NSString *)deviceName {
    
    NSLog(@"MocoDriver - Attempting to open port with with %@", deviceName);

    if (![self initPortWithDeviceName:deviceName])
        return NO;
    else {
        // Allow port to open and then send info.
        [NSTimer scheduledTimerWithTimeInterval:5.0f
                                         target:self 
                                       selector:@selector(handshakeRequestCallback) 
                                       userInfo:nil 
                                        repeats:NO];
        return YES;
    }
    
    
    return NO;
}

- (void)receiveHandshakeConfirmation {
    _rigPortPath = [_portPaths objectAtIndex:_currentPortPathIndex];
    self.status = MocoStatusIdle;
}

- (void)handshakeTimeout {
    if (!_rigPortPath) {
        
        NSLog(@"MocoDriver - Handshake timed out. Trying another port...");

        // Close the port.
        [port close];
        self.port = nil;
        
        // Advance to the next option.
        _currentPortPathIndex++;
        [self testNextPort];
        
    }
}


- (void)didAddPorts:(NSNotification *)theNotification {
    NSLog(@"MocoDriver - A port was added. Let's check to see if it was a rig!");
    
    // Search for rigs unless we already have found one.
    if (!_rigPortPath)
        [self findMocoRig];
}

- (void)didRemovePorts:(NSNotification *)theNotification {
    NSLog(@"didRemovePorts: %@", theNotification);
}

# pragma mark Serial Port Stuff

// Returns YES if could connect to device.
- (BOOL)initPortWithDeviceName:(NSString *)deviceName {
    if (![deviceName isEqualToString:[port bsdPath]]) {
        [port close];
        
        self.port = [[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDAllTypes)];
        [port setDelegate:self];
        
        if ([port open]) {
            
            //Then I suppose we connected!
            NSLog(@"MocoDriver - Connected to device %@", deviceName);
            
            
            //TODO: Set appropriate baud rate here. 
            
            //The standard speeds defined in termios.h are listed near
            //the top of AMSerialPort.h. Those can be preceeded with a 'B' as below. However, I've had success
            //with non standard rates (such as the one for the MIDI protocol). Just omit the 'B' for those.
			
            [port setSpeed:kMocoBaudRate]; 
//            [port setSpeed:B38400]; 

            
            // listen for data in a separate thread
            [port readDataInBackground];
            
            return YES;
            
        } else { // an error occured while creating port
            
            NSLog(@"MocoDriver - Error connecting to device %@", deviceName);
            self.port = nil;
            
        }
    }
    return NO;
}

- (BOOL)initMocoPort {
    if (!_rigPortPath) {
        NSLog(@"Haven't yet found the Moco rig port.");
        return NO;
    }
    return [self initPortWithDeviceName:_rigPortPath];
}


- (void)serialPortReadData:(NSDictionary *)dataDictionary
{
    
    AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
    NSData *data = [dataDictionary objectForKey:@"data"];
    
    NSLog(@"serialPortReadData:");
    
//    NSLog(@"NSData: %@", data);

    if ([data length] > 0) {
        
        
        MocoDriverResponse *response = [MocoDriverResponse responseWithData:data];
        
        if ([response understood]) {
            NSLog(@"%@", response);
        }
        else {
            // Try to get it as a string?
            // Don't think this will work now maybe.
            
            NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSString *whitespacelessText = [receivedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSLog(@"Serial Port Data Received: %@", receivedText);
            
            if ([whitespacelessText isEqualToString:@"fa"]) {
                [self receiveHandshakeConfirmation];
            }

        }
        

        
        //////
        
        // Let's try it as data.
        
//        NSLog(@"NSData: %@", data);
        
        // if it's a recognized first byte
//        NSUInteger len = [data length];
//        Byte *byteData = (Byte*)malloc(len);
//        memcpy(byteData, [data bytes], len);
//        
//        int i = 0;
//        while (i < sizeof(byteData))
//        {
//            NSLog(@"%02X",(int)byteData[i]);
//            i++;
//        }
//        
//        
//        unsigned long int anotherLongInt;
//        anotherLongInt = ( (byteData[1] << 24) 
//                          + (byteData[2] << 16) 
//                          + (byteData[3] << 8) 
//                          + (byteData[4] ) );
//        NSLog(@"long: %lu", anotherLongInt);

        

        
        // otherwise interperet as text.
        
        
        
        
        
        
        //TODO: Do something meaningful with the data...
        
        //Typically, I arrange my serial messages coming from the Arduino in chunks, with the
        //data being separated by a comma or semicolon. If you're doing something similar, a 
        //variant of the following command is invaluable. 
        
        //NSArray *dataArray = [receivedText componentsSeparatedByString:@","];
        
        
        // continue listening
        [sendPort readDataInBackground];
        
    } else { 
        // port closed
        NSLog(@"Port was closed on a readData operation...not good!");
    }
    
}


//- (IBAction)send:(id)sender
//{
//    
//    NSString *sendString = [[textField stringValue] stringByAppendingString:@"\r"];
//    
//    if(!port) {
//        [self initPort];
//    }
//    
//    if([port isOpen]) {
//        [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
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
