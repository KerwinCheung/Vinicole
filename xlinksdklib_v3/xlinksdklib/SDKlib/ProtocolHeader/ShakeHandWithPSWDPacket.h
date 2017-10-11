//
//  ShakeHandWithPSWDPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShakeHandWithPSWDPacket : NSObject

@property (assign, nonatomic) int8_t    version;
@property (assign, nonatomic) int16_t   messageID;
@property (strong, nonatomic) NSData    *accessKeyMD5;
@property (assign, nonatomic) uint8_t   port;
@property (assign, nonatomic) int8_t    flag;
@property (assign, nonatomic) uint16_t  keepAliveTime;

-(id)initWithVersion:(int)version andMessageID:(int16_t)messageID andAuthKey:(NSData *)auth andListenPort:(int)port andFlag:(int)flag andKeepAlive:(int)aliveTime;

-(int)getPacketSize;

-(NSMutableData *)getPacketData;

@end
