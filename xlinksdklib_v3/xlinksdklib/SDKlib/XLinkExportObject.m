//
//  XLinkExportObject.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/2.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//


#import "XLinkCoreObject.h"
#import "XLinkExportObject.h"
#import "XLReachability.h"
#import "ConnectDeviceTask.h"
#import "SDKProperty.h"
#import "XSendBufferQueue.h"

static XLinkExportObject * sharedExportObject;

@implementation XLinkExportObject{
    unsigned int _currentAppID;
    XSendBufferQueue * _sendBufferQueue;
    //LANReachability *_localNetState;
    //LANReachability *_internetState;
    
}


+(XLinkExportObject *)sharedObject{
    @synchronized(self){
        if (sharedExportObject == nil) {
            sharedExportObject = [[XLinkExportObject alloc]init];
        }
    }
    return sharedExportObject;
}

-(void)listernReachabilityNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newStateChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    
}

-(void)newStateChanged:(NSNotification *)notification{
    
    //    if (![LANReachability IsEnableWIFI]) {
    //        if([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]){
    //            [[XLinkExportObject sharedObject].delegate onNetStateChanged:-2];
    //        }
    //    }
    //
    //    if (![LANReachability IsEnable3G]) {
    //        if([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]){
    //            [[XLinkExportObject sharedObject].delegate onNetStateChanged:-2];
    //        }
    //    }
    
}

-(id)init{
    if(self = [super init]){
        
    }
    return self;
}

-(void)clearDeviceList {
    [[XLinkCoreObject sharedCoreObject] clearDeviceList];
}

-(int)start{
    
    if( [SDKProperty isEnableSendDataBuffer] ) {
        _sendBufferQueue = [[XSendBufferQueue alloc] init];
        [_sendBufferQueue startBufferQueue];
    }
    
    [[XLinkCoreObject sharedCoreObject] start];
    
    
    
    return 0;
    
}

-(void)stop{
    if( _sendBufferQueue ) {
        [_sendBufferQueue stopBufferQueue];
        _sendBufferQueue = nil;
    }
    
    [[XLinkCoreObject sharedCoreObject] stop];
}

-(void)setListenPort:(int)port{
    [[XLinkCoreObject sharedCoreObject] setListenPort:port];
}

//-(void)enterBackground{
//    [[XLinkCoreObject sharedCoreObject] enterBackground];
//}
//
//-(void)enterForeground{
//    [[XLinkCoreObject sharedCoreObject] enterForeground];
//}

//登陆外网
-(int)loginWithAppID:(int)appId andAuthStr:(NSString *)authStr{
    
    if(appId<0){
        return -1;
    }
    
    if ([XLinkCoreObject sharedCoreObject].isLoginSuccessed) {
        
        if (_currentAppID == appId) {
            NSLog(@"你当前是登录状态");
            if([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onLogin:)]){
                [[XLinkExportObject sharedObject].delegate onLogin:0];
            }
            return 0;
        }else{
            NSLog(@"已经登录了不同的账号，请调用stop再进行登录流程");
            return -1;
        }
        
    }else{
        [[XLinkCoreObject sharedCoreObject] loginWithAppID:appId andAuthStr:authStr andKeepLive:60];
        return 0;
    }
}

-(void)logout{
    [[XLinkCoreObject sharedCoreObject] logout];
}

//-(int)scanByDeviceMacAddress:(NSString *)macAddress andDelegate:(id<ScanDeviceDelegate>)dlgt{
//    [[XLinkCoreObject sharedCoreObject] scanByDeviceMacAddress:macAddress andDelegate:dlgt];
//    return 0;
//}

-(int)scanByDeviceProductID:(NSString *)productID{
    
    if (productID.length != 32) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if( ![XLReachability IsEnableWIFI] ) {
        return CODE_STATE_NO_WIFI;
    }
    
    [[XLinkCoreObject sharedCoreObject] scanByDeviceProductID:productID andDelegate:nil];
    
    return 0;
    
}

-(int)sendLocalPipeData:(DeviceEntity *)device andPayload:(NSData *)payload{
    
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (![device getSessionID]) {
        return CODE_FUNC_DEVICE_SESSION_ID_ERROR;
    }
    
    if(!device.isLANOnline) {
        // 这个动作一定要在主线程内发起
        //        [[XLinkCoreObject sharedCoreObject] performSelectorOnMainThread:@selector(reconnectDevice:) withObject:device waitUntilDone:NO];
        //        [[XLinkCoreObject sharedCoreObject] reconnectDevice:device];
        return CODE_FUNC_DEVICE_CONNECTING;
    }
    
    if( [SDKProperty isEnableSendDataBuffer] && _sendBufferQueue ) {
        unsigned short msgID = [[XLinkCoreObject sharedCoreObject] getMessageID];
        [_sendBufferQueue addLocalPipeBufferWithDevice:device msgId:msgID andPayload:payload];
        return msgID;
    } else {
        return [[XLinkCoreObject sharedCoreObject] sendLocalPipeWithDevice:device andPayload:payload andFlag:0];
    }
}

-(int)setLocalDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthCode:(NSNumber *)oldAuth andNewAuthCode:(NSNumber *)newAuth{
    
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    return  [[XLinkCoreObject sharedCoreObject] setLocalDeviceAuthorizeCode:device andOldAuthCode:oldAuth andNewAuthCode:newAuth];
}

-(int)handShakeWithDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (device.devicePort<0) {
        return CODE_FUNC_DEVICE_ERROR;
    }
    
    if (!device.fromIP) {
        return CODE_FUNC_DEVICE_ERROR;
    }
    
    [[XLinkCoreObject sharedCoreObject] handShakeWithDevice:device andAuthKey:authKey];
    return 0;
}

//-(int)handShakeWithDevice:(DeviceEntity *)device {
//    if (!device) {
//        return CODE_FUNC_PARAM_ERROR;
//    }
//
//    [[XLinkCoreObject sharedCoreObject] handShakeWithDevice:device];
//
//    return 0;
//}

-(int)subscribeDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey andFlag:(int8_t)flag{
    
    
    return [[XLinkCoreObject sharedCoreObject] subscribeDevice:device andAuthKey:authKey andFlag:flag];
    
}

-(int)sendPipeData:(DeviceEntity *)device andPayload:(NSData *)payload{
    
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (device.deviceID ==0) {
        return CODE_FUNC_DEVICE_NOT_ACTIVATION;
    }
    
    if (![XLinkCoreObject sharedCoreObject].isLoginSuccessed) {
        return CODE_FUNC_NETWOR_ERROR;
    }
    
    if(!device.isWANOnline) {
        // 这个动作一定要在主线程内发起
        //        [[XLinkCoreObject sharedCoreObject] performSelectorOnMainThread:@selector(reconnectDevice:) withObject:device waitUntilDone:NO];
        //        [[XLinkCoreObject sharedCoreObject] reconnectDevice:device];
        return CODE_FUNC_DEVICE_CONNECTING;
    }
    
    return  [[XLinkCoreObject sharedCoreObject] sendCloudPipe:device andPayload:payload];
    
}

-(int)initDevice:(DeviceEntity *)device{
    
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (device.productID.length != 32) {
        return CODE_FUNC_DEVICE_ERROR;
    }
    
    if(device.macAddress.length != 6){
        return CODE_FUNC_DEVICE_MAC_ERROR;
    }
    
    if (!device.fromIP) {
        return CODE_FUNC_DEVICE_IP_ERROR;
    }
    
    //TODO：
    //    NSDictionary * dict = [device getDictionaryFormatWithProtocol:100];
    //    NSLog(@"%@", dict);
    
    [[XLinkCoreObject sharedCoreObject] initDevice:(DeviceEntity *)device];
    
    return 0;
    
}


-(int)probeDevice:(DeviceEntity *)device{
    
    if(!device){
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if(device.deviceID == 0){
        return CODE_FUNC_DEVICE_NOT_ACTIVATION;
    }
    
    
    if (device.connectStatus & ConnectStatusWANConnectSuccessfully) {
        return [[XLinkCoreObject sharedCoreObject] sendCloudProbe:device andFlag:0];
    }else{
        return [[XLinkCoreObject sharedCoreObject] sendLocalProbeWithDevice:device andFlag:0];
    }
}

-(int)connectDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey{
    
    if( device == nil ) {
        return -1;
    }
    
    // 看看本地设备中有没有该设备的信息
    DeviceEntity *temp = [[XLinkCoreObject sharedCoreObject] getDeviceByMacAddress:[device macAddress]];
    if( temp == nil  ) {
        NSLog(@"需要连接的设备 %@ 在SDK中不存在，SDK自动添加该设备", [device getMacAddressString]);
        [[XLinkCoreObject sharedCoreObject] initDevice:device];
        [device setAccessKey:authKey];
    }else if (temp != device){
        //需要连接的设备与SDK中的设备的地址不匹配，重新初始化设备
        [[XLinkCoreObject sharedCoreObject] initDevice:device];
        [device setAccessKey:authKey];
    }
    
    NSLog(@"Try connect device %@ ...", [device getMacAddressString]);
    
    ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:device.macAddress];
    return [task connectWithAccessKey:authKey];
    
    /*
     device.isCloud = NO;
     _isConnectDevice = YES;
     _authKey = authKey;
     
     return [self handShakeWithDevice:device andAuthKey:authKey];
     */
}

-(int)disconnectDevice:(DeviceEntity *)device withReason:(int)reason {
    
    // 看看本地设备中有没有该设备的信息
    DeviceEntity * deviceInSDK = [[XLinkCoreObject sharedCoreObject] getDeviceByMacAddress:[device macAddress]];
    if( deviceInSDK == nil  ) {
        NSLog(@"需要断开的设备 %@ 在SDK中不存在，跳出", [deviceInSDK getMacAddressString]);
        return 0;
    }
    
    
    // 如果是本地通讯的设备，需要发送byebye包
    if( deviceInSDK.connectStatus & ConnectStatusLANConnectSuccessfully ) {
        [[XLinkCoreObject sharedCoreObject] sendLocalByeBye:deviceInSDK];
    }
    
    NSLog(@"手动断开设备%@ %d，SDK将不再处理该设备的数据", [deviceInSDK getMacAddressString], [deviceInSDK getDeviceID]);
    
    // 下设置设备的状态
    [deviceInSDK userDisconnect];
    
    return 0;
}

-(int)setDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (device.deviceID<0) {
        return CODE_FUNC_DEVICE_NOT_ACTIVATION;
    }
    
    return  [[XLinkCoreObject sharedCoreObject] setDeviceAuthorizeCode:device andOldAuthKey:oldAuth andNewAuthKey:newAuth];
    
}

-(void)pipeWithDevice:(DeviceEntity *)device andPayload:(NSData *)payload{
    [[XLinkCoreObject sharedCoreObject] pipeWithDevice:device andMessageFlag:0 andPlayData:payload];
}

-(void)setProdctidWithJsonString:(NSString *)jsonStr{
    NSArray *dataTypeString = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[jsonStr UTF8String] length:jsonStr.length] options:0 error:nil]];
    if (!_prodctid_value) {
        _prodctid_value = [[NSMutableArray alloc] init];
    }
    [_prodctid_value removeAllObjects];
    for (NSString *str in dataTypeString) {
        if ([str isEqualToString:@"byte"] || [str isEqualToString:@"bool"]) {
            [_prodctid_value addObject:@1];
        }else if ([str isEqualToString:@"int16"]){
            [_prodctid_value addObject:@2];
        }
    }
}

-(int)setSDKProperty:(NSObject *)object withKey:(NSString *)key {
    [[SDKProperty sharedProperty] setProperty:object forKey:key];
    
    return 0;
}

- (NSObject *)getSDKProperty:(NSString *)key {
    return [[SDKProperty sharedProperty] getProperty:key];
}

-(int)setAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    return [[XLinkCoreObject sharedCoreObject] setAccessKey:accessKey withDevice:device];
}

-(unsigned short)setLocalDataPoints:(NSArray<DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device{
    
    if (!device) {
        return 0;
    }
    
    return [[XLinkCoreObject sharedCoreObject] setLocalDataPoints:dataPoints withDevice:device];
}

-(unsigned short)setCloudDataPoints:(NSArray<DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device{
    
    if (!device) {
        return 0;
    }
    
    return [[XLinkCoreObject sharedCoreObject] setCloudDataPoints:dataPoints withDevice:device];
}

@end
