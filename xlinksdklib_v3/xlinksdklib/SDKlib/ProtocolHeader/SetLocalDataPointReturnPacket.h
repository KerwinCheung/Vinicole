//
//  SetLocalDataPointReturnPacket.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetLocalDataPointReturnPacket : NSObject

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
