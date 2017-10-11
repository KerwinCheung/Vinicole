//
//  setCloudDataPointReturnPacket.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "SetCloudDataPointReturnPacket.h"

#define PacketSize 7

@implementation SetCloudDataPointReturnPacket{
    
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short deviceID_offset:8;
        unsigned short deviceID_len:8;
        
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short code_offset:8;
        unsigned short code_len:8;
        
    }_packetFlag;
    
}

-(void)initProtocolLayout{
    
    _packetFlag.deviceID_offset = 0;
    _packetFlag.deviceID_len =4;
    
    _packetFlag.messageID_offset = 4;
    _packetFlag.messageID_len =2;
    
    _packetFlag.code_offset =6;
    _packetFlag.code_len = 1;
    
    _packetSize = 7;
    
}

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        if (data.length != _packetSize) {
            return nil;
        }
        
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
        
    }
    return self;
}

+(int)getPacketSize{
    return PacketSize;
}

-(int)getPacketSize{
    return _packetSize;
}

-(int)getDeviceID{
    if (_packetData.length == _packetSize) {
        unsigned int temp ;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len)];
        return ntohl(temp);
    }return -1;
}

-(int)getMessageID{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len)];
        return ntohs(temp);
    }return -1;
}

-(int)getCode{
    if (_packetData.length == _packetSize) {
        unsigned char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
        return temp;
    }return -1;
    
}

@end
