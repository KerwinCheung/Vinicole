//
//  CloudSetAuthPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "CloudSetAuthPacket.h"

#define PacketSize 39

@implementation CloudSetAuthPacket
{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short deviceID_offset:8;
        unsigned short deviceID_len:8;
        
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short flag_offset:8;
        unsigned short flag_len:8;
        
        unsigned short oldAuth_offset:8;
        unsigned short oldAuth_len:8;
        
        unsigned short newAuth_offset:8;
        unsigned short newAuth_len:8;
        
        
        
    }_packetFlag;
    
}

-(void)initProtocolLayout{
    _packetFlag.deviceID_offset = 0;
    _packetFlag.deviceID_len = 4;
    
    _packetFlag.messageID_offset =4;
    _packetFlag.messageID_len = 2;
    
    _packetFlag.flag_offset =6;
    _packetFlag.flag_len =1;
    
    _packetFlag.oldAuth_offset = 7;
    _packetFlag.oldAuth_len = 16;
    
    _packetFlag.newAuth_offset = 23;
    _packetFlag.newAuth_len =16;
    
    _packetSize = 39;
}

-(id)initWithDeviceID:(int)deviceID andMessageID:(int)messageID andFlag:(int)flag andOldAuthKey:(NSData *)oldAuth andNewAuth:(NSData *)newAuth{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        unsigned int tempDeviceId= deviceID;
        tempDeviceId = htonl(tempDeviceId);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset,_packetFlag.deviceID_len) withBytes:&tempDeviceId length:_packetFlag.deviceID_len];
        
        unsigned short tempMessageID = messageID;
        tempMessageID = htons(tempMessageID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&tempMessageID length:_packetFlag.messageID_len];
        
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.oldAuth_offset, _packetFlag.oldAuth_len) withBytes:oldAuth.bytes length:_packetFlag.oldAuth_len];
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.newAuth_offset, _packetFlag.newAuth_len) withBytes:newAuth.bytes length:_packetFlag.newAuth_len];
        
        
    }
    return self;
}


+(int)getPacketSize{
    return PacketSize;
}

-(int)getPacketSize{
    return _packetSize;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}
@end
