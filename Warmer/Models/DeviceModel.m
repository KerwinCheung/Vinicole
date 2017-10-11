//
//  DeviceModel.m
//  lightify
//
//  Created by xtmac on 20/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "DeviceModel.h"
#import "DeviceEntity.h"

@implementation DeviceModel

-(instancetype)init{
    if (self = [super init]) {
        _actionList = [NSMutableArray array];
        _timedTaskIDList = [NSMutableArray array];
        _uploadTime = @"0";
        _isSubscription = @(0);
        _isSelect = @(0);
        _isExpDevice = @(0);
        [self initDataPoint];
    }
    return self;
}

+(DeviceModel *)creatExpDevice{
    
    DeviceModel *deviceModel = [[DeviceModel alloc]init];

    deviceModel.isExpDevice = @(1);
    deviceModel.device = [[DeviceEntity alloc]init];
    deviceModel.name = @"Vinicole-演示机";
    [deviceModel setDefaultDataPoint];
    return deviceModel;
    
}

-(instancetype)initWithDictionary:(NSDictionary *)dic{
    
    if (self = [self init]) {
        _device = [[DeviceEntity alloc] initWithDictionary:[dic objectForKey:@"deviceEntity"]];
        _accessKey = [dic objectForKey:@"accessKey"];
        _isSubscription = [dic objectForKey:@"isSubscription"];
        _isSelect = [dic objectForKey:@"isSelect"];
        _isExpDevice = [dic objectForKey:@"isExpDevice"];
        _name = [dic objectForKey:@"name"];
        
        NSDictionary *propertyDic = [dic objectForKey:@"Property"];
        
        if ([propertyDic.allKeys containsObject:@"uploadTime"]) {
            _uploadTime = [propertyDic objectForKey:@"uploadTime"];
        }else{
            _uploadTime = @"0";
        }
        
//        _name = [propertyDic objectForKey:@"name"];
        
        
        _curFirmwareVersion = [propertyDic[@"curFirmwareVersion"] integerValue];
        _newestFirmwareVersion = [propertyDic[@"newestFirmwareVersion"] integerValue];
        
        [self initDataPoint];
    }
    return self;
    
}

-(void)initDataPoint{
    
    /*
     1开关机（1byte）
     2功能（1byte）
     3运行的时钟（1byte）
     4运行的分钟（1byte）
     5运行的秒（1byte）
     6速度（1byte）
     7当前的温度（1byte）
     8备用（1byte）
     9故障（1byte）
     10工作状态显示（1byte）
     11预约剩余小时（1byte）
     12预约剩余分钟（1byte）
     13设置的保温温度 (1byte)
     */
    
    UInt8 value = 0x00;
    
    _dataPoint = [NSMutableArray arrayWithObjects:
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  [NSMutableData dataWithBytes:&value length:1],
                  nil];
   
    
    
}

-(void)setDefaultDataPoint{
    /*
     1开关机（1byte）
     2功能（1byte）
     3运行的时钟（1byte）
     4运行的分钟（1byte）
     5运行的秒（1byte）
     6速度（1byte）
     7当前的温度（1byte）
     8备用（1byte）
     9故障（1byte）
     10工作状态显示（1byte）
     11预约剩余小时（1byte）
     12预约剩余分钟（1byte）
     */

    UInt8 setTemp = 0x01;
    [_dataPoint[0] replaceBytesInRange:NSMakeRange(0, 1) withBytes:&setTemp length:1];
    
}

-(NSDictionary *)getDictionary{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_device) [dic setObject:[_device getDictionaryFormat] forKey:@"deviceEntity"];
    if (_accessKey) [dic setObject:_accessKey forKey:@"accessKey"];
    if (_isSubscription) [dic setObject:_isSubscription forKey:@"isSubscription"];

    if (_isSelect) [dic setObject:_isSelect forKey:@"isSelect"];
    
    if (_isExpDevice) [dic setObject:_isExpDevice forKey:@"isExpDevice"];
    
    if (_name) [dic setObject:_name forKey:@"name"];
    
    
    NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
    [propertyDic setObject:_uploadTime forKey:@"uploadTime"];
//    if (_name) [propertyDic setObject:_name forKey:@"name"];
    if (_curFirmwareVersion) {
        [propertyDic setObject:@(_curFirmwareVersion) forKey:@"curFirmwareVersion"];
    }
    if (_newestFirmwareVersion) {
        [propertyDic setObject:@(_newestFirmwareVersion) forKey:@"newestFirmwareVersion"];
    }
    [dic setObject:propertyDic forKey:@"Property"];
    
    return dic;
}

//-(NSString *)name{
//    if (!_name.length) {
//        if (_isExpDevice.intValue == 1) {
//            _name = @"商用豆浆机-演示机";
//        }else{
//            NSString *macStr = [_device getMacAddressSimple];
//            NSString *nameStr = [macStr substringWithRange:NSMakeRange(macStr.length-4, 4)];
//            _name =[NSString stringWithFormat:@"商用豆浆机-%@",nameStr];
//        }
//    }
//    return _name;
//}

-(NSNumber *)getValidTimedTaskID{
    NSUInteger timedTaskID = 0;
    BOOL isHas;
    do {
        timedTaskID++;
        isHas = false;
        for (NSNumber *tid in _timedTaskIDList) {
            if ([tid isEqualToNumber:@(timedTaskID)]) {
                isHas = YES;
                break;
            }
        }
    } while (isHas);
    return @(timedTaskID);
}

@end
