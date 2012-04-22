//
//  MocoDriverResponse.h
//  Trenchrun
//
//  Created by Wil Gieseler on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MocoDriverResponse : NSObject

@property (readonly) NSData *data;
@property (assign) MocoProtocolResponseType type;
@property (readonly) NSDictionary *parsedResponse;

+(MocoDriverResponse *)responseWithData:(NSData *)data;

-(BOOL)understood;
-(NSString *)byteDescription;
-(Byte *)byteData;

@end
