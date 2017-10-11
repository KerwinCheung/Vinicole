//
//  SetPSWDPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SetPSWDPacket.h"

#define PACKETSIZE 37

@implementation SetPSWDPacket
{
    NSMutableData *_packetData;

    struct {
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _flag_offset:8;
        unsigned short _flag_len:8;
        
        unsigned short _port_offset:8;
        unsigned short _port_len:8;
        
        unsigned short _oldAuth_offset:8;
        unsigned short _oldAuth_len:8;
        
        unsigned short _newAuth_offset:8;
        unsigned short _newAuth_len:8;
       
    
    }_packetFlag;
}

-(void)initProtocolLayout{
    
    _packetFlag._messageID_offset = 0;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._flag_offset = 2;
    _packetFlag._flag_len = 1;
    
    _packetFlag._port_offset = 3;
    _packetFlag._port_len = 2;
    
    _packetFlag._oldAuth_offset = 5;
    _packetFlag._oldAuth_len = 16;
    
    _packetFlag._newAuth_offset = 21;
    _packetFlag._newAuth_len = 16;
    
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, 37)];
    }
    return self;
}

-(id)initWithMessageID:(int)messageID andAppListenPort:(int)port andOldAuth:(NSData *)oldAuth andNewAuth:(NSData *)newAuth andFlag:(int)flag{
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

        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._oldAuth_offset, _packetFlag._oldAuth_len) withBytes:oldAuth.bytes length:_packetFlag._oldAuth_len];
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._newAuth_offset, _packetFlag._newAuth_len) withBytes:newAuth.bytes length:_packetFlag._newAuth_len ];

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
