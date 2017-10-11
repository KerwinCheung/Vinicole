//
//  CloudSetPWDPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudSetPWDPacket : NSObject

-(id)initWithDeviceID:(int)deviceID andMessageID:(int)messageID andFlag:(int)flag andOldAuth:(NSData *)oldAuth andNewAuth:(NSData *)newAuth;

-(id)init;

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;

@end
