//
//  ViewController.h
//  ArduinoSerial
//
//  Created by Pat O'Keefe on 4/30/09.
//  Copyright 2009 POP - Pat OKeefe Productions. All rights reserved.
//
//	Portions of this code were derived from Andreas Mayer's work on AMSerialPort. 
//	AMSerialPort was absolutely necessary for the success of this project, and for
//	this, I thanks Andreas. This is just a glorified adaptation to present an interface
//	for the ambitious programmer and work well with Arduino serial messages.
//  
//	AMSerialPort is Copyright 2006 Andreas Mayer.
//


#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"



@interface SerialConnectionViewController : NSObject {

	AMSerialPort *port;
	
	IBOutlet NSPopUpButton	*serialSelectMenu;
	IBOutlet NSTextField	*textField;
	IBOutlet NSButton		*connectButton, *sendButton;
	IBOutlet NSTextField	*serialScreenMessage;


}

// Interface Methods
- (IBAction)attemptConnect:(id)sender;
- (IBAction)send:(id)sender;

// Serial Port Methods
- (AMSerialPort *)port;
- (void)setPort:(AMSerialPort *)newPort;
- (void)listDevices;
- (void)initPort;


//@property (nonatomic, retain) IBOutlet NSPopUpButton *serialSelectMenu;
//@property (nonatomic, retain) IBOutlet NSTextField	 *textField;

@end