//
//  MocoDriverResponse.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MocoProtocolConstants.h"
#import "MocoDriverResponse.h"

@interface MocoDriverResponse ( /* class extension */ ) {
@private
}

@end

// IMPLEMENTATION

@implementation MocoDriverResponse
@synthesize data = _data;
@synthesize type = _type;
@synthesize parsedResponse = _parsedResponse;

-(id)init {
	self = [super init];
	if (self) {
        self.type = MocoProtocolUnknownResponseType;
	}
	return self;
}

-(id)initWithData:(NSData *)data {
	self = [self init];
	if (self) {
        _data = data;
        [self processData];
	}
	return self;
}

+(MocoDriverResponse *)responseWithData:(NSData *)data {
    return [[MocoDriverResponse alloc] initWithData:data];
}

+(unsigned long int)longIntFromFourBytes:(Byte *)fourBytes {
    return     ( (fourBytes[0] << 24) 
                + (fourBytes[1] << 16) 
                + (fourBytes[2] << 8) 
                + (fourBytes[3] ) );
}


-(BOOL)processData {
    
    Byte *bytes = [self byteData];
    
    // Process first byte.
    // This should directly correspond with the enum values for MocoDriverResponseType.
    self.type = (int)bytes[0];
        
    if (self.type == MocoProtocolHandshakeResponseType) {
        BOOL handshakeSuccessful = NO;
        if ((int)bytes[1] == (int)MocoProtocolHandshakeSuccessfulResponse) {
            handshakeSuccessful = YES;
        }
        _parsedResponse = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:handshakeSuccessful], @"successful", nil];

    }
    else if (self.type = MocoProtocolAxisPositionResponseType) {
        MocoAxis axis = (int)bytes[1];
        
        Byte fourbytes[4];
        fourbytes[0] = bytes[2];
        fourbytes[1] = bytes[3];
        fourbytes[2] = bytes[4];
        fourbytes[3] = bytes[5];
        
        unsigned long int positionValue = [MocoDriverResponse longIntFromFourBytes:fourbytes];
        
        _parsedResponse = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithLong:positionValue], @"position", [NSNumber numberWithInt:axis], @"axis", nil];
        
    }
    
    return YES;
}

-(BOOL)understood {
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"MocoDriverResponse type=%i data=%@ parsed=%@", self.type, self.data, self.parsedResponse];
}

-(Byte *)byteData {
    NSUInteger len = _data.length;
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [_data bytes], len);
    return byteData;
}


//-(NSArray *)byteArray {
//    
////    NSMutableArray * targetArray = [[NSMutableArray alloc] initWithCapacity: SIZE];
////    
////    int i;
////    NSNumber *number;
////    for (i = 0; i < SIZE; i++)
////    {
////        number = [NSNumber numberWithDouble: sourceArray[i]];
////        [targetArray addObject: number];
////    }
//
//}

//-(NSString *)byteDescription {
//    
//    
//    
////    Byte byte_array[] = self.data.bytes;
////    NSString *description = @"";
////    int i = 0;
////    while (i < sizeof(bytes)) {
////        description = [NSString stringWithFormat:@"%@, %02X", description, (int)bytes[i]];
////        i++;
////    }
//    
//    unsigned char *bytePtr = (unsigned char *)self.data.bytes;
//    
//    
//    return [description stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
//}


//
//NSUInteger len = [data length];
//Byte *byteData = (Byte*)malloc(len);
//memcpy(byteData, [data bytes], len);
//
//int i = 0;
//while (i < sizeof(byteData))
//{
//    NSLog(@"%02X",(int)byteData[i]);
//    i++;
//}
//
//
//unsigned long int anotherLongInt;
//anotherLongInt = ( (byteData[1] << 24) 
//                  + (byteData[2] << 16) 
//                  + (byteData[3] << 8) 
//                  + (byteData[4] ) );
//NSLog(@"long: %lu", anotherLongInt);


@end
