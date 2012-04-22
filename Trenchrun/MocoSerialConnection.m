//
//  SerialExample.m
//  Arduino Serial Example
//
//  Created by Gabe Ghearing on 6/30/09.
//

#import "MocoSerialConnection.h"
#import "MocoProtocolConstants.h"

@implementation MocoSerialConnection

@synthesize delegate;

-(id)init {
	self = [super init];
	if (self) {
	
        serialFileDescriptor = -1;
        readThreadRunning = FALSE;
        killThread = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(killThread) 
                                                     name:@"MocoSerialConnectionShouldKillPortNotification" 
                                                   object:nil];

    
    }
	return self;
}

-(void)closePort {
    if (serialFileDescriptor != -1) {
        close(serialFileDescriptor);
        serialFileDescriptor = -1;
        NSLog(@"allegedly closed");
    }
    else {
        NSLog(@"didn't close");
    }
}

-(void)openThreadedConnectionWithSerialPort:(NSString *)port baud:(int)baud {
	NSString *error = [self openSerialPort:port baud:baud];
        
	if (error!=nil) {
        [self.delegate openSerialConnectionFailedWithMessage:error];
	} else {
		[self performSelectorInBackground:@selector(serialPortUpdateThread:) withObject:[NSThread currentThread]];
        [self.delegate openSerialConnectionSuccessful];
	}

}

// open the serial port
//   - nil is returned on success
//   - an error message is returned otherwise
- (NSString *) openSerialPort: (NSString *)serialPortFile baud: (speed_t)baudRate {
	int success;
	
	// close the port if it is already open
	if (serialFileDescriptor != -1) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
		
		// wait for the reading thread to die
		while(readThreadRunning);
		
		// re-opening the same port REALLY fast will fail spectacularly... better to sleep a sec
		sleep(0.5);
	}
    
    NSLog(@"open serial port yaya");
	
	// c-string path to serial-port file
	const char *bsdPath = [serialPortFile cStringUsingEncoding:NSUTF8StringEncoding];
	
	// Hold the original termios attributes we are setting
	struct termios options;
	
	// receive latency ( in microseconds )
	unsigned long mics = 3;
	
	// error message string
	NSString *errorMessage = nil;
	
	// open the port
	//     O_NONBLOCK causes the port to open without any delay (we'll block with another call)
	serialFileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK );
	
	if (serialFileDescriptor == -1) { 
		// check if the port opened correctly
		errorMessage = @"Error: couldn't open serial port";
	} else {
		// TIOCEXCL causes blocking of non-root processes on this serial-port
		success = ioctl(serialFileDescriptor, TIOCEXCL);
		if ( success == -1) { 
			errorMessage = @"Error: couldn't obtain lock on serial port";
		} else {
			success = fcntl(serialFileDescriptor, F_SETFL, 0);
			if ( success == -1) { 
				// clear the O_NONBLOCK flag; all calls from here on out are blocking for non-root processes
				errorMessage = @"Error: couldn't obtain lock on serial port";
			} else {
				// Get the current options and save them so we can restore the default settings later.
				success = tcgetattr(serialFileDescriptor, &gOriginalTTYAttrs);
				if ( success == -1) { 
					errorMessage = @"Error: couldn't get serial attributes";
				} else {
					// copy the old termios settings into the current
					//   you want to do this so that you get all the control characters assigned
					options = gOriginalTTYAttrs;
					
					/*
					 cfmakeraw(&options) is equivilent to:
					 options->c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
					 options->c_oflag &= ~OPOST;
					 options->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
					 options->c_cflag &= ~(CSIZE | PARENB);
					 options->c_cflag |= CS8;
					 */
					cfmakeraw(&options);
					
					// set tty attributes (raw-mode in this case)
					success = tcsetattr(serialFileDescriptor, TCSANOW, &options);
					if ( success == -1) {
						errorMessage = @"Error: coudln't set serial attributes";
					} else {
						// Set baud rate (any arbitrary baud rate can be set this way)
						success = ioctl(serialFileDescriptor, IOSSIOSPEED, &baudRate);
						if ( success == -1) { 
							errorMessage = @"Error: Baud Rate out of bounds";
						} else {
							// Set the receive latency (a.k.a. don't wait to buffer data)
							success = ioctl(serialFileDescriptor, IOSSDATALAT, &mics);
							if ( success == -1) { 
								errorMessage = @"Error: coudln't set serial latency";
							}
						}
					}
				}
			}
		}
	}
	
	// make sure the port is closed if a problem happens
	if ((serialFileDescriptor != -1) && (errorMessage != nil)) {
		close(serialFileDescriptor);
		serialFileDescriptor = -1;
	}
	
	return errorMessage;
}

// This selector/function will be called as another thread...
//  this thread will read from the serial port and exits when the port is closed
- (void)serialPortUpdateThread: (NSThread *) parentThread {
	
    @autoreleasepool {
        
	
        // mark that the thread is running
        readThreadRunning = TRUE;
        
        const int SYSTEM_BUFFER_SIZE = 1;
        char byte_buffer[SYSTEM_BUFFER_SIZE]; // buffer for holding incoming data
        int numBytes=0; // number of bytes read during read
                
        NSMutableData *dataBuffer = [NSMutableData data]; // Cocoa buffer for holding data until the packet size is reached.
        
        // assign a high priority to this thread
        [NSThread setThreadPriority:1.0];
        
        // this will loop unitl the serial port closes
        while(killThread == 0) {
            
            if (serialFileDescriptor == -1) {
                break;
            }
            
            while ([dataBuffer length] < MocoProtocolResponsePacketLength) {
                // read() blocks until some data is available or the port is closed
                numBytes = read(serialFileDescriptor, byte_buffer, SYSTEM_BUFFER_SIZE); // read up to the size of the buffer
                if (numBytes > 0){
                    [dataBuffer appendBytes:byte_buffer length:numBytes];
                }
                else {
                    break;
                }
            }
            
            // DATA BUFFER SHOULD BE FULL NOW
            
            [self performSelectorOnMainThread: @selector(serialMessageReceived:) 
                                   withObject: [dataBuffer copy] 
                                waitUntilDone: NO];

            // Empty data buffer.
            [dataBuffer setData:[NSData data]];


        }
        
        NSLog(@"Killing thread.");
        
        // make sure the serial port is closed
//        if (serialFileDescriptor != -1) {
//            close(serialFileDescriptor);
//            serialFileDescriptor = -1;
//        }
        
        // mark that the thread has quit
        readThreadRunning = FALSE;
        
    }
}

// Callback for serial message recieved that forwards the message to the delegate.
- (void)serialMessageReceived:(NSData *)data {
    [self.delegate performSelector:@selector(serialMessageReceived:) withObject:data];
}

//- (void) refreshSerialList: (NSString *) selectedText {
//	io_object_t serialPort;
//	io_iterator_t serialPortIterator;
//	
//	// remove everything from the pull down list
////	[serialListPullDown removeAllItems];
//	
//	// ask for all the serial ports
//	IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(kIOSerialBSDServiceValue), &serialPortIterator);
//	
//	// loop through all the serial ports and add them to the array
//	while ((serialPort = IOIteratorNext(serialPortIterator))) {
////		[serialListPullDown addItemWithTitle:
////			(__bridge NSString*)IORegistryEntryCreateCFProperty(serialPort, CFSTR(kIOCalloutDeviceKey),  kCFAllocatorDefault, 0)];
//		IOObjectRelease(serialPort);
//	}
//	
//	// add the selected text to the top
////	[serialListPullDown insertItemWithTitle:selectedText atIndex:0];
////	[serialListPullDown selectItemAtIndex:0];
//	
//	IOObjectRelease(serialPortIterator);
//}

// send a string to the serial port
- (void) writeString: (NSString *) str {
	if(serialFileDescriptor!=-1) {
		write(serialFileDescriptor, [str cStringUsingEncoding:NSUTF8StringEncoding], [str length]);
	} else {
		// make sure the user knows they should select a serial port
//		[self appendToIncomingText:@"\n ERROR:  Select a Serial Port from the pull-down menu\n"];
	}
}

// send a byte to the serial port
- (void) writeByte: (uint8_t *) val {
	if(serialFileDescriptor!=-1) {
		write(serialFileDescriptor, val, 1);
	} else {
        NSLog(@"can't write byte");
		// make sure the user knows they should select a serial port
//		[self appendToIncomingText:@"\n ERROR:  Select a Serial Port from the pull-down menu\n"];
	}
}

- (void) writeIntAsByte: (int) val {
    uint8_t y = val;
    
    uint8_t *x = &y;
    [self writeByte:x];
}
@end
