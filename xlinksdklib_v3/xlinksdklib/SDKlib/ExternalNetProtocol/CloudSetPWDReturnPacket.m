//
//  CloudSetPWDReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "CloudSetPWDReturnPacket.h"

#define PacketSize 7

@implementation CloudSetPWDReturnPacket
{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short appID_offset:8;
        unsigned short appID_len:8;
        
        unsigned short mesageID_offset:8;
        unsigned short mesageID_len:8;
        
        unsigned short code_offset:8;
        unsigned short code_len:8;
        
    }_packetFlag;
}
-(void)initProtocolLayout{
    _packetFlag.appID_len = 0;
    _packetFlag.appID_len =4;
    
    _packetFlag.mesageID_offset =4;
    _packetFlag.mesageID_len = 2;
    
    _packetFlag.code_offset =6;
    _packetFlag.code_len = 1;
    
    _packetSize = 7;
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


-(int)getCode{
    if (_packetData.length==_packetSize) {
        
        unsigned char temp ;
        
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
        return temp;
        
    }return -1;
}

-(int)getMessageID{
    if (_packetData.length==_packetSize) {
        
        unsigned short temp ;
        
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.mesageID_offset, _packetFlag.mesageID_len)];
        return ntohs(temp);
        
    }return -1;
}

-(int)getAppID{
    if (_packetData.length==_packetSize) {
        
        unsigned int temp ;
        
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.appID_offset, _packetFlag.appID_len)];
        return ntohl(temp);
        
    }return -1;
}

@end
