//
//  PipeReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtHeader.h"
/*
 typedef struct PIPE_RETURN{
    __b4 _toID;       //byte 1-4 回应的ID
    __b2 _messageID;  //byte 5-6 消息ID
    __b1 _code;       //byte 7   执行
 }PIPE_RETURN;
 */
@interface PipeReturnPacket : NSObject
@property (nonatomic,readonly,retain)NSMutableData *data;
+(PipeReturnPacket *)packetWithToId:(__b4)toId andMessageID:(__b2)msgID andCode:(__b1)code;
-(NSMutableData *)getPacketData;

-(id)initWithData:(NSMutableData *)data;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;

-(int)getToID;

-(int)getMessageID;

-(int)getCode;

-(void)setToID:(int)toID;

-(void)setMessageID:(int)msgID;

-(void)setCode:(int)code;

@end
