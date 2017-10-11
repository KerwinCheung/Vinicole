//
//  SyncExtReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SyncExtReturnPacket.h"

#define PACKETSIZE_SYNEXT_RERURN 3

@implementation SyncExtReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short code_offset:8;
        unsigned short code_len:8;
        
    }_packetFlag;
}

-(void)initProtocolLayout{
    _packetFlag.messageID_offset =0;
    _packetFlag.messageID_len =2;
    
    _packetFlag.code_offset = 2;
    _packetFlag.code_len =1;
}

-(id)initWithData:(NSData *)data{
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_SYNEXT_RERURN;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        if (_packetData.length == _packetSize) {
            if (data.length == _packetSize) {
                [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
            }else{
                return nil;
            }
        }
    }
    return self;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_SYNEXT_RERURN);
}

-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_SYNEXT_RERURN;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
    }
    return self;
}

-(void)setPacketData:(NSData *)data{
    if (data.length==_packetSize&&_packetData.length == _packetSize) {
        [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
    }
}

-(int)getMessageID{
    if (_packetData.length ==_packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len)];
        return ntohs(temp);
    }
    return -1;
}
-(int)getCode{
    if (_packetData.length ==_packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
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
