//
//  SetACKPacket.h
//  xlinksdklib
//
//  Created by xtmac on 14/12/15.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetACKPacket : NSObject

-(id)initWithMessageID:(unsigned short)messageID andAppListenPort:(unsigned short)port andAccessKey:(unsigned int)ack andFlag:(unsigned char)flag;

-(int)getPacketSize;

-(NSMutableData *)getPacketData;

@end
