//
//  PingPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "PingPacket.h"

#define PACKETSIZE  2

@implementation PingPacket{
    
    NSData *_packetData;
    
    struct {
        unsigned int _sessionId_offset:8;
        unsigned int _seesionId_len:8;
    }packetFlag;
    
}


-(id)initWithSessionID:(int)asession{
    self = [super init];
    if (self) {
        unsigned short tmp = asession;
        tmp = htons(tmp);
        _packetData = [[NSData alloc]initWithBytes:&tmp length:2];
    }
    return self;
}

-(int)getPacketSize{
    return PACKETSIZE;
}

-(NSData *)getPacketData{
    return _packetData;
}

@end
