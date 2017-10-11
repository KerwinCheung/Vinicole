//
//  SetExtPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SetExtPacket.h"

#define PACKETSIZE_SETEXT 7

@implementation SetExtPacket{
    
    NSMutableData *_packetData;
    int _packetSize;
    struct {
        unsigned short deviceID_offset:8;
        unsigned short deviceID_len:8;
        
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short flag_offset:8;
        unsigned short flag_len:8;
        
    }_packetFlag;

}
-(id)initWithDeviceId:(int)deviceId andMsgID:(int)msgID andFlag:(int)flag{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_SETEXT;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        if (_packetData.length == _packetSize) {
            int tempDvceId = htonl(deviceId);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&tempDvceId length:_packetFlag.deviceID_len];
            
            
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
    return (PACKETSIZE_SETEXT);
}

-(void)initProtocolLayout{
    _packetFlag.deviceID_offset=0;
    _packetFlag.deviceID_len =4;
    
    _packetFlag.messageID_offset =4;
    _packetFlag.messageID_len =2;
    
    _packetFlag.flag_offset =6;
    _packetFlag.flag_len =1;
}

-(void)setDeviceID:(int)dvceID{
    if (_packetData.length == _packetSize) {
        int tempDvceId = htonl(dvceID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&tempDvceId length:_packetFlag.deviceID_len];
    }
}

-(void)setMessageID:(int)msgID{
    if (_packetData.length == _packetSize) {
        unsigned short tempMsgId = htons((unsigned short)msgID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&tempMsgId length:_packetFlag.messageID_len];
    }
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
