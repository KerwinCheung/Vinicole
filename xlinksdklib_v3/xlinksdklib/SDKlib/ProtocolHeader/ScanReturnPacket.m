//
//  ScanReturnPacket.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/19.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "ScanReturnPacket.h"

@implementation ScanReturnPacket

-(instancetype)initWithData:(NSData *)data{
    if (self = [super init]) {
        
        NSMutableData *scanData = [NSMutableData dataWithData:data];
        
        UInt8 offset = 0;
        
        //版本号
        [scanData getBytes:&_version range:NSMakeRange(offset, 1)];
        offset+=1;
        
        //mac长度
        if (_version < 3) { //v1 v2版本缺少mac长度，伪造加上
            int16_t macLen = htons(6);
            [scanData replaceBytesInRange:NSMakeRange(offset, 0) withBytes:&macLen length:2];
        }
        int16_t macLen;
        [scanData getBytes:&macLen range:NSMakeRange(offset, 2)];
        macLen = htons(macLen);
        offset+=2;
        
        //mac
        _macData = [scanData subdataWithRange:NSMakeRange(offset, macLen)];
        offset+=macLen;
        
        //productID长度
        int16_t productIDLen;
        [scanData getBytes:&productIDLen range:NSMakeRange(offset, 2)];
        productIDLen = htons(productIDLen);
        offset+=2;
        
        //productID
        _productIDData = [scanData subdataWithRange:NSMakeRange(offset, productIDLen)];
        offset+=productIDLen;
        
        //WIFI模组硬件类型
        [scanData getBytes:&_mcuHardVersion range:NSMakeRange(offset, 1)];
        offset+=1;
        
        //MCU软件(固件)版本
        [scanData getBytes:&_mcuSoftVersion range:NSMakeRange(offset, 2)];
        _mcuSoftVersion = htons(_mcuSoftVersion);
        offset+=2;
        
        //port
        [scanData getBytes:&_port range:NSMakeRange(offset, 2)];
        _port = htons(_port);
        offset+=2;
        
        //DeviceType
        if (_version == 1) { //v1版本缺少设备类型，伪造加上
            int16_t deviceType = htons(0);
            [scanData replaceBytesInRange:NSMakeRange(offset, 0) withBytes:&deviceType length:2];
        }
        int16_t deviceType;
        [scanData getBytes:&_deviceType range:NSMakeRange(offset, 2)];
        _deviceType = htons(_deviceType);
        offset+=2;
        
        //mode
        if (_version < 3) { //v1 v2版本缺少mode flag，伪造加上
            int8_t flag = 0b11;
            [scanData replaceBytesInRange:NSMakeRange(offset, 0) withBytes:&macLen length:1];
        }
        [scanData getBytes:&_mode range:NSMakeRange(offset, 1)];
        offset+=1;
        
        //Flag
        [scanData getBytes:&_flag range:NSMakeRange(offset, 1)];
        offset+=1;
        
        //设备名称
        if (_flag & 0b00000001) { //有设备名称
            int16_t nameLen;
            [scanData getBytes:&nameLen range:NSMakeRange(offset, 2)];
            nameLen = htons(nameLen);
            offset+=2;
            _name = [NSString stringWithUTF8String:[scanData subdataWithRange:NSMakeRange(offset, nameLen)].bytes];
            offset+=nameLen;
        }
        
        //AccessKey
        if (_version > 1 && _flag & 0b00000100) { //有AccessKey
            [scanData getBytes:&_accessKey range:NSMakeRange(offset, 4)];
            _accessKey = htonl(_accessKey);
            offset+=4;
        }
        
    }
    return self;
}

@end
