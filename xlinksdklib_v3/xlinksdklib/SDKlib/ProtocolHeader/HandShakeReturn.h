//
//  HandShakeReturn.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"


/*
 *@discussion
 *  握手返回包
 */
@interface HandShakeReturn : NSObject

/*
 *@discussion
 *  把接收到的网络字节
 */
-(id)initWithData:(NSData *)data;

/*
 *@discussion
 *  获得包网络字节
 */
-(NSMutableData *)getPacketData;
/*
 *@discussion
 *  获得包大小
 */
+(int)getPacketSize;
/*
 *@discussion
 *  获得包网络字节
 */
-(void)setPacketData:(NSData *)data;
/*
 *@discussion
 *  获得协议版本
 */
-(int)getVersion;
/*
 *@discussion
 *  获得Mac地址
 */
-(NSData *)getMacAddress;
/*
 *@discussion
 *  获得设备ID
 */
-(int)getDeviceID;
/*
 *@discussion
 *  获得MCU 软件版本
 */
-(int)getMCUSoftVersion;
/*
 *@discussion
 *  获得sessionID
 */
-(int)getSessionID;
/*
 *@discussion
 *  获得握手参数
 */
-(int)getHandShakeKey;

@end
