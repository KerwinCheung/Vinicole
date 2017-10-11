//
//  DataPointEntity.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/7/5.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "DataPointEntity.h"

@implementation DataPointEntity

-(void)setValueData:(NSData *)data{
    if (_type == 0) {
        Byte temp = 0;
        [data getBytes:&temp length:1];
        _value = @(temp);
    }else if (_type == 1){
        int16_t temp = 0;
        [data getBytes:&temp length:2];
        _value = @(htons(temp));
    }else if (_type == 2){
        uint16_t temp = 0;
        [data getBytes:&temp length:2];
        _value = @(htons(temp));
    }else if (_type == 3){
        int32_t temp = 0;
        [data getBytes:&temp length:4];
        _value = @(htonl(temp));
    }else if (_type == 4){
        uint32_t temp = 0;
        [data getBytes:&temp length:4];
        _value = @(htonl(temp));
    }else if (_type == 5){
        int64_t temp = 0;
        [data getBytes:&temp length:8];
        _value = @(htonl(temp));
    }else if (_type == 6){
        uint64_t temp = 0;
        [data getBytes:&temp length:8];
        _value = @(htonl(temp));
    }else if (_type == 7){
        //Float 未实现
    }else if (_type == 8){
        //Double 未实现
    }else if (_type == 9){
        _value = [NSString stringWithUTF8String:data.bytes];
    }
}

-(NSData *)getDataPointData{
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&_index length:1];
    uint16_t temp = htons(_type << 12 | _len);
    [data appendBytes:&temp length:2];
    if (_type == 0) {
        //Byte | Bool
        uint8_t value = [_value unsignedCharValue];
        [data appendBytes:&value length:1];
    }else if (_type == 1){
        //int16
        int16_t value = htons([_value shortValue]);
        [data appendBytes:&value length:2];
    }else if (_type == 2){
        //uint16
        uint16_t value = htons([_value unsignedShortValue]);
        [data appendBytes:&value length:2];
    }else if (_type == 3){
        //int32
        int32_t value = htonl([_value intValue]);
        [data appendBytes:&value length:4];
    }else if (_type == 4){
        //uint32
        uint32_t value = htonl([_value unsignedIntegerValue]);
        [data appendBytes:&value length:4];
    }else if (_type == 5){
        //int64
        int64_t value = htonll([_value longLongValue]);
        [data appendBytes:&value length:8];
    }else if (_type == 6){
        //uint64
        uint64_t value = htonll([_value unsignedLongLongValue]);
        [data appendBytes:&value length:8];
    }else if (_type == 7){
        //Float 未实现
    }else if (_type == 8){
        //Double 未实现
    }else if (_type == 9){
        //String
        [data appendBytes:[_value UTF8String] length:_len];
    }
    return [NSData dataWithData:data];
}

@end
