//
//  ShakeHandWithPSWDPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ShakeHandWithPSWDPacket.h"

@implementation ShakeHandWithPSWDPacket

-(id)initWithVersion:(int)version andMessageID:(int16_t)messageID andAuthKey:(NSData *)auth andListenPort:(int)port andFlag:(int)flag andKeepAlive:(int)aliveTime{
    self = [super init];
    if (self) {
        
        _version = version;
        _messageID = messageID;
        _accessKeyMD5 = auth;
        _port = port;
        _flag = flag;
        _keepAliveTime = aliveTime;
        
    }
    return self;
}

-(NSMutableData *)getPacketData{
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&_version length:1];
    
    if (_version >= 3) {
        int16_t messageID = htons(_messageID);
        [data appendBytes:&messageID length:2];
    }
    
    [data appendData:_accessKeyMD5];
    
    uint16_t port = htons(_port);
    [data appendBytes:&port length:2];
    
    [data appendBytes:&_flag length:1];
    
    uint16_t keepAliveTime = _keepAliveTime;
    [data appendBytes:&keepAliveTime length:2];
    
    return data;
}

@end
