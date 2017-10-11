//
//  LocalBindRespPacket.h
//  xlinksdklib
//
//  Created by Leon on 15/12/7.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalBindRespPacket : NSObject

+(int)getPacketSize;

-(id)initWithData:(NSData *)data;

-(NSMutableData *)getPacketData;

-(int)getMessageID;

-(int)getFlag;

-(int)getCode;

-(int)getMasterKey;

@end
