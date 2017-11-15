//
//  DataManage.m
//  lightify
//
//  Created by xtmac on 4/3/16.
//  Copyright © 2016年 xlink.cn. All rights reserved.
//

#import "DataManage.h"

#import "XLinkExportObject.h"
#import "SendPacketModel.h"
#import "RecvAndSendEngine.h"

#import "UserModel.h"
#import "DeviceModel.h"
#import "HttpRequest.h"


@implementation DataManage{
    NSTimer *_tryConnectTimer;
    BOOL    _status;
}

+(DataManage *)share{
    static dispatch_once_t once;
    static DataManage *dataManage;
    dispatch_once(&once, ^{
        dataManage = [[DataManage alloc] init];
        dataManage->_status = 0;
    });
    return dataManage;
}

-(void)start{
    if (!_status) {
        _status = 1;
        [self addNotification];
        [self performSelectorInBackground:@selector(tryConnectTimerRun) withObject:nil];
    }
    
}

-(void)stop{
    if (_status) {
        _status = 0;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_tryConnectTimer invalidate];
        for (DeviceModel *deviceModel in DATASOURCE.user.deviceList) {
            if (deviceModel.device.isConnected) {
                [[XLinkExportObject sharedObject] disconnectDevice:deviceModel.device withReason:0];
            }
        }
        [[XLinkExportObject sharedObject] clearDeviceList];
    }
}

-(void)tryConnectTimerRun{
    _tryConnectTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(tryConnect) userInfo:nil repeats:YES];
    [_tryConnectTimer fire];
    [[NSRunLoop currentRunLoop] run];
}

-(void)tryConnect{
    for (NSUInteger i = 0; i < DATASOURCE.user.deviceList.count; i++) {
        DeviceModel *deviceModel = DATASOURCE.user.deviceList[i];
        if (!deviceModel.device.isConnected) {
            [[XLinkExportObject sharedObject] connectDevice:deviceModel.device andAuthKey:deviceModel.device.accessKey];
        }
        if (!deviceModel.device.isConnected && !deviceModel.device.isLANOnline && deviceModel.isSelect) {
            [[XLinkExportObject sharedObject] connectDevice:deviceModel.device andAuthKey:deviceModel.device.accessKey];
        }
    }
}

-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvLocalPipeData:) name:kOnRecvLocalPipeData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceStateChange:) name:kOnDeviceStateChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDevice:) name:kAddDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delDevice:) name:kDeleteDevice object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDeviceDataPoint:) name:kQueryDeviceDataPoint object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectDevice:) name:kOnConnectDevice object:nil];

}

-(void)addDevice:(NSNotification *)noti{
    DeviceModel *deviceModel = noti.object;
    [DATASOURCE.user.deviceList addObject:deviceModel];
    [DATASOURCE saveDeviceModelWithMac:nil withIsUpload:NO];
    [[XLinkExportObject sharedObject] connectDevice:deviceModel.device andAuthKey:deviceModel.accessKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDeviceList object:nil];
    
}

-(void)delDevice:(NSNotification *)noti{

//    NSString *mac = noti.object;
//    
//    DeviceModel *deviceModel = [DATASOURCE getDeviceModelWithMac:mac];
    
    DeviceModel *deviceModel = noti.object;
    [DATASOURCE.user.willDelDeviceList addObject:deviceModel];
    
    if (deviceModel.isExpDevice.intValue == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAddExpDevice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [HttpRequest unsubscribeDeviceWithUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken withDeviceID:@(deviceModel.device.deviceID) didLoadData:^(id result, NSError *err) {
        
        if (!err) {
            [DATASOURCE.user.willDelDeviceList removeObject:deviceModel];
            [DATASOURCE saveDeviceModelWithMac:nil withIsUpload:NO];
        }
        
    }];
    
    [DATASOURCE.user.deviceList removeObject:deviceModel];
    [DATASOURCE saveUserWithIsUpload:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDeviceList object:nil];
    
}

-(void)queryDeviceDataPoint:(NSNotification *)noti{
    
    char result = [noti.object[@"result"] intValue];
    DeviceEntity *device = [noti.object objectForKey:@"device"];
    
    if (result) {
        //查询失败
        if (device.isConnected) {
            [SendPacketModel queryDeviceDataPoint:device];
        }
        return;
    }
    
    NSMutableArray *dataPoint = [noti.object objectForKey:@"dataPoint"];
    
    DeviceModel *deviceModel = [DATASOURCE getDeviceModelWithMac:[device getMacAddressSimple]];
    deviceModel.dataPoint = dataPoint;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceChange object:device];
}

#pragma mark
#pragma mark XlinkExportObject Notification

-(void)onConnectDevice:(NSNotification *)noti{
    DeviceEntity *device = noti.object;

    //[SendPacketModel queryDeviceDataPoint:device];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnDeviceStateChange object:device];
    

}

-(void)onRecvLocalPipeData:(NSNotification *)noti{
    NSDictionary *dic = noti.object;
    [[RecvAndSendEngine shareEngine] recvData:[dic objectForKey:@"data"] withDevice:[dic objectForKey:@"device"]];
}

-(void)onDeviceStateChange:(NSNotification *)noti{
    DeviceEntity *device = noti.object;

//        for (DeviceModel *deviceModel in DATASOURCE.user.deviceList) {
//            if ([deviceModel.device.macAddress isEqualToData:device.macAddress]) {
//                [deviceModel initDataPoint];
//                [SendPacketModel queryDeviceDataPoint:device];
                //订阅设备 暂无登陆所以没有此功能
//                if (!deviceModel.isSubscription.boolValue) {
//                    [[XLinkExportObject sharedObject] subscribeDevice:device andAuthKey:device.accessKey andFlag:YES];
//                }
//                break;
//            }
//        }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceChange object:device];

}

@end
