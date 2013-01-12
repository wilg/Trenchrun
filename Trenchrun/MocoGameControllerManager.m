//
//  MocoGameControllerManager.m
//  Trenchrun
//
//  Created by Wil Gieseler on 1/11/13.
//
//

#import "MocoGameControllerManager.h"

@implementation MocoGameControllerManager

-(id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllersUpdated) name:XBOX360CONTROLLERS_UPDATED object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    Xbox360ControllerManager *mrManager = [Xbox360ControllerManager sharedInstance];
    [mrManager updateControllers];
}

- (void)controllersUpdated {
    
    int controllers = [Xbox360ControllerManager sharedInstance].controllerCount;
    if (controllers > 0) {
        
        NSLog(@"There are %i Xbox Controllers available.", controllers);
        if (_pollingThreadRunning) {
            NSLog(@"We already have a thread watching Xbox controllers.");
        }
        else {
            NSLog(@"Starting polling thread...");
            _pollingThreadRunning = YES;
            NSThread *pollingThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(pollingThreadMain:)
                                                       object:nil];
            [pollingThread start];
        }

    }
    else {
        NSLog(@"No Xbox Controllers available.");
        if (_pollingThreadRunning) {
            NSLog(@"Requesting termination of polling thread");
            _pollingThreadRunning = NO;
        }
    }
}

- (void)checkControllers {
    Xbox360ControllerManager *mrManager = [Xbox360ControllerManager sharedInstance];
    Xbox360Controller *firstController = [mrManager getController:0];
    if (firstController) {
        NSLog(@"Controller 1: left stick = %i, %i", firstController.leftStickX, firstController.leftStickY);
        usleep(10000);
    }
    else {
        NSLog(@"no first controller");
    }
}

- (void)pollingThreadMain:(NSThread *)parentThread {
    @autoreleasepool {
        NSLog(@"... polling thread started.");
        while (_pollingThreadRunning ){
            [self checkControllers];
        }
        NSLog(@"Polling thread exited.");
    }
}

//
//-(void)buttonAPressed {
//    NSLog(@"A!!!!!");
//}


@end
