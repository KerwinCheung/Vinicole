//
//  CloudSetAuthPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudSetAuthPacket : NSObject
-(id)initWithDeviceID:(int)deviceID andMessageID:(int)messageID andFlag:(int)flag andOldAuthKey:(NSData *)oldAuth andNewAuth:(NSData *)newAuth;

+(int)getPacketSize;

-(int)getPacketSize;

-(NSMutableData *)getPacketData;
@end
