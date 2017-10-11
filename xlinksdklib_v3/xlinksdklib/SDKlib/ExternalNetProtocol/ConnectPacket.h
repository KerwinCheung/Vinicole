//
//  ConnectPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectPacket : NSObject
-(id)initWithVersion:(int)version andDeviceId:(int)deviceId andAuthorizedLen:(int)authLen andAuthorizeStr:(NSData *)data andReseved:(int)reseved andKeepLive:(int)keepLive;

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;

-(void)setVersion:(int)version;

-(void)setDeviceId:(int)deviceId;

-(void)setAuthLen:(int)authLen;

-(void)setAuthStr:(NSData *)strDt;

-(void)setReseved:(int)reserved;

-(void)setKeepAliveTime:(int)aliveTimer;

@end
