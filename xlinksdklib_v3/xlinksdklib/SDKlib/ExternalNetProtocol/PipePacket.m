//
//  PipePacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "PipePacket.h"

#define PACKETSIZE_PIPE 7

@implementation PipePacket{
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

}

+(PipePacket *)packetWithDeviceId:(__b4)dvceID andMessageID:(__b2)messageID andFlag:(__b1)flag{
    return nil;
}

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc] initWithData:data];
        _packetSize = (int)_packetData.length;
    }
    return self;
}


-(id)initWithDeviceId:(int)dvceID andMessageID:(int)messageID andFlag:(int)flag{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        
        _packetSize = PACKETSIZE_PIPE;
        
        _packetData  = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
            int temp = htonl(dvceID);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._deviceId_offset, _packetFlag._deviceId_len) withBytes:&temp length:_packetFlag._deviceId_len];
            
            unsigned short pTemp = messageID;
            pTemp = htons(pTemp);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._message_offset, _packetFlag._message_len) withBytes:&pTemp length:_packetFlag._message_len];
            
            char fTemp = flag;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&fTemp length:_packetFlag._flag_len];
            

    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_PIPE;
        _packetData  = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
    }
    return self;
}

//get method

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(int)getPacketSize{
    return (PACKETSIZE_PIPE);
}

-(int)getDeviceID{
    if (_packetData.length ==_packetSize) {
        int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._deviceId_offset, _packetFlag._deviceId_len)];
        return NTOHL(temp);
    }
    
    return -1;
}

-(int)getMessageID{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._message_offset, _packetFlag._message_len)];
        return NTOHS(temp);
    }
    return -1;
}

-(int)getFlag{
    
    if (_packetData.length == _packetSize ) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._flag_offset, _packetFlag._message_len)];
        return temp;
    }
    return -1;
    
}

//set method

-(void)setPacketData:(NSMutableData *)data{
    if (data) {
        if (data.length == _packetData.length) {
            [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
        }
    }
}

-(void)setDeviceID:(int)dvceID{
    if (_packetData.length ==_packetSize) {
        int temp = HTONL(dvceID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._deviceId_offset, _packetFlag._deviceId_len) withBytes:&temp length:_packetFlag._deviceId_len];
    }
}

-(void)setMessageID:(int)msgID{
    if (_packetData.length ==_packetSize) {
        unsigned short temp = msgID;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._message_offset, _packetFlag._message_len) withBytes:&temp length:_packetFlag._message_len];
    }
}

-(void)setFlag:(int)flg{
    if (_packetData.length ==_packetSize) {
        char temp[_packetSize];
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&temp length:_packetFlag._flag_len];
    }
}

-(NSString *)description{
    if (_packetData.length == _packetSize) {
        char temp[_packetSize];
        NSMutableString *str = [[NSMutableString alloc]init];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        for (int i =0; i<_packetSize; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
        
    }
    return nil;
}

@end
