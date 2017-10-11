//
//  PipePacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtHeader.h"
/*
 //pipe 数据管道
 typedef struct PIPE_HEADER{
 __b4 _deviceId;   //byte 1-4 设备ID
 __b2 _messageID;  //byte 5-6 消息ID
 __b1 _flag;       //byte 7  数据实体标示
 }PIPE_HEADER;
 */
@interface PipePacket : NSObject
@property (nonatomic,retain,readonly)NSMutableData *data;

+(PipePacket *)packetWithDeviceId:(__b4)dvceID andMessageID:(__b2)messageID andFlag:(__b1)flag;

-(id)initWithDeviceId:(int)dvceID andMessageID:(int)messageID andFlag:(int)flag;

-(id)initWithData:(NSData *)data;

//get method

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(int)getPacketSize;

-(int)getDeviceID;

-(int)getMessageID;

-(int)getFlag;

//set method

-(void)setPacketData:(NSMutableData *)data;

-(void)setDeviceID:(int)dvceID;

-(void)setMessageID:(int)msgID;

-(void)setFlag:(int)flg;

@end
