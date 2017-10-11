//
//  HandShakeRetPacket.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/6/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandShakeRetPacket : NSObject

@property (assign, nonatomic) uint8_t   result;
@property (assign, nonatomic) uint8_t   version;
@property (assign, nonatomic) int16_t   messageID;
@property (assign, nonatomic) uint16_t  macLen;
@property (strong, nonatomic) NSData    *macData;
@property (assign, nonatomic) uint32_t  deviceID;
@property (assign, nonatomic) uint16_t  mcuSoftVersion;
@property (assign, nonatomic) int16_t   sessionID;
@property (assign, nonatomic) int8_t    encryptionType;

-(instancetype)initWithData:(NSData *)data;

@end

