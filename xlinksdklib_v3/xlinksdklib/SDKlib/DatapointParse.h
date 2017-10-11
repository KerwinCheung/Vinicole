//
//  DatapointParse.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/30.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatapointParse : NSObject
+(NSArray *)parseDataPointBuffer:(NSMutableData *)buf andParseTemplate:(NSString *)dataPointModel;
+(NSMutableData *)bufferDataWithIndex:(int )index andValue:(int )value forParseTemplate:(NSString *)dataPointModel;


@end
