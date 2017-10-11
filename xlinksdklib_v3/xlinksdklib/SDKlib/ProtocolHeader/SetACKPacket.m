//
//  SetACKPacket.m
//  xlinksdklib
//
//  Created by xtmac on 14/12/15.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SetACKPacket.h"

#define PACKETSIZE 9

@implementation SetACKPacket{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _flag_offset:8;
        unsigned short _flag_len:8;
        
        unsigned short _port_offset:8;
        unsigned short _port_len:8;
        
        unsigned short _accessKey_offset:8;
        unsigned short _accessKey_len:8;
        
        
        
    }_packetFlag;
    
}

-(void)initProtocolLayout{
    
    _packetFlag._messageID_offset = 0;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._flag_offset = 2;
    _packetFlag._flag_len = 1;
    
    _packetFlag._port_offset = 3;
    _packetFlag._port_len = 2;
    
    _packetFlag._accessKey_offset = 5;
    _packetFlag._accessKey_len = 4;
    
}

-(instancetype)init{
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithLength:PACKETSIZE];
    }
    return self;
}

-(id)initWithMessageID:(unsigned short)messageID andAppListenPort:(unsigned short)port andAccessKey:(unsigned int)ack andFlag:(unsigned char)flag{
    self = [self init];
    
    messageID = htons(messageID);
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len) withBytes:&messageID length:_packetFlag._messageID_len];
    
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&flag length:_packetFlag._flag_len];
    
    port = htons(port);
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&port length:_packetFlag._port_len];
    
    ack = htonl(ack);
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._accessKey_offset, _packetFlag._accessKey_len) withBytes:&ack length:_packetFlag._accessKey_len];
    
    return self;
}

-(int)getPacketSize{
    return PACKETSIZE;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

@end
