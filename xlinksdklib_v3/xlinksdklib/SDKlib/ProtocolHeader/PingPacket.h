//
//  PingPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"
/*
 *@discussion
 *  PING包头
 */
@interface PingPacket : NSObject
/*
 *@discussion
 *  PING包头
 */
-(id)initWithSessionID:(int)asession;
/*
 *@discussion
 *  PING包头
 */
-(NSData *)getPacketData;
/*
 *@discussion
 *  PING包头
 */
-(int)getPacketSize;

@end
