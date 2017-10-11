//
//  ConnectReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ConnectReturnPacket.h"

#define PACKETSIZE_CONNECT_RETURN 2

@implementation ConnectReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
    struct {
        unsigned short code_offset:8;
        unsigned short code_len:8;
        
        unsigned short reserved_offset:8;
        unsigned short reserved_len:8;
    
    }_packetFlag;
}

-(NSMutableData *)getPacketData{
   return  _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize
{
    return (PACKETSIZE_CONNECT_RETURN);
}

-(void)initProtocolLayout{
    _packetFlag.code_offset =0;
    _packetFlag.code_len = 1;
    
    _packetFlag.reserved_offset =1;
    _packetFlag.reserved_len =1;
}

-(id)initWithData:(NSData *)data{
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetSize =PACKETSIZE_CONNECT_RETURN;
        
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        if (data.length ==_packetSize) {
            [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
        }
    }
    return self;
}
-(int)getCode{
    if (_packetData.length ==_packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
        return temp;
    }
    return -1;
}
-(int)getReserved{
    if (_packetData.length == _packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.reserved_offset, _packetFlag.reserved_len)];
        return temp;
    }
    return -1;
}

-(NSString *)description{
    if (_packetData.length == _packetSize) {
        char temp[_packetSize];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        NSMutableString *str =[[NSMutableString alloc]init];
        for (int i=0; i<_packetSize; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
    }
    return nil;
}
@end
