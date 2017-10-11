//
//  LoginPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/5.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "LoginPacket.h"
#import "ExtHeader.h"

#define PACKETSIZE_LOGIN 3
#define PACKETSIZE 26

@implementation LoginPacket{
    LOGIN_HEADER _loginStruct;
    int _packetSize;
    NSMutableData *_packetData;
    
    struct {
        unsigned int _version_offset:8;           //一个字节
        unsigned int _version_len:8;
        
        unsigned int _appID_offset:8;             //四个字节
        unsigned int _appID_len;
        
        unsigned int _authorize_len_offset:8;   //两个字节
        unsigned int _authorize_len_len:8;
        
        unsigned int _authorize_str_offset:8;   //两个字节
        unsigned int _authorize_str_len:8;
        
        unsigned int _reserved_offset:8;               //一个字节
        unsigned int _reserved_len:8;
        
        unsigned int _keepLive_offset:8;        //两个字节
        unsigned int _keepLive_len:8;
        
    }_packetFlag;
    
}



-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetData.length;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_LOGIN);
}

-(void)initProtocolLayout{
    _packetFlag._version_offset =0;
    _packetFlag._version_len =1;
    
    _packetFlag._appID_offset = 1;
    _packetFlag._appID_len =4;
    
    _packetFlag._authorize_len_offset =5;
    _packetFlag._authorize_len_len =2;
    
    _packetFlag._authorize_str_offset =7;
    _packetFlag._authorize_str_len = 16;
    
    _packetFlag._reserved_offset = 23;
    _packetFlag._reserved_len =1;
    
    _packetFlag._keepLive_offset =24;
    _packetFlag._keepLive_len =2;
}

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        [self initProtocolLayout];
        
        _packetSize = sizeof(LOGIN_HEADER);
        
        _packetData = [[NSMutableData alloc]init];
        
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];

    }
    
    return self;
}


-(id)initWithVersion:(int)version andAppID:(int)appId andAuthLen:(int)authLen andAuthStr:(NSData *)authStr andReserved:(int)reserved andKeepAlive:(int)liveTime{
    
    self = [super init];
    
    if (self) {
        
        [self initProtocolLayout];
        
        
        
        _packetData = [[NSMutableData alloc]init];
        
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
        
        char v = version;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&v length:_packetFlag._version_len];
        
        
        
        int appid = htonl(appId);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._appID_offset, _packetFlag._appID_len) withBytes:&appid length:_packetFlag._appID_len];
        
        
        
        unsigned short aLen = authLen;
        aLen = htons(aLen);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._authorize_len_offset, _packetFlag._authorize_len_len) withBytes:&aLen length:_packetFlag._authorize_len_len];
        
        
        
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._authorize_str_offset, _packetFlag._authorize_str_len) withBytes:authStr.bytes length:_packetFlag._authorize_str_len];
        
            char rs= reserved;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&rs length:_packetFlag._reserved_len];
        
        
        
            unsigned short alt = liveTime;
            alt = htons(alt);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._keepLive_offset, _packetFlag._keepLive_len) withBytes:&alt length:_packetFlag._keepLive_len];
            
        
        
    }
    
    return self;
    
}

-(void)printByteData:(NSData *)data{
//    char temp[data.length];
//    [data getBytes:temp range:NSMakeRange(0, data.length)];
//    
//    for (int i=0; i<data.length; i++) {
//        NSLog(@"%d ->%02x",i,temp[i]);
//    }
    
}

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        if (data.length ==_packetSize) {
            
            [self initProtocolLayout];
            
            _packetSize = sizeof(LOGIN_HEADER);
            
            _packetData = [[NSMutableData alloc]init];
            
            [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
            
            [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
            
            
        }else{
            return nil;
        }
    }
    return self;
}

-(int)getVersion{
    if (_packetData.length ==_packetSize) {
        
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len)];
        return temp;
        
    }
    return -1;
}

-(int)getAppId{
    
    if (_packetData.length == _packetSize) {
        int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._appID_offset, _packetFlag._appID_len)];
        return ntohl(temp);
    }
    return -1;
}

-(int)getAuthLen{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._authorize_len_offset, _packetFlag._authorize_len_len)];
        return ntohs(temp);
    }
    return -1;
}

-(NSData *)getAuthStr{
    if (_packetData.length == _packetSize) {
        NSData *subdata = [_packetData subdataWithRange:NSMakeRange(_packetFlag._authorize_str_offset, _packetFlag._authorize_str_len)];
        return subdata;
    }
    return nil;
}

-(int)getReserved{
    if (_packetData.length == _packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len)];
        return temp;
    }
    return 0;
}

-(int)getAliveTime{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._keepLive_offset, _packetFlag._keepLive_len)];
        return ntohs(temp);
    }
    return 0;
}

#pragma mark
#pragma mark set method

-(void)setVersion:(int)version{
    if (_packetData.length ==_packetSize) {
        char temp = version;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&temp length:_packetFlag._version_len];
    }
    return;
}

-(void)setAppId:(int)appId{
    if (_packetData.length ==_packetSize) {
        int temp = HTONL(appId);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._appID_offset, _packetFlag._appID_len) withBytes:&temp length:_packetFlag._appID_len];
    }
    return;
}

-(void)setAuthLen:(int)len{
    if (_packetData.length ==_packetSize) {
        unsigned short temp = len;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._authorize_len_offset, _packetFlag._authorize_len_len) withBytes:&temp length:_packetFlag._authorize_len_len];
    }
    return;
}

-(void)setAuthStr:(NSData *)data{
    if (_packetData.length ==_packetSize) {
        if (data.length == _packetFlag._authorize_str_len) {
            
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._authorize_str_offset, _packetFlag._authorize_str_len) withBytes:data.bytes length:_packetFlag._authorize_str_len];
        }
    }
    return;
}

-(void)setReserved:(int)reserved{
    if (_packetData.length ==_packetSize) {
        char temp = reserved;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&temp length:_packetFlag._reserved_len];
    }
    return;
}

-(void)setAliveTime:(int)aliveTime{
    if (_packetData.length ==_packetSize) {
        unsigned short temp = aliveTime;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._keepLive_offset, _packetFlag._keepLive_len) withBytes:&temp length:_packetFlag._keepLive_len];
    }
    return;
}


-(NSString *)description{
    
    if (_packetData.length == _packetSize) {
        
        char temp[_packetSize];
        
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        
        NSMutableString *str =[[NSMutableString alloc]init];
        
        for (int i=0; i<_packetSize;i++) {
            
            [str appendFormat:@"#%d=%02x",i,temp[i]];
            
        }
        
        return str;
        
    }
    
    return nil;
    
}

@end
