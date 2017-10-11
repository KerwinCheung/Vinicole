//
//  PingRetPacket.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/6/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PingRetPacket : NSObject

-(id)initWithData:(NSData *)data withVersion:(uint8_t)version;

-(NSInteger)getPacketSize;

-(NSData *)getMAC;

@end
