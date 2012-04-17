//
//  MocoDriver.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OldMocoDriver.h"
#import "readline.h"

@implementation OldMocoDriver

- (id)init {
    if (self = [super init]){
        [NSThread detachNewThreadSelector:@selector(mocoDriverThreadMain:) toTarget:self withObject:nil];
	}
	return self;
}

- (void)mocoDriverThreadMain:(id)object{
    @autoreleasepool {
        
        NSLog(@"Moco Driver - Thread Booted");
        
        int fd;
        char buffer[256];
        
        fd = USBSerialInit();
        
        NSArray *lastTime;
        
        while (1) {
            USBSerialGetLine(fd, buffer, sizeof buffer);
            NSString *reading = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
            NSArray *args = [reading componentsSeparatedByString:@" "];
            
            //            NSLog(@"ARGS: %@", args);
            
            if (![lastTime isEqualTo:args]) {
                lastTime = args;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MocoDriverDidRecieveInput" object:args];
            }
        }
        
        
    }
}


@end
