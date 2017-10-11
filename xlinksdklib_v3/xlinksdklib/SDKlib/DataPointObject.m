//
//  DataPointObject.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/30.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "DataPointObject.h"

@implementation DataPointObject
-(NSString *)description{
    return [NSString stringWithFormat:@"index:%d  type:%d  value:%d",_index,_type,_value];
}
@end
