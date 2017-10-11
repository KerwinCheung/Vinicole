//
//  PipeTwoReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/5.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "PipeTwoReturnPacket.h"


#define PacketSize 3

@implementation PipeTwoReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
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
    
    _packetSize = _packetFlag._code_offset+_packetFlag._code_len;
    
}

-(id)initWithReturnData:(NSData *)data{
    self = [super init];
    if (self) {
        
        [self initProtocolLayout];
        
        _packetData = [[NSMutableData alloc]init];
        
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        if (data.length != _packetSize) {
            
            return nil;
            
        }
        
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

-(int)getMessageID{
    if (_packetData.length == _packetSize) {
        unsigned short msgID;
        [_packetData getBytes:&msgID range:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len)];
        return ntohs(msgID);
    }return -1;
}

-(int)getCode{
    if (_packetData.length == _packetSize) {
        unsigned char tempCode;
        [_packetData getBytes:&tempCode range:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len)];
    }return -1;
}
@end
