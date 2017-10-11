//
//  SetPSWDPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetPSWDPacket : NSObject

-(id)initWithMessageID:(int)asessionID andAppListenPort:(int)port andOldAuth:(NSData *)oldAuth andNewAuth:(NSData *)newAuth andFlag:(int)flag;

-(int)getPacketSize;

-(NSMutableData *)getPacketData;

@end
