//
//  PipeReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "PipeReturnPacket.h"

#define PACKETSIZE_PIPE_Return 7

@implementation PipeReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short _toID_offset:8;
        unsigned short _toID_len:8;
        
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _code_offset:8;
        unsigned short _code_len:8;
        
        
    }_packetFlag;
}

-(void)initProtocolLayout{
    _packetFlag._toID_offset = 0;
    _packetFlag._toID_len =4;
    
    _packetFlag._messageID_offset =4;
    _packetFlag._messageID_len =2;
    
    _packetFlag._code_offset =6;
    _packetFlag._code_len =1;
    
    _packetSize = _packetFlag._code_len+_packetFlag._messageID_len+_packetFlag._toID_len;
}

+(PipeReturnPacket *)packetWithToId:(__b4)toId andMessageID:(__b2)msgID andCode:(__b1)code{
    return nil;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_PIPE_Return);
}

-(id)initWithData:(NSMutableData *)data{
    if (self =[super init]) {
        [self initProtocolLayout];
        if (data.length==_packetSize) {
            _packetData = [[NSMutableData alloc]initWithData:data];
        }
        
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
    }
    return self;
}


-(int)getToID{
    if (_packetData.length==_packetSize) {
        int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._toID_offset, _packetFlag._toID_len)];
        
        return ntohl(temp);
        
    }else return -1;
}

-(int)getMessageID{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len)];
        return ntohs(temp);
        
    }else
    return -1;
}

-(int)getCode{
    
    if (_packetData.length == _packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len)];
        return temp;
    }
    return -1;
}

-(void)setToID:(int)toID{
    if (_packetData.length == _packetSize) {
        int tempToId = htonl(toID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._toID_offset, _packetFlag._toID_len) withBytes:&tempToId length:_packetFlag._toID_len];
    }
}

-(void)setMessageID:(int)msgID{
    if (_packetData.length ==_packetSize) {
        unsigned short temp = msgID;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len) withBytes:&temp length:_packetFlag._messageID_len];
    }
}

-(void)setCode:(int)code{
    if (_packetData.length == _packetSize) {
        char cd = (char)code;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len) withBytes:&cd length:_packetFlag._code_len];
    }
}


-(NSString *)description{
    if (_packetData.length == _packetSize) {
        char temp[_packetSize];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        NSMutableString *str = [[NSMutableString alloc]init];
        if (str) {
            for (int i = 0; i<_packetSize; i++) {
                [str appendFormat:@"#%d=%02x",i,temp[i]];
            }
            
            return str;
        }else{
            return nil;
        }
    }
    return nil;
}

@end
