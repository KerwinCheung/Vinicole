//
//  LocalPipeReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/28.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "LocalPipeReturnPacket.h"

#define PACKETSIZE 3

@implementation LocalPipeReturnPacket{
    
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
    _packetFlag._messageID_len =2;
    
    _packetFlag._code_offset =2;
    _packetFlag._code_len =1;
    
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
    }
    return self;
    
}


-(id)initWithData:(NSData *)data{
    
    self = [super init];
    
    if (self) {
        
        if (data.length != PACKETSIZE) {
            return nil;
        }
        
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]initWithData:data];
    }
    
    return self;
    
}

-(int)getMessageID{
    
    unsigned short msgID;
    if (_packetData.length != PACKETSIZE) {
        return -1;
    }
    [_packetData getBytes:&msgID range:NSMakeRange(0, 2)];
    return ntohs(msgID);
    
}

-(int)getCode{
    
    unsigned char code;
    if (_packetData.length != PACKETSIZE) {
        return -1;
    }
    [_packetData getBytes:&code range:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len)];
    return code;
    
}

+(int)getPacketSize{

    return PACKETSIZE;
}

@end
