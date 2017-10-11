//
//  ConnectPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ConnectPacket.h"

#define PACKETSIZE_CONNECT 26

@implementation ConnectPacket{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        
        unsigned short version_offset:8;
        unsigned short version_len:8;
        
        unsigned short deviceId_offset:8;
        unsigned short deviceId_len:8;
        
        unsigned short authorizedLen_offset:8;
        unsigned short authorizedLen_len:8;
        
        unsigned short authorizedStr_offset:8;
        unsigned short authorizedStr_len:8;
        
        unsigned short reseved_offset:8;
        unsigned short reseved_len:8;
        
        unsigned short keepLive_offset:8;
        unsigned short keepLive_len:8;
        
        
    }_packetFlag;
    
}

-(void)initProtocolLayout{
    _packetFlag.version_offset =0;
    _packetFlag.version_len =1;
    
    _packetFlag.deviceId_offset =1;
    _packetFlag.deviceId_len = 4;
    
    _packetFlag.authorizedLen_offset = 5;
    _packetFlag.authorizedLen_len =2;
    
    _packetFlag.authorizedStr_offset =7;
    _packetFlag.authorizedStr_len = 16;
    
    _packetFlag.reseved_offset = 23;
    _packetFlag.reseved_len =1;
    
    _packetFlag.keepLive_offset = 24;
    _packetFlag.keepLive_len =2;
}

-(id)initWithVersion:(int)version andDeviceId:(int)deviceId andAuthorizedLen:(int)authLen andAuthorizeStr:(NSData *)data andReseved:(int)reseved andKeepLive:(int)keepLive{
    
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_CONNECT;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        if (_packetData.length == _packetSize) {
            char tVs= version;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.version_offset, _packetFlag.version_len) withBytes:&tVs length:_packetFlag.version_len];
            
            int did = htonl(deviceId);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceId_offset, _packetFlag.deviceId_len) withBytes:&did length:_packetFlag.deviceId_len];
            
            unsigned short len = authLen;
            len = htons(len);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.authorizedLen_offset, _packetFlag.authorizedLen_len) withBytes:&len length:_packetFlag.authorizedLen_len];
            
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.authorizedStr_offset, _packetFlag.authorizedStr_len) withBytes:data.bytes length:_packetFlag.authorizedStr_len];
            
            char resvd =reseved;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.reseved_offset, _packetFlag.reseved_len) withBytes:&resvd length:_packetFlag.reseved_len];
            
            unsigned short alive = keepLive;
            alive = htons(alive);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.keepLive_offset, _packetFlag.keepLive_len) withBytes:&alive length:_packetFlag.keepLive_len];
            
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
    return (PACKETSIZE_CONNECT);
}

-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_CONNECT;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
    }
    return self;
}

-(void)setVersion:(int)version{
    if (_packetData.length == _packetSize) {
        char tVs= version;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.version_offset, _packetFlag.version_len) withBytes:&tVs length:_packetFlag.version_len];
    }

}

-(void)setDeviceId:(int)deviceId{
    if (_packetData.length == _packetSize) {
        int did = htonl(deviceId);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceId_offset, _packetFlag.deviceId_len) withBytes:&did length:_packetFlag.deviceId_len];
    }
}

-(void)setAuthLen:(int)authLen{
    if (_packetData.length == _packetSize) {
        unsigned short len = authLen;
        len = htons(len);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.authorizedLen_offset, _packetFlag.authorizedLen_len) withBytes:&len length:_packetFlag.authorizedLen_len];
    }
}

-(void)setAuthStr:(NSData *)strDt{
    if (_packetData.length == _packetSize) {
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.authorizedStr_offset, _packetFlag.authorizedStr_len) withBytes:strDt.bytes length:_packetFlag.authorizedStr_len];
    }
}

-(void)setReseved:(int)reserved{
    if (_packetData.length == _packetSize) {
        char resvd =reserved;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.reseved_offset, _packetFlag.reseved_len) withBytes:&resvd length:_packetFlag.reseved_len];
    }
}

-(void)setKeepAliveTime:(int)aliveTimer{
    if (_packetData.length == _packetSize) {
        unsigned short alive = aliveTimer;
        alive = htons(alive);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.keepLive_offset, _packetFlag.keepLive_len) withBytes:&alive length:_packetFlag.keepLive_len];
    }
}


-(NSString *)description{
    if (_packetData.length ==_packetSize) {
        char temp[_packetSize];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for (int i =0; i<_packetSize; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
    }
    return nil;
}
@end
