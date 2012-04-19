//
//  SerialExample.h
//  Arduino Serial Example
//
//  Created by Gabe Ghearing on 6/30/09.
//

#import <Cocoa/Cocoa.h>

// import IOKit headers
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/serial/ioss.h>
#include <sys/ioctl.h>

@protocol MocoSerialConnectionDelegate <NSObject>
@required;
- (void)serialMessageReceived:(NSData *)data;
@end

@interface MocoSerialConnection : NSObject {
    int serialFileDescriptor; // file handle to the serial port
	struct termios gOriginalTTYAttrs; // Hold the original termios attributes so we can reset them on quit ( best practice )
	bool readThreadRunning;
    bool killThread;
//	NSTextStorage *storage;
}

@property (assign) id<MocoSerialConnectionDelegate> delegate;

-(void)openThreadedConnectionWithSerialPort:(NSString *)port baud:(int)baud;
-(void)closePort;

- (void) writeString: (NSString *) str;
- (void) writeByte: (uint8_t *) val;
- (void) writeIntAsByte: (int) val;

@end
