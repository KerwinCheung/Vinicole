//
//  ScanHeader.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "ScanHeader.h"
#import "SDKHeader.h"

#define PACKETSIZE  4

/*
 *扫描协议头
 */

@implementation ScanHeader{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned int _version_offset:8;
        unsigned int _version_len:8;
        
        unsigned int _port_offset:8;
        unsigned int _port_len:8;
        
        unsigned int _reserved_offset:8;
        unsigned int _reserved_len:8;
        
        
    }_packetFlag;
    
}
/*
 *@discussion
 * 协议头字节布局
 */
-(void)initProtocolLayout{
    
    _packetFlag._version_offset = 0;
    _packetFlag._version_len = 1;
    
    _packetFlag._port_offset = 1;
    _packetFlag._port_len = 2;
    
    _packetFlag._reserved_offset = 3;
    _packetFlag._reserved_len = 1;
    
}

/*
 *@discussion
 *   协议的初始化函数
 */
-(instancetype)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithLength:PACKETSIZE];
    }
    return self;
    
}
/*
 *@discussion
 *   协议的初始化函数
 */
-(id)initWithVersion:(int)aVersion andPort:(int)aPort andMacAddress:(NSData *)mac{
    self = [self init];
    if (self) {
        
        char verion = aVersion;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&verion length:_packetFlag._version_len];
        
        unsigned short port = aPort;
        port = htons(port);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&port length:_packetFlag._port_len];
        
        ScanMode resed = ScanModeByMacAddress;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&resed length:_packetFlag._reserved_len];
        
        [_packetData appendData:mac];
        
    }
    return self;
}

-(id)initWithVersion:(int)aVersion andPort:(int)aPort andProductID:(NSString *)productID{
    self = [self init];
    if (self) {
        
        char verion = aVersion;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&verion length:_packetFlag._version_len];
        
        unsigned short port = aPort;
        port = htons(port);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&port length:_packetFlag._port_len];
        
        ScanMode resed = ScanModeByProductiD;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&resed length:_packetFlag._reserved_len];
        
        [_packetData appendData:[productID dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    return self;
}

-(ScanMode)getScanMode{
    
    ScanMode scanMode;
    [_packetData getBytes:&scanMode range:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len)];
    return scanMode;
    
}

/*
 *@discussion
 *  得到协议的bytes
 */
-(NSMutableData *)getPacketData{
    return _packetData;
}
/*
 *@discussion
 *  得到协议的包大小
 */
-(int)getPacketSize{
    if ([self getScanMode] == ScanModeByMacAddress) {
        return PACKETSIZE + 6;
    }else{
        return PACKETSIZE + 32;
    }
}
/*
 *@discussion
 *  设置协议版本
 */
-(void)setVersion:(int)aVersion{
    if (_packetData.length == PACKETSIZE) {
        char v= aVersion;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&v length:_packetFlag._version_len];
    }
}
/*
 *@discussion
 *  得到监听的端口
 */
-(void)setPort:(int)aPort{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp = aPort;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._port_offset, _packetFlag._port_len) withBytes:&temp length:_packetFlag._port_len];
    }
}
/*
 *@discussion
 *  得到协议的保留标示
 */
-(void)setReserved:(ScanMode)aReserved{
    [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&aReserved length:_packetFlag._reserved_len];
}

/*
 *@discussion
 *  得到协议的包描述
 */
-(NSString *)description{
    if (_packetData.length == PACKETSIZE) {
        
        char temp[PACKETSIZE];
        [_packetData getBytes:temp range:NSMakeRange(0, PACKETSIZE)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for ( int i = 0; i < PACKETSIZE; i++) {
            [str appendFormat:@"#%d = %02x",i,temp[i]];
        }
        return str;
        
    }
    return nil;
    
}

@end
