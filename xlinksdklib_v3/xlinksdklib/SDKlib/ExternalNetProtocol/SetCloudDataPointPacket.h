//
//  setCloudDataPointPacket.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetCloudDataPointPacket : NSObject

@property (assign, nonatomic) uint32_t  deviceID;
@property (assign, nonatomic) uint16_t  msgID;
@property (assign, nonatomic) uint8_t   flag;

-(instancetype)initWithSessionID:(uint32_t)deviceID withMessageID:(uint16_t)msgID withFlag:(uint8_t)flag;

-(NSData *)getPacketData;

@end
