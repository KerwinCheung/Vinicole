//
//  SubscribeByAuthReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscribeByAuthReturnPacket : NSObject

@property (assign, nonatomic) int32_t   deviceID;
@property (assign, nonatomic) int16_t   msgID;
@property (assign, nonatomic) int8_t    code;

-(id)initWithData:(NSData *)data;

@end
