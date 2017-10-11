//
//  SetResponsePacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "SetResponsePacket.h"

#define PACKETSIZE  3

/*
 *@discussion
 *  设置返回包
 */
@implementation SetResponsePacket{
    
    NSMutableData *_packetData;
    
    struct{
        
        unsigned int _messageId_offset:8;
        unsigned int _messageId_len:8;
        
        unsigned int _setState_offset:8;
        unsigned int _setState_len:8;
    
    }_packetFlag;
    
}
/*
 *@discussion
 *  协议字节布局设置
 */
-(void)initProtocolLayout{
    
    _packetFlag._messageId_offset = 0;
    _packetFlag._messageId_len = 2;
    
    _packetFlag._setState_offset =2;
    _packetFlag._setState_len =1;
    
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
 *  初始化函数
 */
-(instancetype)init{
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
 *  获得消息ID
 */
-(int)getMessageID{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._messageId_offset, _packetFlag._messageId_len)];
        return ntohs(temp);
    }
    return -1;
}

/*
 *@discussion
 *  获得设置的状态来判断是否设置成功
 */

-(int)getState{
    if (_packetData.length == PACKETSIZE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._setState_offset, _packetFlag._setState_len)];
    }
    
    return -1;
}
@end
