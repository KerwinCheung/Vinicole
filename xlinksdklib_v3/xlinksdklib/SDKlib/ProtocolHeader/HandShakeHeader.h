//
//  HandShakeHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"

@interface HandShakeHeader : NSObject

-(id)initWithVersion:(int)version andDeviceKeyLen:(int)length andKeyStrData:(NSData *)strData andPort:(int)port andReserved:(int)reserved andAliveTime:(int)aliveTime;

-(id)initWithData:(NSData *)data;

-(NSMutableData *)getPacketData;

-(int)getPacketSize;

-(int)getVersion;

-(int)getDeviceKeyLength;

-(NSData *)getDeviceKeyStr;

-(int)getPort;

-(int)getReserved;

-(int)getKeepAliveTime;

-(void)setVersion:(int)version;

-(void)setDeviceKeyLength:(int)keyLen;

-(void)setDeviceKeyStr:(NSData *)strData;

-(void)setPort:(int)port;

-(void)setReserved:(int)reserved;

-(void)setKeepAliveTime:(int)aliveInterval;

@end
