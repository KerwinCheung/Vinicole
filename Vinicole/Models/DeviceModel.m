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
    deviceModel.name = @"红酒柜-演示机";
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
    //     开关 1byte 0=关，1=开
    //     灯开关 1byte 0=关，1=开
    //     玻璃门除雾开关状态 1byte 0=关，1=开
    //     温度单位 1byte 0=关，1=开
    //     温度设定值 1byte 5~20 步长为1
    //     湿度设定值 1byte 20~99 步长为1
    //     实际温度值 1byte 0~129 步长为1(实际温度为值-30)
    //     实际湿度 1byte 0~99 步长为1
    //     工作状态 1byte 0=制冷 1=恒温 2=制热
    //     故障 1byte 0=正常 1=E1 2=E2 。。。。 10=E10
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
                  nil];
}

-(void)setDefaultDataPoint{
    //     开关 1byte 0=关，1=开
    //     灯开关 1byte 0=关，1=开
    //     玻璃门除雾开关状态 1byte 0=关，1=开
    //     温度单位 1byte 0=关，1=开
    //     温度设定值 1byte 5~20 步长为1
    //     湿度设定值 1byte 20~99 步长为1
    //     实际温度值 1byte 0~129 步长为1(实际温度为值-30)
    //     实际湿度 1byte 0~99 步长为1
    //     工作状态 1byte 0=制冷 1=恒温 2=制热
    //     故障 1byte 0=正常 1=E1 2=E2 。。。。 10=E10
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
