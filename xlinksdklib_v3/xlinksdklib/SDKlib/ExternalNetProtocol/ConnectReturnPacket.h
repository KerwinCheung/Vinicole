//
//  ConnectReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectReturnPacket : NSObject
-(NSMutableData *)getPacketData;
-(NSInteger)getPacketSize;
+(NSInteger)getPacketSize;
-(id)initWithData:(NSData *)data;

-(int)getCode;
-(int)getReserved;
@end
