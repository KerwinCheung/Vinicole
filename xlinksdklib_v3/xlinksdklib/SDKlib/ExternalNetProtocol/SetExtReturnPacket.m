//
//  SetExtReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SetExtReturnPacket.h"

#define PACKET_SETEXTRETURN 7

@implementation SetExtReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
    
        struct {
            unsigned short toDeviceID_offset:8;
            unsigned short toDeviceID_len:8;
            
            unsigned short messageID_offset:8;
            unsigned short messageID_len:8;
            
            unsigned short flag_offset:8;
            unsigned short flag_len:8;
            
        }_packetFlag;
        
        
    
}

-(void)initProtocolLayout{
    _packetFlag.toDeviceID_offset=0;
    _packetFlag.toDeviceID_len =4;
    
    _packetFlag.messageID_offset =4;
    _packetFlag.messageID_len =2;
    
    _packetFlag.flag_offset =6;
    _packetFlag.flag_len =1;
}

-(void)setToDeviceID:(int)dvceID{
    if (_packetData.length == _packetSize) {
        int tempDvceId = htonl(dvceID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.toDeviceID_offset, _packetFlag.toDeviceID_len) withBytes:&tempDvceId length:_packetFlag.toDeviceID_len];
    }
}

-(void)setMessageID:(int)msgID{
    if (_packetData.length == _packetSize) {
        unsigned short tempMsgId = htons((unsigned short)msgID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&tempMsgId length:_packetFlag.messageID_len];
    }
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize =PACKET_SETEXTRETURN;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
    }
    return self;
}

-(void)setPacketData:(NSData *)data{
    if (_packetData.length == _packetSize&&data.length ==_packetSize) {
        [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
    }
}

-(id)initWithToDeviceId:(int)deviceId andMsgID:(int)msgID andFlag:(int)flag{
    self = [super init];
    if (self) {
        
        [self initProtocolLayout];
        _packetSize =PACKET_SETEXTRETURN;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        if (_packetData.length == _packetSize) {
            int tempDvceId = htonl(deviceId);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.toDeviceID_offset, _packetFlag.toDeviceID_len) withBytes:&tempDvceId length:_packetFlag.toDeviceID_len];
            
            
            unsigned short tempMsgId = htons((unsigned short)msgID);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&tempMsgId length:_packetFlag.messageID_len];
            
            char fg= flag;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&fg length:_packetFlag.flag_len];
            
        }
    }
    return self;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKET_SETEXTRETURN);
}

-(void)setFlag:(int)flag{
    if (_packetData.length == _packetSize) {
        char fg= (char)flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&fg length:_packetFlag.flag_len];
    }
}

-(NSString *)description{
    
    if (_packetData.length == _packetSize) {
        char temp[_packetSize];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for (int i=0; i<_packetSize; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
        
    }
    return nil;
    
}

@end
