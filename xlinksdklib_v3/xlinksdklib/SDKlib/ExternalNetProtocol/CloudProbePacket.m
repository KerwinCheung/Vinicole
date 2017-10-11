//
//  CloudProbePacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "CloudProbePacket.h"

@implementation CloudProbePacket

-(id)initWithDeviceID:(int)deviceID andMessageID:(int)messageID andFlag:(int)flag{
    if (self = [super init]) {
        _deviceID = deviceID;
        _msgID = messageID;
        _flag = flag;
    }
    return self;
}

-(NSMutableData *)getPacketData{
    NSMutableData *data = [NSMutableData data];
    
    int32_t deviceID = htonl(_deviceID);
    [data appendBytes:&deviceID length:4];
    
    uint16_t msgID = htons(_msgID);
    [data appendBytes:&msgID length:2];
    
    [data appendBytes:&_flag length:1];
    
    return data;
}
@end
