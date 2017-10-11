//
//  SetPSWDReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SetPSWDReturnPacket.h"

#define PACKETSIZE 3

@implementation SetPSWDReturnPacket{
    
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
    if (_packetData.length == PACKETSIZE) {
        unsigned short msgId;
        [_packetData getBytes:&msgId range:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len)];
        return ntohs(msgId);
    }return -1;
}

-(int)getCode{
    if (_packetData.length == PACKETSIZE) {
        unsigned char tp;
        [_packetData getBytes:&tp range:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len)];
        return tp;
    }return -1;
}
@end
