//
//  setCloudDataPointPacket.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "SetCloudDataPointPacket.h"

@implementation SetCloudDataPointPacket

-(instancetype)initWithSessionID:(uint32_t)deviceID withMessageID:(uint16_t)msgID withFlag:(uint8_t)flag{
    if (self = [super init]) {
        _deviceID = deviceID;
        _msgID = msgID;
        _flag = flag;
    }
    return self;
}

-(NSData *)getPacketData{
    
    uint32_t deviceID = htonl(_deviceID);
    uint16_t msgID = htons(_msgID);
    
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&deviceID length:4];
    [data appendBytes:&msgID length:2];
    [data appendBytes:&_flag length:1];
    
    return [NSData dataWithData:data];
}

@end
