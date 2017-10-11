//
//  SetPSWDReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetPSWDReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

+(int)getPacketSize;

-(NSMutableData *)getPacketData;

-(int)getMessageID;

-(int)getCode;

@end
