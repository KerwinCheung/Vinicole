//
//  LocalBindPacket.h
//  xlinksdklib
//
//  Created by Leon on 15/12/7.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalBindPacket : NSObject

-(id)initWithMessageID:(int)messageID port:(int)port andFlag:(int)flag;

-(int)getPacketSize;

-(NSMutableData *)getPacketData;


@end
