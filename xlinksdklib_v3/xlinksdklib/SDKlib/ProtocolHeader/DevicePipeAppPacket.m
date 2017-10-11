//
//  DevicePipeAppPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/28.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "DevicePipeAppPacket.h"

#define PACKETSIZE 9

@implementation DevicePipeAppPacket

-(instancetype)initWithData:(NSData *)data withVersion:(uint8_t)version{
    self = [super init];
    if (self) {
        if (version < 3) { //修复v3版本以下的mac长度
            uint16_t len = htons(6);
            NSMutableData *temp = [NSMutableData dataWithBytes:&len length:2];
            [temp appendData:data];
            data = [NSData dataWithData:temp];
        }
        
        uint8_t offset = 0;
        
        uint16_t len = 0;
        [data getBytes:&len range:NSMakeRange(offset, 2)];
        len = htons(len);
        offset += 2;
        
        _mac = [data subdataWithRange:NSMakeRange(2, len)];
        offset += len;
        
        [data getBytes:&_msgID range:NSMakeRange(offset, 2)];
        _msgID = htons(_msgID);
        offset += 2;
        
        [data getBytes:&_flag range:NSMakeRange(offset, 1)];
        offset += 1;
        
        _payload = [data subdataWithRange:NSMakeRange(offset, data.length - offset)];
        
    }
    return self;
}

@end
