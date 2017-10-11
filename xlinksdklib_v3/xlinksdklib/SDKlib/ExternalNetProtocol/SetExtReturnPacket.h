//
//  SetExtReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetExtReturnPacket : NSObject
-(id)initWithToDeviceId:(int)deviceId andMsgID:(int)msgID andFlag:(int)flag;

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;

-(void)setToDeviceID:(int)dvceID;

-(void)setMessageID:(int)msgID;

-(void)setFlag:(int)flag;

@end
