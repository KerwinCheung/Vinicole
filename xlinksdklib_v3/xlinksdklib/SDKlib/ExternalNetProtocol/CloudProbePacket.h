//
//  CloudProbePacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudProbePacket : NSObject

@property (assign, nonatomic) int32_t   deviceID;
@property (assign, nonatomic) uint16_t  msgID;
@property (assign, nonatomic) int8_t    flag;

-(id)initWithDeviceID:(int)deviceID andMessageID:(int)messageID andFlag:(int)flag;

-(NSMutableData *)getPacketData;

@end
