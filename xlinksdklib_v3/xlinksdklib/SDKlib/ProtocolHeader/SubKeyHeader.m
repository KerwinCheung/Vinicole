//
//  SubKeyHeader.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/18.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "SubKeyHeader.h"

#define PACKETSIZE 20

@implementation SubKeyHeader

-(id)initWithVersion:(uint8_t)version withMessageID:(uint16_t)messageID withAccessKeyMD5:(NSData *)md5 withFlag:(int8_t)flag{
    if (self = [super init]) {
        _version = version;
        _msgID = messageID;
        _accessKeyData = md5;
        _flag = flag;
        
    }
    return self;
}

-(NSData *)getPacketData{
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&_version length:1];
    
    uint16_t msgID = htons(_msgID);
    [data appendBytes:&msgID length:2];
    
    [data appendData:_accessKeyData];
    
    [data appendBytes:&_flag length:1];
    
    return [NSData dataWithData:data];
}

@end
