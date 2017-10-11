//
//  ExtFixHeader.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ExtFixHeader.h"
#import "ExtHeader.h"
#import "PipePacket.h"


#define PACKET_SIZE_EXTFIX 5

@implementation ExtFixHeader
{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned int _headInfo_offset:8;
        unsigned int _headInfo_len:8;
        
        unsigned int _dataLen_offset:8;
        unsigned int _dataLen_len:8;
    }packetFlag;
    
}
+(ExtFixHeader *)loginExtFixHeader{
    ExtFixHeader *login = [[ExtFixHeader alloc]init];
    [login setFixInfo:LOGIN_REQ_MESSAGE];
    [login setDataLength:26];
    return login;
}

+(ExtFixHeader *)pipeExtFixHeader{
    
    ExtFixHeader *pipe = [[ExtFixHeader alloc]init];
    [pipe setFixInfo:PIPE_REQ_MESSAGE];
    [pipe setDataLength:(int)[PipePacket getPacketSize]];
    return pipe;
    
}

+(ExtFixHeader *)activateExtFixHeader{
    ExtFixHeader *activate = [[ExtFixHeader alloc]init];
    [activate setFixInfo:ACTIVATE_REQ_MESSAGE];
    [activate setDataLength:sizeof(ACTIVATE_HEADER)];
    return activate;
}

+(ExtFixHeader *)connectExtFixHeader{
    ExtFixHeader *connect = [[ExtFixHeader alloc]init];
    [connect setFixInfo:CONNECT_REQ_MESSAGE];
    [connect setDataLength:sizeof(CONNECT_HEADER)];
    return connect;
}

+(ExtFixHeader *)setExtFixHeader{
    ExtFixHeader *set = [[ExtFixHeader alloc]init];
    [set setFixInfo:SET_REQ_MESSAGE];
    [set setDataLength:sizeof(SET_HEADER)];
    return set;
}

+(ExtFixHeader *)syncExtFixHeader{
    ExtFixHeader *sync = [[ExtFixHeader alloc]init];
    [sync setFixInfo:SYNC_REQ_MESSAGE];
    [sync setDataLength:sizeof(SYNC_HEADER)];
    return sync;
}

+(ExtFixHeader *)subscriptionExtFixHeaderWithVersion:(uint8_t)version{
    ExtFixHeader *sub = [[ExtFixHeader alloc]init];
    
    unsigned char info = SUBSCRIPTION_REQ_MESSAGE;
    
    if (version >= 3) {
        info |= version;
    }
    
    [sub setFixInfo:info];
    [sub setDataLength:41];
    
    return sub;
}

+(ExtFixHeader *)pingExtFixHeader{
    
    //13*16
    ExtFixHeader *ping = [[ExtFixHeader alloc]init];
    
    unsigned char info = PING_REQ_MESSAGE;
    [ping setFixInfo:info];
    [ping setDataLength:0];
    return ping;

}

+(ExtFixHeader *)pipeResponseHeader{
    ExtFixHeader *temp = [[ExtFixHeader alloc]init];
    [temp setFixInfo:PIPE_RSP_MESSAGE];
    [temp setDataLength:7];
    return temp;
}

+(ExtFixHeader *)probeHeader{
    ExtFixHeader *temp = [[ExtFixHeader alloc]init];
    [temp setFixInfo:PROBE_REQ_MESSAGE];
    [temp setDataLength:0];
    return temp;

}

+(ExtFixHeader *)CloudSetAuthHeader{
    ExtFixHeader *temp = [[ExtFixHeader alloc]init];
    [temp setFixInfo:CLOUDSETPWD_REQ_MESSAGE];
    [temp setDataLength:0];
    return temp;
}

+(ExtFixHeader *)disconnectHeader{
    ExtFixHeader *temp = [[ExtFixHeader alloc]init];
    [temp setFixInfo:DISCONNECT_REQ_MESSAGE];
    [temp setDataLength:1];
    return temp;
}

+(ExtFixHeader *)dataPointHeader{
    ExtFixHeader *temp = [[ExtFixHeader alloc]init];
    [temp setFixInfo:SET_REQ_MESSAGE];
    [temp setDataLength:0];
    return temp;
}

+(int)getPacketSize{
    return (PACKET_SIZE_EXTFIX);
}

-(int)getPacketSize{
    return (int)_packetData.length;
}

-(NSMutableData *)getPacketData{
    
    return _packetData;
    
}

-(id)initWithFixHeader:(NSData *)data{
    if (!data) {
        return nil;
    }
    
    if (data.length != 5) {
        return nil;
    }
    
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetData =[[NSMutableData alloc]initWithCapacity:5];
        [_packetData resetBytesInRange:NSMakeRange(0, sizeof(FIX_EXT_HEADER))];
        [_packetData appendData:data];
        
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        _packetData = [[NSMutableData alloc]initWithCapacity:5];
        [_packetData resetBytesInRange:NSMakeRange(0, sizeof(FIX_EXT_HEADER))];
        [self initProtocolLayout];
    }
    return self;
}

-(void)initProtocolLayout{
    packetFlag._headInfo_offset = 0;
    packetFlag._headInfo_len =1;
    
    packetFlag._dataLen_offset =1;
    packetFlag._dataLen_len=4;
}

-(void)setFixInfo:(int)info{
    if (_packetData.length ==5) {
        [_packetData replaceBytesInRange:NSMakeRange(packetFlag._headInfo_offset, packetFlag._headInfo_len) withBytes:&info length:1];
    }
}

-(int)getFixInfo{
    
    char temp;
    if (_packetData.length ==5) {
        [_packetData getBytes:&temp range:NSMakeRange(packetFlag._headInfo_offset, packetFlag._headInfo_len)];
        return temp;
    }
    
    return 0;
}

-(void)setDataLength:(int)len{
    
    int temp = htonl(len);
    
    [_packetData replaceBytesInRange:NSMakeRange(packetFlag._dataLen_offset, packetFlag._dataLen_len) withBytes:&temp length:4];
    
    
}

-(int)getDataLength{
    if (_packetData.length ==5) {
        int temp;
        [_packetData getBytes:&temp range:NSMakeRange(packetFlag._dataLen_offset, packetFlag._dataLen_len)];
        return ntohl(temp);
    }
    
    return 0;
}

-(NSString *)description{
    if (_packetData.length == 5) {
        char temp[5];
        [_packetData getBytes:temp range:NSMakeRange(0, 5)];
        
        NSMutableString *str =[[NSMutableString alloc]init];
        for (int i=0; i<5; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i] ];
        }
        return str;
    }
    return nil;
}
@end
