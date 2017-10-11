//
//  SyncExtPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncExtPacket : NSObject
-(id)initWithDeviceID:(int)deviceID andMessageID:(int)msgID andFlag:(int)flag;


-(NSMutableData *)getPacketData;


-(NSInteger)getPacketSize;
+(NSInteger)getPacketSize;
-(void)setDeviceID:(int)deviceID;
-(void)setMessageID:(int)messageID;
-(void)setFlag:(int)flag;
@end
