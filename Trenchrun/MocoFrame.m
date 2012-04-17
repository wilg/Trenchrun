#import "MocoFrame.h"


@implementation MocoFrame


#pragma mark ======== properties =========

@synthesize frameNumber, position;


#pragma mark ======== init method =========

- init
{
	if (self = [super init])
    {

	}
	return self;	
}



#pragma mark ======== Archiving and unarchiving methods =========


- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeObject:self.frameNumber forKey:@"frameNumber"];
    [coder encodeObject:self.position forKey:@"position"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
    if (self = [super init])
	{
        self.frameNumber =       [coder decodeObjectForKey:@"frameNumber"];
        self.position =   [coder decodeObjectForKey:@"position"];
    }
    return self;
}


@end


