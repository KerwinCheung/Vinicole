//
//  DeviceModel.h
//  lightify
//
//  Created by xtmac on 20/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceEntity;

typedef enum : unsigned short {
    DeviceTypeSwitchLight       =   0x0100,
    DeviceTypeBrightnessLight   =   0x0101,
    DeviceTypeColorTempLight    =   0x0102,
    DeviceTypeRGBLight          =   0x0103,
    DeviceTypeRGBWLight         =   0x0104,
    DeviceTypeRGBWWLight        =   0x0105
}DeviceType;

@interface DeviceModel : NSObject

@property (strong, nonatomic) DeviceEntity      *device;
@property (strong, nonatomic) NSNumber          *accessKey;
@property (strong, nonatomic) NSString          *name;
@property (assign, nonatomic) NSInteger         role;
@property (strong, nonatomic) NSNumber          *isSubscription;

@property (strong, nonatomic) NSString          *uploadTime;

@property (strong, nonatomic) NSNumber          *isSelect;

@property (strong, nonatomic) NSMutableArray    <NSMutableData  *>*dataPoint;//状态数据

@property (strong, nonatomic) NSMutableArray    <ActionModel    *>*actionList;
@property (strong, nonatomic) NSMutableArray    <NSNumber       *>*timedTaskIDList;

@property (nonatomic,strong) NSMutableArray *deviceModeList;

@property (nonatomic,copy)NSNumber *firmwareVersion;

@property (nonatomic ,strong) NSNumber      *isExpDevice;

// 来源 source == 2代表分享来的设备
@property (assign, nonatomic) NSInteger source;

//设备当前版本
@property (nonatomic,assign)NSUInteger curFirmwareVersion;
//设备当前版本
@property (nonatomic,assign)NSUInteger newestFirmwareVersion;

-(instancetype)init;

-(instancetype)initWithDictionary:(NSDictionary *)dic;

-(NSDictionary *)getDictionary;

-(void)initDataPoint;

+(DeviceModel *)creatExpDevice;

@end
