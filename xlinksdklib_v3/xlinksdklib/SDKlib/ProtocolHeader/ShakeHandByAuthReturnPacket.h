//
//  ShakeHandByAuthReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShakeHandByAuthReturnPacket : NSObject
-(id)initWithData:(NSData *)data;

+(int)getPacketSize;

-(NSMutableData *)getPacketData;

-(int)getVersion;

-(NSData *)getMacAddress;

-(int)getDeviceID;

-(int)getMcuSoftVersion;

-(int)getSessionID;

-(int)getCrypTpye;

-(int)getMessageID;

-(int)getCode;
@end
