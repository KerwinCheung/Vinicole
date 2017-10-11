//
//  SyncHeaderPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "SyncCloudHeaderPacket.h"
#import "DataPointEntity.h"

#define PACKETSIZE  7

/*
 *@discussion
 *  同步包头
 */
@implementation SyncCloudHeaderPacket

-(id)initWithData:(NSData *)data{
    if (self = [super init]) {
        
        [data getBytes:&_deviceID range:NSMakeRange(0, 4)];
        _deviceID = htonl(_deviceID);
        
        [data getBytes:&_msgID range:NSMakeRange(4, 2)];
        _msgID = htons(_msgID);
        
        [data getBytes:&_flag range:NSMakeRange(6, 1)];
        
        NSUInteger offset = 7;
        
        if (_flag & 0b00000001) {
            NSUInteger len;
            [data getBytes:&len range:NSMakeRange(offset, 2)];
            offset+=2;
            
            _name = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset, len)] encoding:NSUTF8StringEncoding];
            offset+=len;
        }
        
        if (_flag & 0b00000110) {
            _dataPoint = [data subdataWithRange:NSMakeRange(offset, data.length - offset)];
        }
        
    }
    
    return self;
}

-(NSArray<DataPointEntity *> *)getDataPointArr{
    if (!_dataPoint.length) {
        return nil;
    }
    NSMutableArray *dataPoint = [NSMutableArray array];
    NSData *dataPointData = _dataPoint;
    while (dataPointData.length) {
        DataPointEntity *dataPointEntity = [[DataPointEntity alloc] init];
        uint8_t  index;
        uint16_t temp;
        uint8_t  type;
        uint16_t len;
        [dataPointData getBytes:&index range:NSMakeRange(0, 1)];
        [dataPointData getBytes:&temp range:NSMakeRange(1, 2)];
        temp = htons(temp);
        type = temp >> 12 & 0b1111;
        len = temp & 0b0000111111111111;
        dataPointEntity.index = index;
        dataPointEntity.type = type;
        dataPointEntity.len = len;
        [dataPointEntity setValueData:[dataPointData subdataWithRange:NSMakeRange(3, len)]];
        [dataPoint addObject:dataPointEntity];
        dataPointData = [dataPointData subdataWithRange:NSMakeRange(3 + len, dataPointData.length - 3 - len)];
    }
    return [NSArray arrayWithArray:dataPoint];
}

@end
