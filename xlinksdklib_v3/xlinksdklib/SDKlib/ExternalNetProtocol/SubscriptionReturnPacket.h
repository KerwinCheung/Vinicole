//
//  SubscriptionReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscriptionReturnPacket : NSObject
-(id)initWithData:(NSData *)data;
-(NSMutableData *)getPacketData;
-(NSInteger)getPacketSize;
+(NSInteger)getPacketSize;
-(int)getMessageID;
-(int)getCode;
-(int)getAppid;

@end
