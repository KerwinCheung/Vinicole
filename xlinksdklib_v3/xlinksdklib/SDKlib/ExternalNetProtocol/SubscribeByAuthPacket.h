//
//  SubscribeByAuthPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscribeByAuthPacket : NSObject

@property (assign, nonatomic) uint8_t   version;
@property (strong, nonatomic) NSData    *productIDData;
@property (strong, nonatomic) NSData    *macAddressData;
@property (strong, nonatomic) NSData    *authKeyData;
@property (assign, nonatomic) uint16_t  msgID;
@property (assign, nonatomic) int8_t    flag;

-(id)initWithVersion:(int8_t)version withProductID:(NSString *)productID withMacAddrwss:(NSData *)macAddress withAuthKey:(NSData *)authKey withMessageID:(int16_t)messageID withFlag:(int8_t)flag;

-(NSMutableData *)getPacketData;


@end
