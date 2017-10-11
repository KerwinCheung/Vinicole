//
//  HandShakeHeader.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "HandShakeHeader.h"
#import "SDKHeader.h"

#define PACKETSIZE 24
/*
 *@discussion
 *  握手协议包
 */
@implementation HandShakeHeader{
    
    NSMutableData *_packetData;
    
    struct {
        
        unsigned int _version_offset:8;
        unsigned int _version_len:8;
        
        unsigned int _deviceKey_len_offset:8;
        unsigned int _deviceKey_len_len:8;
        
        unsigned int _deviceKey_str_offset:8;
        unsigned int _deviceKey_str_len:8;
        
        unsigned int _port_offset:8;
        unsigned int _port_len:8;
        
        unsigned int _reserved_offset:8;
        unsigned int _reserved_len:8;
        
        unsigned int _keepLive_offset:8;
        unsigned int _keepLive_len:8;
    
    }_packetFlag;

}
/*
 *@discussion
 *  协议的字节布局
 */
-(void)initProtocolLayout{
    
    _packetFlag._version_offset =0;
    _packetFlag._version_len =1;
    
    _packetFlag._deviceKey_len_offset =1;
    _packetFlag._deviceKey_len_len = 2;
    
    _packetFlag._deviceKey_str_offset =3;
    _packetFlag._deviceKey_str_len =16;
    
    _packetFlag._port_offset =19;
    _packetFlag._port_len = 2;
    
    _packetFlag._reserved_offset = 21;
    _packetFlag._reserved_len = 1;
    
    _packetFlag._keepLive_offset = 22;
    _packetFlag._keepLive_len =2;
    
}
/*
 *@discussion
 *  协议的初始化方法
 */
-(id)init{
    self = [super init];
    if (self) {
        
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
        
    }
    return self;
}
/*
 *@discussion
 *  获得协议的字节
 */
-(NSMutableData *)getPacketData{
    return _packetData;
}
/*
 *@discussion
 *  获得包的大小
 */
-(int)getPacketSize{
    return PACKETSIZE;
}
#pragma mark
#pragma mark init方法
/*
 *@discussion
 *  包的初始化
 */
-(id)initWithVersion:(int)version andDeviceKeyLen:(int)length andKeyStrData:(NSData *)strData andPort:(int)port andReserved:(int)reserved andAliveTime:(int)aliveTime{
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
        
        char v = version;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&v length:_packetFlag._version_len];
            
        unsigned short len = length;
        len = htons(len);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._deviceKey_len_offset, _packetFlag._deviceKey_len_len) withBytes:&len length:_packetFlag._deviceKey_len_len];
            
            
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._deviceKey_str_offset, _packetFlag._deviceKey_str_len) withBytes:strData.bytes length:_packetFlag._deviceKey_str_len];
            
        unsigned short pt= port;
        pt = htons(pt);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&pt length:_packetFlag._port_len];
            
        char rs= reserved;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&rs length:_packetFlag._reserved_len];
            
        unsigned short alt = aliveTime;
        
        alt= htons(alt);
    
        NSLog(@"%02x",alt);
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._keepLive_offset, _packetFlag._keepLive_len) withBytes:&alt length:_packetFlag._keepLive_len];
        
    }
    return self;
}
-(id)initWithData:(NSData *)data{
    if (self = [super init]) {
        
        if (data.length != PACKETSIZE) {
            return nil;
        }
        
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithData:data];
        
    }
    return self;
}
#pragma mark
#pragma mark  get方法
/*
 *@discussion
 *  获得协议的版本
 */
-(int)getVersion{
    if (_packetData.length != PACKETSIZE) {
        return 0;
    }
    char temp = 0;
    
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len)];
    
    return temp;
    
}
/*
 *@discussion
 *  获得设备Key长度
 */
-(int)getDeviceKeyLength{
    if (_packetData.length != PACKETSIZE) {
       return 0;
    }
    unsigned short temp = 0;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._deviceKey_len_offset, _packetFlag._deviceKey_len_len)];
    
    temp = ntohs(temp);
    return temp;
    
}
/*
 *@discussion
 *  获得设备的key 字节
 */
-(NSData *)getDeviceKeyStr{
    if (_packetData.length != PACKETSIZE) {
        return nil;
    }
    
    NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._deviceKey_str_offset, _packetFlag._deviceKey_str_len)];
    return temp;
    
}
/*
 *@discussion
 *  获得app监听的端口号
 */
-(int)getPort{
    
    if (_packetData.length != PACKETSIZE) {
        return 0;
    }
    unsigned short temp=0;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len)];
    temp = ntohs(temp);
    return temp;
}
/*
 *@discussion
 *  获得协议保留字节的值
 */
-(int)getReserved{
    if (_packetData.length != PACKETSIZE) {
        return 0;
    }
    char temp = 0;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len)];
    
    return temp;
}
/*
 *@discussion
 *  获得协议app端的服务器存活时间间隔
 */
-(int)getKeepAliveTime{
    if (_packetData.length != PACKETSIZE) {
        return 0;
    }
    unsigned short temp = 0;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._keepLive_offset, _packetFlag._keepLive_len)];
    temp = ntohs(temp);
    
    return temp;
}
#pragma mark
#pragma mark set方法
/*
 *@discussion
 *  设置协议版本
 */
-(void)setVersion:(int)version{
    if (_packetData.length != PACKETSIZE) {
        return;
    }
    char temp = version;
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&temp length:1];
    
}
/*
 *@discussion
 *  设置设备key长度
 */
-(void)setDeviceKeyLength:(int)keyLen{
    if (_packetData.length != PACKETSIZE) {
        return;
    }
    unsigned short temp = htons(keyLen);
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._deviceKey_len_offset, _packetFlag._deviceKey_len_len) withBytes:&temp length:2];
    
}
/*
 *@discussion
 *  设置设备的key 字节
 */
-(void)setDeviceKeyStr:(NSData *)strData{
    if (_packetData.length != PACKETSIZE) {
        return;
    }
    if (strData.length) {
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._deviceKey_str_offset, _packetFlag._deviceKey_str_len) withBytes:strData.bytes length:strData.length];
    }
    
}

/*
 *@discussion
 *  设置app监听端口号
 */
-(void)setPort:(int)port{
    if (_packetData.length != PACKETSIZE) {
        return;
    }
    
    unsigned short temp = port;
    temp = htons(temp);
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&temp length:_packetFlag._port_len];
    
}
/*
 *@discussion
 *  设置保留
 */
-(void)setReserved:(int)reserved{
    if (_packetData.length != PACKETSIZE) {
        return;
    }
    
    char temp=reserved;
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&temp length:1];
}
/*
 *@discussion
 *  设置app的服务器存活时间
 */
-(void)setKeepAliveTime:(int)aliveInterval{
    if (_packetData.length != PACKETSIZE) {
        return;
    }
    unsigned short temp = aliveInterval;
    temp = htons(temp);
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._keepLive_offset, _packetFlag._keepLive_len) withBytes:&temp length:2];
    
}
/*
 *@discussion
 *  返回协议描述字符串
 */
-(NSString *)description{
    
    if (_packetData.length ==PACKETSIZE) {
        char temp[PACKETSIZE];
        [_packetData getBytes:temp range:NSMakeRange(0, PACKETSIZE)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for (int i = 0; i< PACKETSIZE; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
    }
    return nil;
    
}
@end
