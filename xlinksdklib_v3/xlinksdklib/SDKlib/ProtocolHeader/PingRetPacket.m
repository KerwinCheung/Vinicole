//
//  PingRetPacket.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/6/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "PingRetPacket.h"

@implementation PingRetPacket{
    UInt16  _macLen;
    NSData  *_macData;
}

-(id)initWithData:(NSData *)data withVersion:(uint8_t)version{
    if (self = [super init]) {
        if (version < 3) {
            NSMutableData *temp = [NSMutableData dataWithData:data];
            uint16_t macLen = htons(6);
            [temp replaceBytesInRange:NSMakeRange(0, 0) withBytes:&macLen length:2];
            data = [NSData dataWithData:temp];
        }
        [data getBytes:&_macLen range:NSMakeRange(0, 2)];
        _macLen = htons(_macLen);
        _macData = [data subdataWithRange:NSMakeRange(2, _macLen)];
    }
    return self;
}

-(NSInteger)getPacketSize{
    return 2 + _macLen;
}

-(NSData *)getMAC{
    return _macData;
}

@end
