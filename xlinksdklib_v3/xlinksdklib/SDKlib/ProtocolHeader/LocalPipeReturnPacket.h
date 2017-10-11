//
//  LocalPipeReturnPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/28.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalPipeReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

-(int)getMessageID;

-(int)getCode;

+(int)getPacketSize;

@end
