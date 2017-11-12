//
//  PacketModel.m
//  lightify
//
//  Created by xtmac on 19/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

/*
 帧头:固定为 0xAA。 - 1Byte
 指令:见如下指令定义; - 2Byte
 数据长度:“流水号+地址+数据+校验+帧尾”的字节数; - 2Byte
 地址:根据不同类型地址变化,地址类型见帧头定义; - NByte
 数据:不确定,数据根据不同的控制指令变化; - NByte
 校验:将“指令+数据长度+流水号+地址+数据”进行异或校验; - 1Byte
 帧尾:固定为 0x55。 - 1Byte
 */

#import "PacketModel.h"

@implementation PacketModel{
    char _addressLen[0b11111111];
}

-(instancetype)init{
    if (self = [super init]) {
        _head = 0xAAAA;
        _tail = 0x5555;
    
    }
    return self;
}

-(instancetype)initWithPacketData:(NSData *)packetData{
    if (self = [self init]) {
        [packetData getBytes:&_command range:NSMakeRange(0, 1)];
        
        _data = [packetData subdataWithRange:NSMakeRange(1, 7)];
    }
    return self;
}

-(NSData *)getData{
    //  无论收发数据包长度均为：(帧头)2  +(长度)2+(命令)1+（ID）1+（数据）7       +(校验)1+(帧尾)2 = 16 Byte
    //                         aaaa   0010     02     22    35011c2000005e 66      5555
    
    NSMutableData *data = [NSMutableData data];
    /*
    unsigned short temp;
    
    //包头 2
    [data appendBytes:&_head length:sizeof(UInt16)];
    
    //长度 2
    _length = 16;
    temp = htons(_length);
    [data appendBytes:&temp length:sizeof(unsigned short)];
    
    //命令 1
    [data appendBytes:&_command length:sizeof(unsigned char)];
    
    //ID 1
    unsigned char tempSerial;
    tempSerial = htons(_serial);
    [data appendBytes:&_serial length:sizeof(unsigned char)];
    */
    //数据
    [data appendData:_data];
    /*
    //校验码
    _checkCode = [self getCheckCode];
    [data appendBytes:&_checkCode length:sizeof(unsigned char)];
    
    //包尾
    [data appendBytes:&_tail length:sizeof(UInt16)];
    */
    return [NSData dataWithData:data];
}

-(BOOL)veriflcation{
    
    unsigned char checkCode = [self getCheckCode];
    if (checkCode == _checkCode) {
        return true;
    }else{
        return false;
    }
}

-(unsigned char)getCheckCode{
    
    unsigned short checkLen = 11;
    char checkData[checkLen];
    
    memcpy(checkData, &_length, 2);
    memcpy(checkData+2, &_command, 1);
    memcpy(checkData+2+1, &_serial, 1);
    [_data getBytes:checkData+2+1+1 length:_data.length];
    
    unsigned short checkCode = checkData[0];
    for (unsigned short i = 1; i < checkLen; i++) {
        checkCode ^= checkData[i];
    }
    
    return checkCode;

}

@end
