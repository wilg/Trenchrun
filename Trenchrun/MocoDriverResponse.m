//
//  MocoDriverResponse.m
//  Trenchrun
//
//  Created by Wil Gieseler on 4/16/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import "MocoProtocolConstants.h"
#import "MocoDriverResponse.h"

@interface MocoDriverResponse ( /* class extension */ ) {
@private
    NSDictionary *_payload;
}

@end

// IMPLEMENTATION

@implementation MocoDriverResponse
@synthesize data = _data;
@synthesize type = _type;

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

+(long int)longIntFromFourBytes:(Byte *)fourBytes {
    return     ( (fourBytes[0] << 24) 
                + (fourBytes[1] << 16) 
                + (fourBytes[2] << 8) 
                + (fourBytes[3] ) );
}

-(NSDictionary *)payload {
    if (!_payload)
        [self processData];
    return _payload;
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
        _payload = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:handshakeSuccessful], @"successful", nil];

    }
    else if (self.type == MocoProtocolAxisPositionResponseType) {
        MocoAxis axis = (int)bytes[1];
        
        Byte fourbytes[4];
        fourbytes[0] = bytes[2];
        fourbytes[1] = bytes[3];
        fourbytes[2] = bytes[4];
        fourbytes[3] = bytes[5];
        
        long int positionValue = [MocoDriverResponse longIntFromFourBytes:fourbytes];
        
        _payload = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithLong:positionValue], @"rawPosition", [NSNumber numberWithInt:axis], @"axis", nil];
        
    }
    else if (self.type == MocoProtocolAxisResolutionResponseType) {
        MocoAxis axis = (int)bytes[1];
        
        Byte fourbytes[4];
        fourbytes[0] = bytes[2];
        fourbytes[1] = bytes[3];
        fourbytes[2] = bytes[4];
        fourbytes[3] = bytes[5];
        
        long int positionValue = [MocoDriverResponse longIntFromFourBytes:fourbytes];
        
        _payload = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithLong:positionValue], @"resolution", [NSNumber numberWithInt:axis], @"axis", nil];
        
    }
    else if (self.type == MocoProtocolAdvancePlaybackRequestType) {
        MocoAxis axis = (int)bytes[1];
        
        Byte fourbytes[4];
        fourbytes[0] = bytes[2];
        fourbytes[1] = bytes[3];
        fourbytes[2] = bytes[4];
        fourbytes[3] = bytes[5];
        
        long int positionValue = [MocoDriverResponse longIntFromFourBytes:fourbytes];
        
        _payload = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithLong:positionValue], @"rawPosition", [NSNumber numberWithInt:axis], @"axis", nil];
        
    }
    else if (self.type == MocoProtocolNewlineDelimitedDebugStringResponseType) {

        NSData *subdata = [self.data subdataWithRange:NSMakeRange(1, self.data.length - 1)];
        NSString *string = [[NSString alloc] initWithData:subdata encoding:NSASCIIStringEncoding];
        _payload = [NSDictionary dictionaryWithObjectsAndKeys:
                    [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"message", nil];
        
    }


    
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"MocoDriverResponse type=%@ (%i) data=%@ payload=%@", self.typeDescription, self.type, self.data, self.payload];
}

- (NSString *)typeDescription {
    if (self.type == MocoProtocolUnknownResponseType) {
        return @"No Type";
    }
    else if (self.type == MocoProtocolHandshakeResponseType) {
        return @"Handshake";
    }
    else if (self.type == MocoProtocolAxisPositionResponseType) {
        return @"Axis Position";
    }
    else if (self.type == MocoProtocolAxisResolutionResponseType) {
        return @"Axis Resolution";
    }
    else if (self.type == MocoProtocolAdvancePlaybackRequestType) {
        return @"Advance Playback";
    }
    else if (self.type == MocoProtocolNewlineDelimitedDebugStringResponseType) {
        return @"Debug String";
    }
    else if (self.type == MocoProtocolPlaybackStartingNotificationResponseType) {
        return @"Playback Starting Notification";
    }
    else if (self.type == MocoProtocolPlaybackCompleteNotificationResponseType) {
        return @"Playback Complete Notification";
    }
    return [NSString stringWithFormat:@"Undefined type: %i", self.type];
}

-(Byte *)byteData {
    NSUInteger len = _data.length;
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [_data bytes], len);
    return byteData;
}


@end
