//
//  PipeTwoPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/5.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PipeTwoPacket : NSObject

-(id)initWithSyncData:(NSData *)data;

+(int)getPacketSize;

-(int)getPacketSize;

-(int)getDeviceID;

@end
