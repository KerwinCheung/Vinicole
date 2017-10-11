//
//  TicketPacketHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/27.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketPacketHeader : NSObject


-(id)initWithSessionID:(int)asessionID andAppID:(int)appID andMessageID:(int)msgID andFlag:(int)flag;

+(int)getPacketSize;

-(NSMutableData *)getPacketData;

@end
