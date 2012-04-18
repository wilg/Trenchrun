//
//  MocoDriverResponse.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MocoDriverResponseTypeUnknown      = -1,
    MocoDriverResponseTypeHandshake    = 0,
    MocoDriverResponseTypeAxisPosition = 1
} MocoDriverResponseType;

@interface MocoDriverResponse : NSObject

@property (readonly) NSData *data;
@property (assign) MocoDriverResponseType type;
@property (readonly) NSDictionary *parsedResponse;

+(MocoDriverResponse *)responseWithData:(NSData *)data;

-(BOOL)understood;
-(NSString *)byteDescription;
-(Byte *)byteData;

@end
