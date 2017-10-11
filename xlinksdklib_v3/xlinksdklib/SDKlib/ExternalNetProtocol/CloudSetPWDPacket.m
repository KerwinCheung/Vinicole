//
//  CloudSetPWDPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "CloudSetPWDPacket.h"

#define PacketSize 39

@implementation CloudSetPWDPacket
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
        
        unsigned short  oldAuth_offset:8;
        unsigned short  oldAuth_len:8;
        
        unsigned short newAuth_offset:8;
        unsigned short  newAuth_len:8;
        
    }_packetFlag;
}

-(void)initProtocolLayout{
    _packetFlag.deviceID_offset = 0;
    _packetFlag.deviceID_len =4;
    
    _packetFlag.messageID_offset = 4;
    _packetFlag.messageID_len = 2;
    
    _packetFlag.flag_offset = 6;
    _packetFlag.flag_len =1;
    
    _packetFlag.oldAuth_offset =7;
    _packetFlag.oldAuth_len = 16;
    
    _packetFlag.newAuth_offset =23;
    _packetFlag.newAuth_len =16;
    
    _packetSize = 39;
}


-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
    }
    return self;
}


-(id)initWithDeviceID:(int)deviceID andMessageID:(int)messageID andFlag:(int)flag andOldAuth:(NSData *)oldAuth andNewAuth:(NSData *)newAuth{

    self = [super init];
    if (self) {
        
        
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        
        unsigned int tmpDeviceID = deviceID;
        tmpDeviceID = htonl(tmpDeviceID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&tmpDeviceID length:_packetFlag.deviceID_len];
        
        unsigned short mesgID = messageID;
        mesgID = htons(mesgID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&mesgID length:_packetFlag.messageID_len];
        
        unsigned char tempFlag= flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&tempFlag length:_packetFlag.flag_len];
        
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.oldAuth_offset, _packetFlag.oldAuth_len) withBytes:oldAuth.bytes length:_packetFlag.oldAuth_len];
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.newAuth_offset, _packetFlag.newAuth_len) withBytes:newAuth.bytes length:_packetFlag.newAuth_len];
        
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
    return PacketSize;
}



@end
