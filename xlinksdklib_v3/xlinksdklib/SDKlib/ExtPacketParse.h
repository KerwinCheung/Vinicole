//
//  ExtPacketParse.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExtPacketParse : NSObject
+(ExtPacketParse *)shareObject;
-(void)parserMachine:(NSData *)data;
@end
