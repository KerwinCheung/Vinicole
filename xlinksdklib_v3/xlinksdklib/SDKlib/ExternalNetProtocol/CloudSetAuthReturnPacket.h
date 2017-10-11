//
//  CloudSetAuthReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudSetAuthReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

+(int)getPacketSize;

-(int)getPacketSize;

-(int)getAppID;

-(int)getMessageID;

-(int)getCode;


@end
