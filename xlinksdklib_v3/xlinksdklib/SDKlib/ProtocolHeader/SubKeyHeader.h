//
//  SubKeyHeader.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/18.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubKeyHeader : NSObject

@property (assign, nonatomic) uint8_t   version;
@property (assign, nonatomic) uint16_t  msgID;
@property (strong, nonatomic) NSData    *accessKeyData;
@property (assign, nonatomic) int8_t    flag;

-(id)initWithVersion:(uint8_t)version withMessageID:(uint16_t)messageID withAccessKeyMD5:(NSData *)md5 withFlag:(int8_t)flag;

-(NSData *)getPacketData;

@end
