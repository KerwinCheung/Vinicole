//
//  SetACKReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac on 14/12/15.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetACKReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

+(int)getPacketSize;

-(NSMutableData *)getPacketData;

-(int)getMessageID;

-(int)getCode;

@end
