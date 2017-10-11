//
//  PipeTwoPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/5.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "PipeTwoPacket.h"

#define PacketSize 7

@implementation PipeTwoPacket{
    NSMutableData *_packetData;
    int _packetSize;
    struct {
        unsigned short _deviceId_offset:8;
        unsigned short _deviceId_len:8;
        
        unsigned short _message_offset:8;
        unsigned short _message_len:8;
        
        unsigned short _flag_offset;
        unsigned short _flag_len;
        
    }_packetFlag;
}

-(void)initProtocolLayout{
    
    _packetFlag._deviceId_offset = 0;
    _packetFlag._deviceId_len =4;
    
    _packetFlag._message_offset= 4;
    _packetFlag._message_len =2;
    
    _packetFlag._flag_offset =6;
    _packetFlag._flag_len =1;
    
    _packetSize = 7;
    
}
-(id)initWithSyncData:(NSData *)data{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        if (data.length==_packetSize) {
            _packetData = [[NSMutableData alloc]initWithData:data];
        }
    }
    return self;
}

-(int)getDeviceID{
    if (_packetData.length == _packetSize) {
        unsigned int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._deviceId_offset, _packetFlag._deviceId_len)];
        return ntohl(temp);
        
    }return -1;
}

+(int)getPacketSize{
    return PacketSize;
}

-(int)getPacketSize{
    return _packetSize;
}
@end
