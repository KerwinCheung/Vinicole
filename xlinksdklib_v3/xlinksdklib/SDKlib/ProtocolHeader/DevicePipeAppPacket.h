//
//  DevicePipeAppPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/28.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DevicePipeAppPacket : NSObject

@property (strong, nonatomic) NSData    *mac;
@property (assign, nonatomic) uint8_t   msgID;
@property (assign, nonatomic) uint8_t   flag;
@property (strong, nonatomic) NSData    *payload;

-(instancetype)initWithData:(NSData *)data withVersion:(uint8_t)version;

@end
