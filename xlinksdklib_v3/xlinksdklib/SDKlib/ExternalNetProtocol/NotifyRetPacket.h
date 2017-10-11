//
//  NotifyRetPacket.h
//  xlinksdklib
//
//  Created by xtmac on 6/1/16.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotifyRetPacket : NSObject

-(id)initWithData:(NSData *)data;

-(unsigned char)getFlag;

-(int)getMsgID;

-(int)getFromID;

+(NSInteger)getPacketSize;

@end
