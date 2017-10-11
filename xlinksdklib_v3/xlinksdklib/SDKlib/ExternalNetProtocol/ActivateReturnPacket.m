//
//  ActivateReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ActivateReturnPacket.h"

#define PACKETSIZE_ACTIVATE_RETURN 39

@implementation ActivateReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
    struct {
        unsigned short code_offset:8;
        unsigned short code_len:8;
        
        unsigned short deviceId_offset:8;
        unsigned short deviceId_len:8;
        
        unsigned short authorizedLen_offset:8;
        unsigned short authorizedLen_len:8;
        
        unsigned short authorizedStr_offset:8;
        unsigned short authorizedStr_len:8;
        
    }_packetFlag;
    
    
    
}

-(void)initProtocolLayout{
    
    _packetFlag.code_offset = 0;
    _packetFlag.code_len = 1;
    
    _packetFlag.deviceId_offset =1;
    _packetFlag.deviceId_len =4;
    
    _packetFlag.authorizedLen_offset = 5;
    _packetFlag.authorizedLen_len =2;
    
    _packetFlag.authorizedStr_offset = 7;
    _packetFlag.authorizedStr_len = 32;
    
    _packetSize = PACKETSIZE_ACTIVATE_RETURN;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_ACTIVATE_RETURN);
}

-(id)initWithData:(NSData *)data{
    
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        if (data.length == _packetSize) {
            [_packetData replaceBytesInRange:NSMakeRange(0, _packetSize) withBytes:data.bytes length:_packetSize];
        }else{
            return nil;
        }
        
    }
    return self;
    
}

-(int)getCode{
    
    if (_packetData.length == _packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
        return temp;
    }
    
    return -1;
}

-(int)getDeviceId{
    if (_packetData.length ==_packetSize) {
        int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.deviceId_offset, _packetFlag.deviceId_len)];
        return ntohl(temp);
    }
    return -1;
}

-(int)getAuthorizeLen{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.authorizedLen_offset, _packetFlag.authorizedLen_len)];
        return ntohs(temp);
    }
    
    return -1;
}

-(NSData *)getAuthorizeData{
    if (_packetData.length == _packetSize) {
        
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag.authorizedStr_offset, _packetFlag.authorizedStr_len)];
        return temp;
    }

    return nil;
}

-(NSString *)description{
    
    if (_packetData.length == _packetSize) {
        char temp[_packetSize];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        NSMutableString *str = [[NSMutableString alloc]init];
        
        for (int i =0; i<_packetSize; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
    }
    return nil;
    
}

@end
