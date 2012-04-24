//
//  MocoDriverResponse.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/16/12.
//  Copyright (c) 2012 Wil Gieseler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MocoDriverResponse : NSObject

@property (readonly) NSData *data;
@property (assign) MocoProtocolResponseType type;
@property (readonly) NSDictionary *payload;
@property (readonly) NSString *typeDescription;

+(MocoDriverResponse *)responseWithData:(NSData *)data;

-(Byte *)byteData;

@end
