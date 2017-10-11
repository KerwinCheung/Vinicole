//
//  FixHeader.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "FixHeader.h"
#import "SDKHeader.h"

// 包大小宏定义
#define PACKETSIZE 5

@implementation FixHeader{
    
    NSMutableData *_packetData;  //包的byte缓存
    
    struct {
        unsigned int _headInfo_offset:8;
        unsigned int _headInfo_len:8;
        
        unsigned int _dataLen_offset:8;
        unsigned int _dataLen_len:8;
    }packetFlag;                 //协议字节的布局
    
}

/*
 *该函数的主要作用是初始化协议的字节布局
 */
-(void)initProtocolLayout{
    //协议类型标示
    packetFlag._headInfo_offset = 0;
    packetFlag._headInfo_len =1;
    //协议的长度
    packetFlag._dataLen_offset =1;
    packetFlag._dataLen_len =4;
}
/*
 *@discussion
 *  初始化协议布局，包大小，缓存创建
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
 *  获得缓存byte
 */
-(NSMutableData *)getPacketData{
    return _packetData;
}
/*
 *@discussion
 *  获得包的大小
 */
+(int)getPacketSize{
    return PACKETSIZE;
}
/*
 *@discussion
 *  从网络接收到数据，截取指定固定包大小的字节初始化固定协议头，通过固定协议类型判断后面的数据类型，来指导后面字节的读取，会对传人的data的长度判读，如果长度不对就会创建失败
 */
-(id)initWithFixData:(NSData *)data{
    self = [super init];
    if (self) {
        
        if (data.length != PACKETSIZE) {
            return nil;
        }
        
        _packetData = [NSMutableData dataWithData:data];
        [self initProtocolLayout];
        
    }
    return self;
}
/*
 *@discussion
 *  通过infoFlag 和 len来初始化固定协议包
 */
-(id)initWithInfo:(int8_t)infoFlag andDataLen:(NSUInteger)len{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
        
        char inf= infoFlag;
        [_packetData replaceBytesInRange:NSMakeRange(packetFlag._headInfo_offset, packetFlag._headInfo_len) withBytes:&inf length:packetFlag._headInfo_len];
        
        int lth = htonl(len);
        [_packetData replaceBytesInRange:NSMakeRange(packetFlag._dataLen_offset, packetFlag._dataLen_len) withBytes:&lth length:packetFlag._dataLen_len];
            }
    return self;
}
/*
 *@discussion
 *  得到len
 */
-(int)getDataLength{
    if (!_packetData.length) {
        return 0;
    }
    
    int len;
    [_packetData getBytes:&len range:NSMakeRange(packetFlag._dataLen_offset, packetFlag._dataLen_len)];
    
    
    return ntohl(len);
}

/*
 *@discussion
 *  设置len
 */
-(void)setDataLength:(NSUInteger)len{
    if (!_packetData) {
        return;
    }
    
    if (!_packetData.length) {
        return;
    }
    
    len = htonl(len);
    
    [_packetData replaceBytesInRange:NSMakeRange(packetFlag._dataLen_offset, packetFlag._dataLen_len) withBytes:&len length:4];
    
}
/*
 *@discussion
 *  得到协议类型
 */
-(int)getMessageInfo{
    if (!_packetData) {
        return 0;
    }
    
    if (!_packetData.length) {
        return 0;
    }
    
    unsigned char info=0;
    
    
    [_packetData getBytes:&info range:NSMakeRange(packetFlag._headInfo_offset, packetFlag._headInfo_len)];
    
    return info;
}
/*
 *@discussion
 *  设置info
 */
-(void)setMessageInfo:(int)info{
    if (!_packetData) {
        return;
    }
    if (!_packetData.length) {
        return;
    }
    
    [_packetData replaceBytesInRange:NSMakeRange(packetFlag._headInfo_offset, packetFlag._headInfo_len) withBytes:&info length:1];
    
}

/*
 *@discussion
 *  返回描述字符串
 */

-(NSString *)description{
    if (_packetData.length == PACKETSIZE) {
        char temp[PACKETSIZE];
        [_packetData getBytes:temp range:NSMakeRange(0, PACKETSIZE)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for (int i = 0; i < PACKETSIZE; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
    }
    return nil;
    
    
}

#pragma mark
#pragma mark 类方法直接得到不同类型的固定协议头

/*
 *@discussion
 *得到扫描的固定协议头
 */
//+(FixHeader *)scanFixHeader{
//    
//    return [[FixHeader alloc] initWithInfo:SCAN_REQ_FLAG andDataLen:htonl([ScanHeader getPacketSize])];
//}
/*
 *@discussion
 *得到握手的固定协议头
 */
//+(FixHeader *)handShakeFixHeader{
//    
//    return [[FixHeader alloc] initWithInfo:HANDSHAKE_REQ_FLAG andDataLen:htonl([HandShakeHeader getPacketSize])];
//    
//}
/*
 *@discussion
 *得到设置的固定协议头
 */
//+(FixHeader *)setFixHeader{
//    
//    return [[FixHeader alloc] initWithInfo:SET_REQ_FLAG andDataLen:htonl([SetHeaderPacket getPacketSize])];
//    
//}
/*
 *@discussion
 *得到探测的固定协议头
 */
//+(FixHeader *)probeFixHeader{
//    
//    return [[FixHeader alloc] initWithInfo:PROBE_REQ_FLAG andDataLen:htonl([ProbeHeaderPacket getPacketSize])];
//    
//}
/*
 *@discussion
 *得到同步的固定协议头
 */
//+(FixHeader *)syncFixHeader{
//    
//    return [[FixHeader alloc] initWithInfo:SYNC_REQ_FLAG andDataLen:htonl([SyncHeaderPacket getPacketSize])];
//}
/*
 *@discussion
 *得到Ping的固定协议头
 */
//+(FixHeader *)pingFixHeader{
//    
//    return [[FixHeader alloc] initWithInfo:PING_REQ_FLAG andDataLen:htonl([PingPacket getPacketSize])];
//    
//}

//+(FixHeader *)ByeByeFixHeader{
//    
//    return [[FixHeader alloc]initWithInfo:BYBBYE_REQ_FLAG andDataLen:0];
//}

//+(FixHeader *)ticketFixHeader{
//    
//    return [[FixHeader alloc]initWithInfo:Ticket_REQ_FLAG andDataLen:[TicketPacketHeader getPacketSize]];
//    
//}

//+(FixHeader *)pipeFixHeader{
//    FixHeader *fix = [[FixHeader alloc]init];
//    [fix setMessageInfo:128];
//    [fix setDataLength:0];
//    return fix;
//}

//+(FixHeader *)setPWDFixHeader{
//    FixHeader *fix =[[FixHeader alloc]initWithInfo:SETPSW_REQ_FLAG andDataLen:0];
//    return fix;
//}

//+(FixHeader *)setBINDFixHeader {
//    FixHeader *fix =[[FixHeader alloc]initWithInfo:BIND_REQ_FLAG andDataLen:0];
//    return fix;
//}

//+(FixHeader *)appPipeDeviceFixHeader{
//    FixHeader *fix =[[FixHeader alloc]initWithInfo:Pipe_REQ_FLAG andDataLen:0];
//    return fix;
//}

//+(FixHeader *)devicePipeAppFixHeader{
//    FixHeader *fix;
//    return fix;
//}




@end
