//
//  ProbeHeaderPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *@discussion
 * 探测返回包
 */
@interface ProbeHeaderPacket : NSObject
/*
 *@discussion
 * 得到包的大小
 */
-(int)getPacketSize;
/*
 *@discussion
 * 初始化函数
 */
-(id)initWithSession:(int)aSesssion andFlag:(int)aFlag;
/*
 *@discussion
 * 设置对话ID
 */
-(void)setSession:(int)aSesion;

-(NSMutableData *)getPacketData;
/*
 *@discussion
 * 设置探测标示
 */
-(void)setFlag:(int)aflag;
@end
