//
//  SyncHeaderPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "SyncHeaderPacket.h"

#define PACKETSIZE  7

/*
 *@discussion
 *  同步包头
 */
@implementation SyncHeaderPacket{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned int _macAddress_offset:8;
        unsigned int _macAddress_len:8;
        
        unsigned int _flag_offset:8;
        unsigned int _flag_len:8;
    }_packetFlag;
    
}
/*
 *@discussion
 *  同步包头字节的布局初始化
 */
-(void)initProtocolLayout{
    _packetFlag._macAddress_offset = 0;
    _packetFlag._macAddress_len = 6;
    
    _packetFlag._flag_offset = 6;
    _packetFlag._flag_len =1;
    
}
/*
 *@discussion
 *  获得包的大小
 */
+(int)getPacketSize{
    return PACKETSIZE;
}
-(int)getPacketSize{
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
-(id)initWithMacAddress:(NSData *)aData andFlag:(int)aflag{
    self = [super init];
    if (self) {
        
        if (aData.length != 6) {
            return nil;
        }
        
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithLength:PACKETSIZE];
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len) withBytes:aData.bytes length:_packetFlag._macAddress_len];
        
        char fg = aflag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&fg length:_packetFlag._flag_len];
        
    }
    return self;
}

-(id)initWithData:(NSData *)aData{
    self = [super init];
    if (self) {
        if (aData.length != PACKETSIZE) {
            return nil;
        }
        
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithData:aData];
        
    }
    
    return self;
}

/*
 *@discussion
 *  设置同步包的Mac 地址bytes
 */
-(void)setMacAddress:(NSData *)data{
    if (_packetData.length == PACKETSIZE) {
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len) withBytes:data.bytes length:_packetFlag._macAddress_len];
    }
}

/*
 *@discussion
 *  设置datapoint的有效标示
 */
-(void)setFlag:(int)flag{
    if (_packetData.length == PACKETSIZE) {
        char temp = flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&temp length:_packetFlag._flag_len];
    }
}
-(int)getFlag{
    
    if (_packetData.length != PACKETSIZE) {
        return -1;
    }
    
    char temp;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len)];
    return temp;
    
    
}

-(NSData *)getMacData{
    if (_packetData.length != PACKETSIZE) {
        return nil;
    }
    NSData *tempData = [_packetData subdataWithRange:NSMakeRange(0, 6)];
    return tempData;
}


-(NSMutableData *)getPacketData{
    
    return _packetData;
    
}

@end
