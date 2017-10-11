//
//  SetLocalDataPointPacket.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "SetLocalDataPointPacket.h"

@implementation SetLocalDataPointPacket

-(instancetype)initWithSessionID:(uint16_t)sessionID withMessageID:(uint16_t)msgID withFlag:(uint8_t)flag{
    if (self = [super init]) {
        _sessionID = sessionID;
        _msgID = msgID;
        _flag = flag;
    }
    return self;
}

-(NSData *)getPacketData{
    uint16_t sessionID = htons(_sessionID);
    uint16_t msgID = htons(msgID);
    
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&sessionID length:2];
    [data appendBytes:&msgID length:2];
    [data appendBytes:&_flag length:1];
    
    return [NSData dataWithData:data];
}

@end
