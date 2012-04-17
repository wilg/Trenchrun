//
//  ViewController.m
//  ArduinoSerial
//
//  Created by Pat O'Keefe on 4/30/09.
//  Copyright 2009 POP - Pat OKeefe Productions. All rights reserved.
//
//	Portions of this code were derived from Andreas Mayer's work on AMSerialPort. 
//	AMSerialPort was absolutely necessary for the success of this project, and for
//	this, I thank Andreas. This is just a glorified adaptation to present an interface
//	for the ambitious programmer and work well with Arduino serial messages.
//  
//	AMSerialPort is Copyright 2006 Andreas Mayer.
//



#import "SerialConnectionViewController.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"


@implementation SerialConnectionViewController

//@synthesize serialSelectMenu;
//@synthesize textField;

- (void)awakeFromNib
{
	
	[sendButton setEnabled:NO];
	[textField setEnabled:NO];
	
	/// set up notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
	
	/// initialize port list to arm notifications
	[AMSerialPortList sharedPortList];
	[self listDevices];
	
}

- (IBAction)attemptConnect:(id)sender {
	
	[serialScreenMessage setStringValue:@"Attempting to Connect..."];
	[self initPort];
	
}

	
# pragma mark Serial Port Stuff
	
	- (void)initPort
	{
		NSString *deviceName = [serialSelectMenu titleOfSelectedItem];
		if (![deviceName isEqualToString:[port bsdPath]]) {
			[port close];
			
			[self setPort:[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)]];
			[port setDelegate:self];
			
			if ([port open]) {
				
				//Then I suppose we connected!
				NSLog(@"successfully connected");

				[connectButton setEnabled:NO];
				[serialSelectMenu setEnabled:NO];
				[sendButton setEnabled:YES];
				[textField setEnabled:YES];
				[serialScreenMessage setStringValue:@"Connection Successful!"];

				//TODO: Set appropriate baud rate here. 
				
				//The standard speeds defined in termios.h are listed near
				//the top of AMSerialPort.h. Those can be preceeded with a 'B' as below. However, I've had success
				//with non standard rates (such as the one for the MIDI protocol). Just omit the 'B' for those.
			
				[port setSpeed:1000000]; 
				

				// listen for data in a separate thread
				[port readDataInBackground];
				
				
			} else { // an error occured while creating port
				
				NSLog(@"error connecting");
				[serialScreenMessage setStringValue:@"Error Trying to Connect..."];
				[self setPort:nil];
				
			}
		}
	}
	
	
	
	
	- (void)serialPortReadData:(NSDictionary *)dataDictionary
	{
		
		AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
		NSData *data = [dataDictionary objectForKey:@"data"];
		
		if ([data length] > 0) {
			
			NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"Serial Port Data Received: %@",receivedText);
			
			
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
	
	- (void)listDevices
	{
		// get an port enumerator
		NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
		AMSerialPort *aPort;
		[serialSelectMenu removeAllItems];
		
		while (aPort = [enumerator nextObject]) {
			[serialSelectMenu addItemWithTitle:[aPort bsdPath]];
		}
	}
	
	- (IBAction)send:(id)sender
	{
		NSString *sendString = [[textField stringValue] stringByAppendingString:@"\r"];
		
		 if(!port) {
		 [self initPort];
		 }
		 
		 if([port isOpen]) {
		 [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
		 }
	}
	
	- (AMSerialPort *)port
	{
		return port;
	}
	
	- (void)setPort:(AMSerialPort *)newPort
	{		
		if (newPort != port) {
			port = newPort ;
		}
	}
	
	
# pragma mark Notifications
	
	- (void)didAddPorts:(NSNotification *)theNotification
	{
		NSLog(@"A port was added");
		[self listDevices];
	}
	
	- (void)didRemovePorts:(NSNotification *)theNotification
	{
		NSLog(@"A port was removed");
		[self listDevices];
	}
	




@end
