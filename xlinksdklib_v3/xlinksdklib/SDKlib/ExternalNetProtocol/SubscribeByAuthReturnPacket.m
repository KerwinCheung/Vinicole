//
//  SubscribeByAuthReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SubscribeByAuthReturnPacket.h"

@implementation SubscribeByAuthReturnPacket

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        
        [data getBytes:&_deviceID range:NSMakeRange(0, 4)];
        _deviceID = htonl(_deviceID);
        
        [data getBytes:&_msgID range:NSMakeRange(4, 2)];
//        _msgID = htons(_msgID);
        
        [data getBytes:&_code range:NSMakeRange(6, 1)];
        
    }
    return self;
}

@end
