//
//  SetResponsePacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *@discussion
 *  设置返回包
 */
@interface SetResponsePacket : NSObject
/*
 *@discussion
 *  得到包的大小
 */
+(int)getPacketSize;
/*
 *@discussion
 *  传人数据返回
 */
-(id)initWithData:(NSData *)data;
/*
 *@discussion
 *  得到消息ID
 */
-(int)getMessageID;
/*
 *@discussion
 *  得到有效位标示
 */
-(int)getState;

@end
