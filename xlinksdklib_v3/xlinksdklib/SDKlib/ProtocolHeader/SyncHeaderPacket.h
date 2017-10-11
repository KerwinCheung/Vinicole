//
//  SyncHeaderPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"
/*
 *@discussion
 *  同步包头
 */
@interface SyncHeaderPacket : NSObject
+(int)getPacketSize;
/*
 *@discussion
 *  得到包的大小
 */
-(int)getPacketSize;
/*
 *@discussion
 *  初始化函数
 */
-(id)initWithMacAddress:(NSData *)aData andFlag:(int)aflag;

/*
 *@discussion
 *  同步返回包
 */
-(id)initWithData:(NSData *)aData;

/*
 *@discussion
 *  设置同步的Mac bytes
 */

-(void)setMacAddress:(NSData *)data;
/*
 *@discussion
 *  同步datapoint的有效性标示
 */
-(void)setFlag:(int)flag;

/*
 *@discussion
 *  获得同步的flag标示
 */
-(int)getFlag;

/*
 *@discussion
 *  获得mac字节
 */
-(NSData *)getMacData;
/*
 *@discussion
 *   获得包的字节
 */
-(NSMutableData *)getPacketData;

@end
