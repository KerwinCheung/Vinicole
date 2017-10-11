//
//  SetHeaderPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "SetHeaderPacket.h"
#import "SDKHeader.h"

#define PACKETSIZE 5


/*
 *@discussion
 *  设置的协议头
 */
@implementation SetHeaderPacket{
    
    NSMutableData *_packetData;
    
    struct {
        
        unsigned int _sessionId_offset:8;
        unsigned int _sessionId_len:8;
        
        unsigned int _messageId_offset:8;
        unsigned int _messageId_len:8;
        
        unsigned int _flag_offset:8;
        unsigned int _flag_len:8;
        
    }_packetFlag;
    
}
/*
 *@discussion
 *  协议字节布局
 */
-(void)initProtocolLayout{
    
    _packetFlag._sessionId_offset =0;
    _packetFlag._sessionId_len = 2;
    
    _packetFlag._messageId_offset =2;
    _packetFlag._messageId_len =2;
    
    _packetFlag._flag_offset = 4;
    _packetFlag._flag_len =1;
    
}
/*
 *@discussion
 *  初始化函数
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
 *  初始化函数
 */
-(id)initWithSessionID:(int)aSession andMessageID:(int)aMessage andFlag:(int)flag{
    if (self = [super init]) {
        
        [self initProtocolLayout];
        
        _packetData = [NSMutableData dataWithLength:PACKETSIZE];
        
        unsigned short session = aSession;
        session = htons(session);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._sessionId_offset, _packetFlag._sessionId_len) withBytes:&session length:_packetFlag._sessionId_len];
        
        unsigned short message =aMessage;
        message = htons(message);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageId_offset, _packetFlag._messageId_len) withBytes:&message length:_packetFlag._messageId_len];
        
        char fg = flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&fg length:_packetFlag._flag_len];
        
    }
    return self;
}
/*
 *@discussion
 *  获得包的bytes
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
/*
 *@discussion
 *  设置对话ID
 */
-(void)setSessionID:(int)aSession{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp = aSession;
        temp  = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._sessionId_offset, _packetFlag._sessionId_len) withBytes:&temp length:_packetFlag._sessionId_len];
    }
}
/*
 *@discussion
 *  设置消息ID
 */
-(void)setMessageID:(int)aMessage{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp = aMessage;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageId_offset, _packetFlag._messageId_len) withBytes:&temp length:_packetFlag._messageId_len];
    }
}
/*
 *@discussion
 *  设置datapoint生效标示
 */
-(void)setFlag:(int)aFlag{
    if (_packetData.length == PACKETSIZE) {
        char temp = aFlag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&temp length:_packetFlag._flag_len];
    }
}

@end
