//
//  SyncExtReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncExtReturnPacket : NSObject

-(id)initWithData:(NSData *)data;
-(NSMutableData *)getPacketData;
-(NSInteger)getPacketSize;
+(NSInteger)getPacketSize;
-(void)setPacketData:(NSData *)data;
-(int)getMessageID;
-(int)getCode;
@end
