//
//  SubscriptionPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/8.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtHeader.h"


@interface SubscriptionPacket : NSObject
@property (nonatomic,retain,readonly)NSMutableData  *data;

-(id)initWithDeviceID:(int)deviceID andTicketStrLen:(int)aLen andTicketStr:(NSData *)aTicketStr andMessageID:(int)aMsgID andFlag:(int)aFlag;

-(NSMutableData *)getPacketData;
-(NSInteger)getPacketSize;
+(NSInteger)getPacketSize;
-(void)setDeviceID:(int)deiceID;
-(void)setMessageID:(int)msgID;
-(void)setFlag:(int)flag;

@end
