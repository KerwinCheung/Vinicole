//
//  AppPipeDevicePacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/28.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPipeDevicePacket : NSObject

-(id)initWithSessionID:(int)aSessionId andMessageID:(int)aMessageId andFlag:(int)flag;

-(int)getPacketSize;

-(NSMutableData *)getPacketData;

@end
