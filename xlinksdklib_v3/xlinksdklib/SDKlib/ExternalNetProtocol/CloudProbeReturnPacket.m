//
//  CloudProbeReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "CloudProbeReturnPacket.h"
#import "DataPointEntity.h"

@implementation CloudProbeReturnPacket

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        
        [data getBytes:&_toID range:NSMakeRange(0, 4)];
        _toID = htonl(_toID);
        
        [data getBytes:&_msgID range:NSMakeRange(4, 2)];
        _msgID = htons(_msgID);
        
        [data getBytes:&_code range:NSMakeRange(6, 1)];
        
        [data getBytes:&_flag range:NSMakeRange(7, 1)];
        
        _isFindable = _flag & 0b00001000;
        
        NSUInteger offset = 8;
        
        if (_flag & 0b00000001) {
            NSUInteger len;
            [data getBytes:&len range:NSMakeRange(offset, 2)];
            len = htons(len);
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
