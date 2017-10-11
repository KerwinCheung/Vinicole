//
//  HandShakeReturn.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "HandShakeReturn.h"
#import "SDKHeader.h"

#define PACKETSIZE 16

/*
 *@discussion
 *  握手返回包
 */

@implementation HandShakeReturn{
    
    NSMutableData *_packetData;
    
    struct {
        
        unsigned int _version_offset:8;
        unsigned int _version_len:8;
        
        unsigned int _macaddress_offset:8;
        unsigned int _macaddress_len:8;
        
        unsigned int _deviceId_offset:8;
        unsigned int _deviceId_len:8;
        
        unsigned int _mcu_soft_version_offset:8;
        unsigned int _mcu_soft_version_len:8;
        
        unsigned int _sessionId_offset:8;
        unsigned int _sessionId_len:8;
        
        unsigned int _handshakeKey_offset:8;
        unsigned int _handshakeKey_len:8;
        
    }_packetFlag;
}

/*
 *@discussion
 *  协议的字节布局
 */
-(void)initProtocolLayout{
    
    _packetFlag._version_offset = 0;
    _packetFlag._version_len=1;
    
    _packetFlag._macaddress_offset = 1;
    _packetFlag._macaddress_len = 6;
    
    _packetFlag._deviceId_offset = 7;
    _packetFlag._deviceId_len =4;
    
    _packetFlag._mcu_soft_version_offset = 11;
    _packetFlag._mcu_soft_version_len = 2;
    
    _packetFlag._sessionId_offset = 13;
    _packetFlag._sessionId_len = 2;
    
    _packetFlag._handshakeKey_offset =15;
    _packetFlag._handshakeKey_len = 1;
    
}

/*
 *@discussion
 *  初始化变量
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
 *  握手协议返回包
 */
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
/*
 *@discussion
 *  得到协议bytes
 */
-(NSMutableData *)getPacketData{
    return _packetData;
}
/*
 *@discussion
 *  得到包的大小
 */
+(int)getPacketSize{
    return PACKETSIZE;
}
/*
 *@discussion
 *  设置包的byte
 */
-(void)setPacketData:(NSData *)data{
    if (data.length == PACKETSIZE) {
        [_packetData replaceBytesInRange:NSMakeRange(0, PACKETSIZE) withBytes:data.bytes length:PACKETSIZE];
    }
}

/*
 *@discussion
 *  获得协议的版本号
 */
-(int)getVersion{
    if (_packetData.length == PACKETSIZE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len)];
        return temp;
    }
    
    return -1;
}
/*
 *@discussion
 *  获得Mac地址
 */
-(NSData *)getMacAddress{
    if (_packetData.length == PACKETSIZE) {
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._macaddress_offset, _packetFlag._macaddress_len)];
        return temp;
        
    }
    return nil;
}
/*
 *@discussion
 *  获得设备ID
 */
-(int)getDeviceID{
    if (_packetData.length == PACKETSIZE) {
        int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._deviceId_offset, _packetFlag._deviceId_len)];
        return ntohl(temp);
    }
    return -1;
}
/*
 *@disucssion
 *  获得MCU软件版本号
 */
-(int)getMCUSoftVersion{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._mcu_soft_version_offset, _packetFlag._mcu_soft_version_len)];
        return ntohs(temp);
    }
    return -1;
}
/*
 *@discussion
 *  获得对话ID
 */
-(int)getSessionID{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp ;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._sessionId_offset, _packetFlag._sessionId_len)];
        return ntohs(temp);
    }
    return -1;
}


/*
 *@discussion
 *  获得协议的握手参数
 */

-(int)getHandShakeKey{
    if (_packetData.length == PACKETSIZE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._handshakeKey_offset, _packetFlag._handshakeKey_len)];
        return temp ;
    }
    return -1;
}


/*
 *@discussion
 *  获得包的描述信息
 */
-(NSString *)description{
    if (_packetData.length == PACKETSIZE) {
        char temp[PACKETSIZE];
        [_packetData getBytes:temp range:NSMakeRange(0, PACKETSIZE)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for (int i = 0; i< PACKETSIZE; i++) {
            [str appendFormat:@"#%d=%02x", i, temp[i]];
        }
        return str;
    }
    return nil;
}

@end
