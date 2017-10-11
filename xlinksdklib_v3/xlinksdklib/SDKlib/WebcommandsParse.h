//
//  WebcommandsParse.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/31.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebcommandsParse : NSObject

+(WebcommandsParse *)sharedObject;

-(void)parseWebcommandParse:(NSString *)commands;


@end
