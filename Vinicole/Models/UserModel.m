//
//  UserModel.m
//  lightify
//
//  Created by xtmac on 20/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "UserModel.h"
#import "DeviceModel.h"

@implementation UserModel

-(instancetype)initWithEmail:(NSString *)emailStr andPassword:(NSString *)password{
    if (self = [super init]) {
        _email = emailStr;
        _password = password;
        _uploadTime = @"0";
        _deviceList = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        _email          =   [dic objectForKey:@"email"];
        _password       =   [dic objectForKey:@"password"];
        _nickName       =   [dic objectForKey:@"nickname"];
        _userId         =   [dic objectForKey:@"userID"];
        _authorize      =   [dic objectForKey:@"authorize"];
        _accessToken    =   [dic objectForKey:@"access-token"];
        _isVaild        =   [dic objectForKey:@"is_vaild"];
        
        NSDictionary *propertyDic = [dic objectForKey:@"Property"];
        
        if ([propertyDic.allKeys containsObject:@"uploadTime"]) {
            _uploadTime = [propertyDic objectForKey:@"uploadTime"];
        }else{
            _uploadTime = @"0";
        }
        
        _deviceList = [NSMutableArray array];
        NSArray *deviceListDicArr = [dic objectForKey:@"deviceList"];
        for (NSDictionary *deviceListDic in deviceListDicArr) {
            [_deviceList addObject:[[DeviceModel alloc] initWithDictionary:deviceListDic]];
        }
        
        _willDelDeviceList = [NSMutableArray array];
        NSArray *willDelDeviceListDicArr = [dic objectForKey:@"willDelDeviceList"];
        for (NSDictionary *deviceListDic in willDelDeviceListDicArr) {
            [_willDelDeviceList addObject:[[DeviceModel alloc] initWithDictionary:deviceListDic]];
        }
        
        
        
    }
    return self;
}

-(void)setProperty:(NSDictionary *)propertyDic{
    NSString *uploadTime = [propertyDic objectForKey:@"uploadTime"];
    if (uploadTime.doubleValue > _uploadTime.doubleValue) {
        _uploadTime = [propertyDic objectForKey:@"uploadTime"];
        
        [DATASOURCE saveUserWithIsUpload:NO];
    }else if (uploadTime.doubleValue < _uploadTime.doubleValue){
        [DATASOURCE saveUserWithIsUpload:YES];
    }
}

-(NSDictionary *)getDictionary{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_email)     [dic setObject:_email forKey:@"email"];
    if (_password)  [dic setObject:_password forKey:@"password"];
    if (_nickName)  [dic setObject:_nickName forKey:@"nickname"];
    if (_userId)  [dic setObject:_userId forKey:@"userID"];
    if (_authorize)  [dic setObject:_authorize forKey:@"authorize"];
    if (_accessToken)  [dic setObject:_accessToken forKey:@"access-token"];
    if (_isVaild) [dic setObject:_isVaild forKey:@"is_vaild"];
    
    
    //扩展属性
    NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
    
    if (_uploadTime) {
        [propertyDic setObject:_uploadTime forKey:@"uploadTime"];
    }

    [dic setObject:propertyDic forKey:@"Property"];
    
    
    
    NSMutableArray *deviceListDicArr = [NSMutableArray array];
    for (DeviceModel *deviceModel in _deviceList) {
        [deviceListDicArr addObject:[deviceModel getDictionary]];
    }
    [dic setObject:deviceListDicArr forKey:@"deviceList"];
    
    NSMutableArray *willDelDeviceListDicArr = [NSMutableArray array];
    for (DeviceModel *deviceModel in _willDelDeviceList) {
        [willDelDeviceListDicArr addObject:[deviceModel getDictionary]];
    }
    [dic setObject:willDelDeviceListDicArr forKey:@"willDelDeviceList"];
    
    return [NSDictionary dictionaryWithDictionary:dic];
}


@end
