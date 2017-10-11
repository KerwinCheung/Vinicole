//
//  SyncHeaderPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataPointEntity;

@interface SyncCloudHeaderPacket : NSObject

@property (assign, nonatomic) int32_t   deviceID;
@property (assign, nonatomic) int16_t   msgID;
@property (assign, nonatomic) int8_t    flag;

@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) NSData    *dataPoint;

-(id)initWithData:(NSData *)data;

-(NSArray <DataPointEntity *> *)getDataPointArr;

@end
