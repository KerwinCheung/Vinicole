//
//  TicketReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/27.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

+(int)getPacketSize;

-(NSMutableData *)getPacketData;

-(int)getMessageID;

-(int)getCode;

-(NSString *)getTicket;

-(BOOL)isHasTicket;

@end
