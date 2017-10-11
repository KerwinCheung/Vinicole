//
//  LocalBindRespPacket.m
//  xlinksdklib
//
//  Created by Leon on 15/12/7.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import "LocalBindRespPacket.h"

#define PACKETSIZE  5

@implementation LocalBindRespPacket {
    
    NSMutableData *_packetData;
    
    struct {
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _flag_offset:8;
        unsigned short _flag_len:8;

        unsigned short _code_offset:8;
        unsigned short _code_len:8;
        
        unsigned short _master_key_offset:8;
        unsigned short _master_key_len:8;

    }_packetFlag;

}

-(void)initProtocolLayout{
    
    _packetFlag._messageID_offset = 0;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._flag_offset = 2;
    _packetFlag._flag_len = 1;
    
    _packetFlag._code_offset = 3;
    _packetFlag._code_len = 1;
    
    _packetFlag._master_key_offset = 4;
    _packetFlag._master_key_len = 4;
    
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

-(int)getFlag {
    unsigned char flag;
    [_packetData getBytes:&flag range:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len)];
    return flag;
}

-(int)getCode{
    unsigned char code;
    [_packetData getBytes:&code range:NSMakeRange(_packetFlag._code_offset, _packetFlag._code_len)];
    return code;
}

-(int)getMasterKey {
    int masterKey = 0;
    if( [self getCode] == 0 ) {
        [_packetData getBytes:&masterKey range:NSMakeRange(_packetFlag._master_key_offset, _packetFlag._master_key_len)];
    }
    return masterKey;
}

@end
