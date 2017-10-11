//
//  setCloudDataPointReturnPacket.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/3.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetCloudDataPointReturnPacket : NSObject

-(id)initWithData:(NSData *)data;

+(int)getPacketSize;

-(int)getPacketSize;

-(int)getDeviceID;

-(int)getMessageID;

-(int)getCode;

@end
