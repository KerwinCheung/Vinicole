//
//  LocalBindPacket.m
//  xlinksdklib
//
//  Created by Leon on 15/12/7.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import "LocalBindPacket.h"

#define PACKETSIZE  5

@implementation LocalBindPacket {
    
    NSMutableData *_packetData;
    
    struct {
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _flag_offset:8;
        unsigned short _flag_len:8;
        
        unsigned short _port_offset:8;
        unsigned short _port_len:8;
    }_packetFlag;
    
}

-(void)initProtocolLayout{
    
    _packetFlag._messageID_offset = 0;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._flag_offset = 2;
    _packetFlag._flag_len = 1;
    
    _packetFlag._port_offset = 3;
    _packetFlag._port_len = 2;
    
}

-(id)initWithMessageID:(int)messageID port:(int)port andFlag:(int)flag {
    self = [super init];
    if (self) {
        
        [self initProtocolLayout];
        
        _packetData = [NSMutableData dataWithLength:PACKETSIZE];
        
        unsigned short msgID = messageID;
        msgID = htons(msgID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len) withBytes:&msgID length:_packetFlag._messageID_len];
        
        unsigned char fg= flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&fg length:_packetFlag._flag_len];
        
        unsigned short p = htons(port);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&p length:_packetFlag._port_len];
    }
    
    return self;
}

-(int)getPacketSize{
    return PACKETSIZE;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

@end
