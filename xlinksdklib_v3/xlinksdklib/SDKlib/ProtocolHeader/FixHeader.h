//
//  FixHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"

@interface FixHeader : NSObject

//+(FixHeader *)scanFixHeader;        //扫描的固定协议头

//+(FixHeader *)handShakeFixHeader;   //握手的固定协议头

//+(FixHeader *)setFixHeader;         //设置的固定协议头

//+(FixHeader *)probeFixHeader;       //探测的固定协议头

//+(FixHeader *)syncFixHeader;        //同步的固定协议头

//+(FixHeader *)pingFixHeader;        //ping的固定协议头

//+(FixHeader *)ByeByeFixHeader;      //bye-bye包

//+(FixHeader *)ticketFixHeader;      //ticket固定协议头

//+(FixHeader *)appPipeDeviceFixHeader;

//+(FixHeader *)devicePipeAppFixHeader;

//+(FixHeader *)setPWDFixHeader;

//+(FixHeader *)setBINDFixHeader;

//+(FixHeader *)pipeFixHeader;        //pipe头

+(int)getPacketSize;   //包大小

//初始化，该函数的主要作用是在接收到网络返回的数据时截取指定长度的头并得到返回信息的协议头
-(id)initWithFixData:(NSData *)data;

//获得固定协议头的长度
-(NSMutableData *)getPacketData;

//初始化
-(id)initWithInfo:(int8_t)infoFlag andDataLen:(NSUInteger)len;

//获得固定协议头标示
-(int)getMessageInfo;

//设置固定协议头标示
-(void)setMessageInfo:(int)info;

//获得数据的长度
-(int)getDataLength;

//设置固定协议头的数据长度
-(void)setDataLength:(NSUInteger)len;

@end
