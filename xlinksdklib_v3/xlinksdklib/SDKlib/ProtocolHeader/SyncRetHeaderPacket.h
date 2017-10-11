//
//  SyncHeaderPacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataPointEntity;

@interface SyncRetHeaderPacket : NSObject

@property (strong, nonatomic) NSData    *mac;
@property (assign, nonatomic) int8_t    flag;

@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) NSData    *dataPoint;

-(id)initWithData:(NSData *)data withVersion:(uint8_t)version;

-(NSArray <DataPointEntity *> *)getDataPointArr;

@end
