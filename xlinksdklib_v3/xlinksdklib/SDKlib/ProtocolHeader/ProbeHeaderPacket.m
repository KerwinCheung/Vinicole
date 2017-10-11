//
//  ProbeHeaderPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "ProbeHeaderPacket.h"
/*
 *@discussion
 * 探测包头
 */

#define PACKETSIZE  3

@implementation ProbeHeaderPacket{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned int _sessionId_offset:8;
        unsigned int _sessionId_len:8;
        
        unsigned int _flag_offset:8;
        unsigned int _flag_len:8;
        
    }_packetFlag;
    
}
/*
 *@discussion
 * 得到包的大小
 */
-(int)getPacketSize{
    return PACKETSIZE;
}
/*
 *@discussion
 * 初始化协议的字节布局
 */
-(void)initProtocolLayout{
    
    _packetFlag._sessionId_offset =0;
    _packetFlag._sessionId_len =2;
    
    _packetFlag._flag_offset =2;
    _packetFlag._flag_len =1;
    
}
/*
 *@discussion
 *  初始化函数
 */
-(instancetype)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData  = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
    }
    return self;
}
/*
 *@discussion
 * 初始化函数
 */
-(id)initWithSession:(int)aSesssion andFlag:(int)aFlag{
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetData  = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
        
        unsigned short sesion = aSesssion;
        sesion = htons(sesion);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._sessionId_offset, _packetFlag._sessionId_len) withBytes:&sesion length:_packetFlag._sessionId_len];
        
        char flag = aFlag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&flag length:_packetFlag._flag_len];
        
    }
    return self;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}
/*
 *@discussion
 * 设置会话ID
 */
-(void)setSession:(int)aSesion{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp = aSesion;
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._sessionId_offset, _packetFlag._sessionId_len) withBytes:&temp length:_packetFlag._sessionId_len];
    }
}
/*
 *@discussion
 * 设置协议标示
 */
-(void)setFlag:(int)aflag{
    if (_packetData.length == PACKETSIZE) {
        char temp = aflag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&temp length:_packetFlag._flag_len];
    }
}

@end
