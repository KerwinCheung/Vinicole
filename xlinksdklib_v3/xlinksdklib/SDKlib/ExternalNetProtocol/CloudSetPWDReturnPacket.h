//
//  CloudSetPWDReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudSetPWDReturnPacket : NSObject

//-(id)initWith:(NSData *)data;

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;

-(int)getAppID;

-(int)getMessageID;


-(int)getCode;


@end
