//
//  SetACKReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac on 14/12/15.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SetACKReturnPacket.h"

#define PACKETSIZE 3

@implementation SetACKReturnPacket{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _code_offset:8;
        unsigned short _code_len:8;
    }_packetFlag;
    
}


-(void)initProtocolLayout{
    _packetFlag._messageID_offset = 0;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._code_offset = 2;
    _packetFlag._code_len = 1;
    
}

-(id)initWithData:(NSData *)data{
    
    self = [super init];
    if (self) {
        
        if (data.length != PACKETSIZE) {
            return nil;
        }
        
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithData:data];
        
    }
    return self;
}

+(int)getPacketSize{
    return PACKETSIZE;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(int)getMessageID{
    unsigned short msgId;
    [_packetData getBytes:&msgId range:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len)];
    return ntohs(msgId);
}

-(int)getCode{
    unsigned char tp;
    [_packetData getBytes:&tp range:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len)];
    return tp;
}


@end
