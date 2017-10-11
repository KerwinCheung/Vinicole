//
//  ActivateReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtHeader.h"
@interface ActivateReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;

-(int)getCode;

-(int)getDeviceId;

-(int)getAuthorizeLen;

-(NSData *)getAuthorizeData;

@end
