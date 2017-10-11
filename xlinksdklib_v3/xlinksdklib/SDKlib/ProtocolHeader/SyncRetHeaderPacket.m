//
//  SyncRetHeaderPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/29.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "SyncRetHeaderPacket.h"
#import "DataPointEntity.h"

@implementation SyncRetHeaderPacket

-(id)initWithData:(NSData *)data withVersion:(uint8_t)version{
    
    if (self = [super init]) {
        
        NSMutableData *temp =[NSMutableData dataWithData:data];
        if (version < 3) {
            uint16_t len = htons(6);
            [temp replaceBytesInRange:NSMakeRange(0, 0) withBytes:&len length:2];
            data = [NSData dataWithData:temp];
        }
        
        uint16_t macLen;
        [data getBytes:&macLen range:NSMakeRange(0, 2)];
        macLen = htons(macLen);
        
        _mac = [data subdataWithRange:NSMakeRange(2, macLen)];
        uint16_t offset = 2 + macLen;
        
        [data getBytes:&_flag range:NSMakeRange(offset, 1)];
        offset+=1;
        
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
/*
 00 0 001 85
 01 0 001 3c
 02 1 002 3462
 03 3 004 0098988a
 04 9 018 e794b5e9 a5ade994 85656c65 63747269 6320636f 6f6b6572
 05 0 001 01
 06 7 004 00000001
 */
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
