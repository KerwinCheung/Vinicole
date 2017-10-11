//
//  HandShakeRetPacket.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/6/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "HandShakeRetPacket.h"

@implementation HandShakeRetPacket

-(instancetype)initWithData:(NSData *)data{
    if (self = [super init]) {
        
        NSMutableData *handshakeData = [NSMutableData dataWithData:data];
        
        [handshakeData getBytes:&_result range:NSMakeRange(0, 1)];
        
        [handshakeData getBytes:&_version range:NSMakeRange(1, 1)];
        
        
        if (_version < 3) { //v1 v2版本缺少mac长度，伪造加上
            
            int16_t messageID = htons(-1);
            [handshakeData replaceBytesInRange:NSMakeRange(2, 0) withBytes:&messageID length:2];
            
            UInt16 len = htons(6);
            [handshakeData replaceBytesInRange:NSMakeRange(4, 0) withBytes:&len length:2];
        }
        
        [handshakeData getBytes:&_messageID range:NSMakeRange(2, 2)];
        
        [handshakeData getBytes:&_macLen range:NSMakeRange(4, 2)];
        _macLen = htons(_macLen);
        unsigned int scanOffset = 6;
        _macData = [handshakeData subdataWithRange:NSMakeRange(scanOffset, _macLen)];
        scanOffset+=_macLen;
        
        //握手成功才有后面的数据
        if (_result == 0) {
            [handshakeData getBytes:&_deviceID range:NSMakeRange(scanOffset, 4)];
            _deviceID = htonl(_deviceID);
            scanOffset+=4;
            
            [handshakeData getBytes:&_mcuSoftVersion range:NSMakeRange(scanOffset, 2)];
            _mcuSoftVersion = htons(_mcuSoftVersion);
            scanOffset+=2;
            
            [handshakeData getBytes:&_sessionID range:NSMakeRange(scanOffset, 2)];
            _sessionID = htons(_sessionID);
            scanOffset+=2;
            
            [handshakeData getBytes:&_encryptionType range:NSMakeRange(scanOffset, 1)];
        }
        
    }
    return self;
}

@end
