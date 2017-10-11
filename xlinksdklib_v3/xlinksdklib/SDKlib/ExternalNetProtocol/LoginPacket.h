//
//  LoginPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/5.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtHeader.h"

/*
 
 //login
 typedef struct LOGIN_HEADER{
 __b1 _version;           //byte 1 版本好
 __b4 _appId;             //byte 2-5 app ID
 __b2 _authorizeLen;      //byte 6-7 授权字符串长度
 __b1 _authorizeStr[32];  //byte 8-39 授权字符串
 __b1 _reserved;          //byte 40 预留
 __b2 _keepAliveTime;     //byte 41-42 保持存活时间
 }LOGIN_HEADER;
 
 */

@interface LoginPacket : NSObject{
    
}
@property (nonatomic,readonly,retain)NSMutableData *data;
@property (nonatomic,assign,readonly)LOGIN_HEADER packetStruct;


-(id)initWithVersion:(int)version andAppID:(int)appId andAuthLen:(int)authLen andAuthStr:(NSData *)authStr andReserved:(int)reserved andKeepAlive:(int)liveTime;

-(id)initWithData:(NSData *)data;


//get method

-(NSMutableData *)getPacketData;

+(NSInteger)getPacketSize;

-(NSInteger)getPacketSize;

-(int)getVersion;

-(int)getAppId;

-(int)getAuthLen;

-(NSData *)getAuthStr;

-(int)getReserved;

-(int)getAliveTime;

  //set method

-(void)setVersion:(int)version;

-(void)setAppId:(int)appId;

-(void)setAuthLen:(int)len;

-(void)setAuthStr:(NSData *)data;

-(void)setReserved:(int)reserved;

-(void)setAliveTime:(int)aliveTime;

@end
