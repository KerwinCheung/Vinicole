//
//  DataSource.m
//  lightify
//
//  Created by xtmac on 20/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "DataSource.h"

#import "UserModel.h"
#import "DeviceModel.h"
#import "DeviceEntity.h"
#import "HttpRequest.h"

@implementation DataSource

+(DataSource *)shareDataSource{
    static dispatch_once_t once;
    static DataSource *dataSource;
    dispatch_once(&once, ^{
        dataSource = [[DataSource alloc] init];
    });
    return dataSource;

}

-(void)saveUserWithIsUpload:(BOOL)isUpload{
    NSMutableArray *userList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"userList"]];
    for (NSInteger i = userList.count - 1; i >= 0; i--) {
        NSDictionary *userModelDic = userList[i];
        if ([_user.email isEqualToString:[userModelDic objectForKey:@"email"]]) {
            [userList removeObjectAtIndex:i];
            break;
        }
    }
    if (isUpload) {
        _user.uploadTime = @([[NSDate date] timeIntervalSince1970]).stringValue;
    }
    NSDictionary *userDictionary = [_user getDictionary];
    [userList addObject:userDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:userList forKey:@"userList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (isUpload) {
        NSDictionary *jingmeiPropertyDic = @{@"Property" : [userDictionary objectForKey:@"Property"]};
        //上传
        [HttpRequest setUserPropertyDictionary:jingmeiPropertyDic withUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken didLoadData:^(id result, NSError *err) {
            if (err) {
                if (err.code == 4031003) {  //无效/过期的Access-Token，重新获取
                    [HttpRequest authWithAccount:_user.email withPassword:_user.password didLoadData:^(id result, NSError *err) {
                        if (!err) {
                            _user.accessToken = result[@"access_token"];
                            [DATASOURCE saveUserWithIsUpload:NO];
                            [HttpRequest setUserPropertyDictionary:jingmeiPropertyDic withUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken didLoadData:nil];
                        }
                    }];
                }
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceChange object:nil];
}

-(void)saveDeviceModelWithMac:(NSString *)mac withIsUpload:(BOOL)isUpload{
    if (isUpload) {
        DeviceModel *deviceModel = [self getDeviceModelWithMac:mac];
        if (deviceModel) {
            deviceModel.uploadTime = @([[NSDate date] timeIntervalSince1970]).stringValue;
            NSDictionary *deviceModelDictionary = [deviceModel getDictionary];
            NSDictionary *PropertyDic = @{@"Property" : [deviceModelDictionary objectForKey:@"Property"]};
            [HttpRequest setDevicePropertyDictionary:PropertyDic withDeviceID:@(deviceModel.device.deviceID) withProductID:deviceModel.device.productID withAccessToken:DATASOURCE.user.accessToken didLoadData:^(id result, NSError *err) {
                if (err.code == 4031003) {  //无效/过期的Access-Token，重新获取
                    [HttpRequest authWithAccount:_user.email withPassword:_user.password didLoadData:^(id result, NSError *err) {
                        if (!err) {
                            _user.accessToken = result[@"access_token"];
                            [DATASOURCE saveUserWithIsUpload:NO];
                            [HttpRequest setDevicePropertyDictionary:PropertyDic withDeviceID:@(deviceModel.device.deviceID) withProductID:deviceModel.device.productID withAccessToken:DATASOURCE.user.accessToken didLoadData:nil];
                        }
                    }];
                }
            }];
        }
    }
    [self saveUserWithIsUpload:NO];
}

-(DeviceModel *)getDeviceModelWithMac:(NSString *)mac{
    
    for (int i = 0; i<self.user.deviceList.count; i++) {
        DeviceModel *deviceModel = self.user.deviceList[i];
        if ([mac isEqualToString:[deviceModel.device getMacAddressSimple]]) {
            return deviceModel;
        }
    }
    for (DeviceModel *deviceModel in _user.deviceList) {
        if ([mac isEqualToString:[deviceModel.device getMacAddressSimple]]) {
            return deviceModel;
        }
    }
    return nil;
}

-(DeviceModel *)getWillDelDeviceModelWithMac:(NSString *)mac{
    for (DeviceModel *deviceModel in _user.willDelDeviceList) {
        if ([mac isEqualToString:[deviceModel.device getMacAddressSimple]]) {
            return deviceModel;
        }
    }
    return nil;
}


@end
