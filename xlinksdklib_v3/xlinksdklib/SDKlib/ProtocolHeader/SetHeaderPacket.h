//
//  SetHeaderPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"
/*
 *@discussion
 *  设置可以变协议头
 */
@interface SetHeaderPacket : NSObject
/*
 *@discussion
 *  初始化函数
 */
-(id)initWithSessionID:(int)aSession andMessageID:(int)aMessage andFlag:(int)flag;
/*
 *@discussion
 *  获得包的bytes
 */
-(NSMutableData *)getPacketData;
/*
 *@discussion
 *  获得包的大小
 */
-(int)getPacketSize;
/*
 *@discussion
 *  获得对话ID
 */
-(void)setSessionID:(int)aSession;
/*
 *@discussion
 *  设置消息ID
 */

-(void)setMessageID:(int)aMessage;
/*
 *@discussion
 *  设置datapoint的flag
 */

-(void)setFlag:(int)aFlag;

@end
