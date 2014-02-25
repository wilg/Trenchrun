//
//  MocoGameControllerManager.m
//  Trenchrun
//
//  Created by Wil Gieseler on 1/11/13.
//
//

#import "MocoGameControllerManager.h"
#import "MocoDocument.h"

#define XBOX_JOYSTICK_RESOLUTION 32768

@implementation MocoGameControllerManager

-(id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllersUpdated) name:XBOX360CONTROLLERS_UPDATED object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    Xbox360ControllerManager *mrManager = [Xbox360ControllerManager sharedInstance];
    [mrManager setAllDelegates:self];
    [mrManager updateControllers];
}

- (void)controllersUpdated {
    
    NSUInteger controllers = [Xbox360ControllerManager sharedInstance].controllerCount;
    if (controllers > 0) {
        
        NSLog(@"There are %lu Xbox Controllers available.", (unsigned long)controllers);
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

#define DEADZONE 0.3

- (float)normalizeAndDeadZoneJoystickData:(int)rawData {
    float val = (float)rawData / XBOX_JOYSTICK_RESOLUTION;
    if (fabs(val) < DEADZONE) {
        return 0;
    }
    int dir = val / fabs(val);
    val = fabs(val) - DEADZONE;
    return (1 / (1 - DEADZONE)) * val * dir;
}

#define DELAY_S 0.1

- (void)checkControllers {
    
    MocoDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
    MocoAxisPosition *currentPosition = [doc trackWithAxis:MocoAxisCameraTilt].currentPosition;

    if (currentPosition) {
        Xbox360ControllerManager *mrManager = [Xbox360ControllerManager sharedInstance];
        Xbox360Controller *firstController = [mrManager getController:0];
        if (firstController) {
            float normalizedLeftStickX = [self normalizeAndDeadZoneJoystickData:firstController.leftStickX];
            float normalizedLeftStickY = [self normalizeAndDeadZoneJoystickData:firstController.leftStickY] * -1;
            

            if (fabs(normalizedLeftStickY) > 0) {
                
                NSLog(@"[Xbox Controller] Left Stick %f, %f", normalizedLeftStickX, normalizedLeftStickY);
                
                MocoAxisPosition *desiredPosition = [[MocoAxisPosition alloc] init];
                desiredPosition.resolution = currentPosition.resolution;
                desiredPosition.position = @(currentPosition.position.floatValue + DELAY_S * 0.33 * normalizedLeftStickY);
                
                NSLog(@"[Xbox Controller] Move from %@ to %@.", currentPosition.position, desiredPosition.position);
                
                [mocoDriver setPosition:desiredPosition forAxis:desiredPosition.axis];
            }
            
            usleep(DELAY_S * 1000000);
        }
        else {
            NSLog(@"no first controller");
        }
  
    }
    else {
//        NSLog(@"No device position for game controller.");
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


-(void)buttonAPressed {
    NSLog(@"A!!!!!");
}

-(void)buttonBackPressed {
    NSLog(@"BACK");  
}


@end
