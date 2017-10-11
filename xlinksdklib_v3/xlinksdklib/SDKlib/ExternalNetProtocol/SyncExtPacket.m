//
//  SyncExtPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SyncExtPacket.h"

#define PACKETSIZE_SYNEXT 7

@implementation SyncExtPacket{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short deviceID_offset:8;
        unsigned short deviceID_len:8;
        
        unsigned short mesageID_offset:8;
        unsigned short mesageID_len:8;
        
        unsigned short flag_offset:8;
        unsigned short flag_len:8;
        
    }_packetFlag;
}

-(void)initProtocolLayout{
    _packetFlag.deviceID_offset = 0;
    _packetFlag.deviceID_len =4;
    
    _packetFlag.mesageID_offset =4;
    _packetFlag.mesageID_len = 2;
    
    _packetFlag.flag_offset =6;
    _packetFlag.flag_len = 1;
    
    
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_SYNEXT);
}

-(id)initWithDeviceID:(int)deviceID andMessageID:(int)msgID andFlag:(int)flag{
    
    if (self = [super init]) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_SYNEXT;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        if (_packetData.length ==_packetSize) {
            int dceid = htonl(deviceID);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&dceid length:_packetFlag.deviceID_len];
            
            unsigned short mgId = msgID;
            mgId = htons(mgId);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.mesageID_offset, _packetFlag.mesageID_len) withBytes:&mgId length:_packetFlag.mesageID_len];
            
            char fg = flag;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&fg length:_packetFlag.flag_len];
            
        }
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_SYNEXT;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
    }
    return self;
}

-(void)setDeviceID:(int)deviceID{
    if (_packetData.length == _packetSize) {
        int temp = htonl(deviceID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&temp length:_packetFlag.deviceID_len];
    }
}
-(void)setMessageID:(int)messageID{
    if (_packetData.length == _packetSize) {
        unsigned short temp=messageID;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.mesageID_offset, _packetFlag.mesageID_len) withBytes:&temp length:_packetFlag.mesageID_len];
        
    }
}
-(void)setFlag:(int)flag{
    if (_packetData.length == _packetSize) {
        char temp = flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&temp length:_packetFlag.flag_len];
    }
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
