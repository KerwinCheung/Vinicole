//
//  CloudProbeReturnPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataPointEntity;

@interface CloudProbeReturnPacket : NSObject

@property (assign, nonatomic) int32_t   toID;
@property (assign, nonatomic) int16_t   msgID;
@property (assign, nonatomic) int8_t    code;
@property (assign, nonatomic) int8_t    flag;
@property (assign, nonatomic) BOOL      isFindable;

@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) NSData    *dataPoint;

-(id)initWithData:(NSData *)data;

-(NSArray <DataPointEntity *> *)getDataPointArr;

@end
