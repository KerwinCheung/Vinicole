//
//  ConnectDeviceTask.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/18.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ConnectDeviceTask.h"
#import "GCDAsyncUdpSocket.h"
#import "FixHeader.h"
#import "ScanHeader.h"

#import "XlinkMessage.h"
#import "XLinkCoreObject.h"
#import "XLinkExportObject.h"

#import "SubscribeByAuthReturnPacket.h"
#import "ExternalNetProtocol/CloudProbeReturnPacket.h"
#import "SubKeyReturnHeader.h"

#import "XLReachability.h"

@implementation ConnectDeviceTask{
//    NSThread    *_scanThread;
//    NSThread    *_handShakeThread;
//    NSThread    *_subscriptThread;
//    NSThread    *_subKeyThread;
    //    NSThread    *_probeThread;
    BOOL _isScanSuccess;
    BOOL _isHandShakeSuccess;
    BOOL _isSubscriptSuccess;
    BOOL _isGetSubKeySuccess;
    BOOL _isProbeSuccess;
    
    NSLock  *_lock;
    
    UInt8   _scanStep;
}

-(instancetype)initWithDevice:(DeviceEntity *)device{
    
    self = [super init];
    
    if (self) {
        _deviceEntity = device;
        _lock   = [[NSLock alloc] init];
    }
    
    return self;
    
}

-(int)connectWithAccessKey:(NSNumber *)accessKey{
    
    if (!_deviceEntity) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    _accessKey = accessKey;
    
//    _deviceEntity.connectStatus = ConnectStatusConnecting;
    
    //有内网的环境
    if ([XLReachability IsEnableWIFI]) {
        // 第一次扫描
        if (_deviceEntity.connectStatus & 0b0011) {
            //把连接状态致为内网正在连接
            _deviceEntity.connectStatus = _deviceEntity.connectStatus & 0b1100;
            // 通知正在连接设备
            if( [[[XLinkExportObject sharedObject] delegate] respondsToSelector:@selector(onDeviceStatusChanged:)] ) {
                [[XLinkExportObject sharedObject].delegate onDeviceStatusChanged:_deviceEntity];
            }
            NSLog(@"Connect device scan by mac %@ begin...", [_deviceEntity getMacAddressString]);
            _scanStep = 0;
            [self performSelector:@selector(beginScanByMac) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
        }else{
            NSLog(@"Device %@ is already connecting In LAN.", [_deviceEntity getMacAddressString]);
        }
    }
    
    if( [XLinkCoreObject sharedCoreObject].isLoginSuccessed ) {
        if (_deviceEntity.connectStatus & 0b1100) {
            //把连接状态致为外网正在连接
            _deviceEntity.connectStatus = _deviceEntity.connectStatus & 0b0011;
            // 通知正在连接设备
            if( [[[XLinkExportObject sharedObject] delegate] respondsToSelector:@selector(onDeviceStatusChanged:)] ) {
                [[XLinkExportObject sharedObject].delegate onDeviceStatusChanged:_deviceEntity];
            }
            if (_deviceEntity.getDeviceID == 0) {
                if (_deviceEntity.version >= 3 && _deviceEntity.subKey == 0) {
                    NSLog(@"Connect device try get subKey ...");
                    [self performSelector:@selector(beginGetSubKey) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
                }else{
                    NSLog(@"Connect device try subscripe device for no device id ...");
                    [self performSelector:@selector(beginSubscriptionWithDevice) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
                }
            } else{
                NSLog(@"Connect device try probe device %d ...", _deviceEntity.getDeviceID);
                [self performSelector:@selector(beginProbeDevice) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
            }
        }else{
            NSLog(@"Device %@ is already connecting In WAN.", [_deviceEntity getMacAddressString]);
        }
    } else {
        NSLog(@"Connect device app offline, connect device overtime.");
        [self onConnectDeviceCallbackIsLAN:false withCode:CODE_TIMEOUT andTaskID:0];
    }
    
    return 0;
}

#pragma mark
#pragma mark 扫描
- (void)beginScanByMac{
    
    //扫描协议头
    ScanHeader *scan = [[ScanHeader alloc] initWithVersion:2 andPort:[[XLinkCoreObject sharedCoreObject] getListenPort] andMacAddress:_deviceEntity.macAddress];
    
    FixHeader *fix = [[FixHeader alloc] initWithInfo:SCAN_REQ_FLAG andDataLen:[scan getPacketSize]];
    
    NSMutableData *temp = [fix getPacketData];
    [temp appendData:[scan getPacketData]];
    
    // 发包
    _isScanSuccess = false;
    [[SenderEngine sharedEngine] sendBoardcastWithData:temp];
    
    // 设置超时处理
    [self performSelector:@selector(scanByMacOvertime) withObject:nil afterDelay:1.5];
    
}

#pragma mark 扫描超时
- (void)scanByMacOvertime{
    
    //扫描设备3次
    if (!_isScanSuccess) {
        if (_scanStep < 3) {
            _scanStep++;
            [self beginScanByMac];
        }else{
            NSLog(@"Connect device scan by mac overtime...");
            [self onConnectDeviceCallbackIsLAN:YES withCode:CODE_TIMEOUT andTaskID:0];
        }
    }
    
}

#pragma mark 扫描回包
- (void)onConnectDeviceScanByMacBack{
    NSLog(@"Connect device scan by mac back %@.", [_deviceEntity getMacAddressString]);
    
    _isScanSuccess = YES;
    
    if (_deviceEntity.version != 1 && [_deviceEntity isDeviceInitted] == false) {
        [self onConnectDeviceCallbackIsLAN:YES withCode:CODE_DEVICE_UNINIT andTaskID:0];
    }else{
        [self performSelector:@selector(beginHandshakeWithDevice) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
    }
}

#pragma mark
#pragma mark 握手
-(void)beginHandshakeWithDevice{
    
    // 开始发包
    _isHandShakeSuccess = NO;
    [[XLinkCoreObject sharedCoreObject] handShakeWithDevice:_deviceEntity andAuthKey:_accessKey];
    
    // 设置超时
    [self performSelector:@selector(handshakeOvertime) withObject:nil afterDelay:5.0];
    
}

#pragma mark 握手超时
- (void)handshakeOvertime{
    
    if (!_isHandShakeSuccess) {
        NSLog(@"Connect device handshake overtime...");
        [self onConnectDeviceCallbackIsLAN:YES withCode:CODE_TIMEOUT andTaskID:0];
    }
    
}

#pragma mark 握手回包
- (void)onConnectDeviceHandshakeBack:(int8_t)result{
    
    _isHandShakeSuccess = YES;
    
    NSLog(@"Connect device handshake back with code %d.", result);
    
    if (result == 0) {
        
        _deviceEntity.lastGetPingReturn = [[NSDate date] timeIntervalSince1970];
        
    }
    
    // 通知外面
    [self onConnectDeviceCallbackIsLAN:YES withCode:result andTaskID:0];
}

#pragma mark
#pragma mark 订阅
- (void)beginSubscriptionWithDevice{
    NSLog(@"Connect device try subscription with device.");
    
    _isSubscriptSuccess = NO;
    
    // 尝试订阅
    if (_deviceEntity.version < 3) {
        [[XLinkCoreObject sharedCoreObject] subscribeDevice:_deviceEntity andAuthKey:_accessKey andFlag:1];
    }else{
        [[XLinkCoreObject sharedCoreObject] subscribeDevice:_deviceEntity andAuthKey:@(_deviceEntity.subKey) andFlag:1];
    }
    
    // 设置订阅超时
    [self performSelector:@selector(subscriptionDeviceOvertime) withObject:nil afterDelay:7.5];
}

#pragma mark 订阅超时
- (void)subscriptionDeviceOvertime{
    // 真正的连接超时，设备不在线
    if (!_isSubscriptSuccess) {
        NSLog(@"Connect device subscription overtime, device offline.");
        [self onConnectDeviceCallbackIsLAN:false withCode:CODE_TIMEOUT andTaskID:0];
    }
    
}

#pragma mark 订阅回包
-(void)onConnectDeviceSubscriptionBack:(SubscribeByAuthReturnPacket *)subResp {
    
    _isSubscriptSuccess = YES;
    
    NSLog(@"Connect device %d subscription back with code %d.", subResp.deviceID, subResp.code);
    if( subResp.code == CODE_SUCCEED ) {
        // 订阅成功，再次尝试probe
        NSLog(@"Connect device try probe device %d again...", subResp.deviceID);
        _deviceEntity.deviceID = subResp.deviceID;

        // 尝试Probe
        [self performSelector:@selector(beginProbeDevice) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
    } else {
        // 通知到外面
        [self onConnectDeviceCallbackIsLAN:false withCode:subResp.code andTaskID:subResp.msgID];
    }
}

#pragma mark
#pragma mark 获取SUBKEY
- (void)beginGetSubKey{
    NSLog(@"Begin Get Sub Key");
    
    _isGetSubKeySuccess = NO;
    
    // 尝试获取SUBKEY
    [[XLinkCoreObject sharedCoreObject] getSubKeyWithAccessKey:_accessKey withDevice:_deviceEntity];
    
    // 设置获取SUBKEY超时
    [self performSelector:@selector(getSubKeyOvertime) withObject:nil afterDelay:3];
}

#pragma mark 获取SUBKEY超时
- (void)getSubKeyOvertime{
    // 真正的连接超时，设备不在线
    if (!_isGetSubKeySuccess) {
        NSLog(@"Connect device get subkey overtime");
        [self onConnectDeviceCallbackIsLAN:false withCode:CODE_TIMEOUT andTaskID:0];
    }
}

#pragma mark 获取SUBKEY回包
-(void)onGotSubKeyBack:(SubKeyReturnHeader *)subResp {
    
    _isGetSubKeySuccess = YES;
    
    NSLog(@"Got Sub Key back with code %d.", subResp.code);
    if( subResp.code == CODE_SUCCEED ) {
        // 获取subkey成功，尝试订阅
        // 尝试订阅
        [self performSelector:@selector(beginSubscriptionWithDevice) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
    } else {
        // 通知到外面
        [self onConnectDeviceCallbackIsLAN:false withCode:subResp.code andTaskID:subResp.messageID];
    }
}

#pragma mark
#pragma mark probe
- (void)beginProbeDevice{
    
    _isProbeSuccess = NO;
    
    // 探测
    [[XLinkCoreObject sharedCoreObject] sendCloudProbe:_deviceEntity andFlag:0];
    
    // 设置探测超时
    [self performSelector:@selector(probeDeviceOvertime) withObject:nil afterDelay:7.5];
    
}

#pragma mark probe超时
- (void)probeDeviceOvertime{
    // 真正的连接超时，设备不在线
    if (!_isProbeSuccess) {
        NSLog(@"Connect device probe device overtime, device offline.");
        [self onConnectDeviceCallbackIsLAN:false withCode:CODE_TIMEOUT andTaskID:0];
    }
}

#pragma mark probe回包
-(void)onConnectDeviceProbeBack:(CloudProbeReturnPacket *)packet {
    
    // 取消已有的超时计时动作
    _isProbeSuccess = YES;
    
    NSLog(@"Connect device probe back with code %d.", packet.code);
    if( packet.code == CODE_UNAUTHORIZED) {
        // 订阅关系不正确，尝试订阅
        if (_deviceEntity.version >= 3 && _deviceEntity.subKey == 0) {
            [self performSelector:@selector(beginGetSubKey) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
        }else{
            NSLog(@"Connect device try subscripe device for no device id ...");
            [self performSelector:@selector(beginSubscriptionWithDevice) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
        }
        
    } else {
        
        // 如果内网没有连接上，回调出去
        [self onConnectDeviceCallbackIsLAN:false withCode:packet.code andTaskID:0];
    }
}

#pragma mark
#pragma mark 结果
-(void)onConnectDeviceCallbackIsLAN:(BOOL)isLan withCode:(int)code andTaskID:(int)taskID{
    [_lock lock];
    if (isLan) {
        if (code == 0) {
            _deviceEntity.connectStatus = (_deviceEntity.connectStatus & 0b1100) | ConnectStatusLANConnectSuccessfully;
            
            if (_deviceEntity.version >= 3 && _deviceEntity.subKey == 0 && (_deviceEntity.connectStatus & 0b1100) == ConnectStatusWANConnectFailed) {
                //v3的设备在内网连接上，没有外网的情况下，获取一次subkey;
                
            }
            
            [_deviceEntity onConnected];
            
            //连接成功只对外回调一次
            if (_deviceEntity.connectStatus != ConnectStatusLANAndWANConnectSuccessfully) {
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onConnectDevice:andResult:andTaskID:)]) {
                    [[XLinkExportObject sharedObject].delegate onConnectDevice:_deviceEntity andResult:CODE_SUCCEED andTaskID:0];
                }
            }
        }else{
            _deviceEntity.connectStatus = (_deviceEntity.connectStatus & 0b1100) | ConnectStatusLANConnectFailed;
        }
    }else{
        if (code == 0) {
            _deviceEntity.connectStatus = (_deviceEntity.connectStatus & 0b0011) | ConnectStatusWANConnectSuccessfully;
            
            [_deviceEntity onConnected];
            
            //连接成功只对外回调一次
            if (_deviceEntity.connectStatus != ConnectStatusLANAndWANConnectSuccessfully) {
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onConnectDevice:andResult:andTaskID:)]) {
                    [[XLinkExportObject sharedObject].delegate onConnectDevice:_deviceEntity andResult:CODE_SUCCEED andTaskID:0];
                }
            }
        }else{
            _deviceEntity.connectStatus = (_deviceEntity.connectStatus & 0b0011) | ConnectStatusWANConnectFailed;
        }
    }
    
    [_lock unlock];
    
    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onDeviceStatusChanged:)]) {
        [[XLinkExportObject sharedObject].delegate onDeviceStatusChanged:_deviceEntity];
    }
}

@end




/*
 93
 0000003d
 0002
 31363037 64326164 31373264 35323030
 31363037 64326164 31373264 35323031
 0002
 accf23 6ab93690 a70f4ccb a2607dbb 43581af8 1a8e041b 0001
 
 93
 0000003d
 0002
 31363037 64326164 31373264 35323030
 31363037 64326164 31373264 35323031 0600accf23 6ab93690 a70f4ccb a2607dbb 43581af8 1a8e040e 0001
 
 93
 0000003d
 0002
 31363037 64326164 31373264 35323030
 31363037 64326164 31373264 35323031
 0006
 accf236ab936
 90a70f4c cba2607d bb43581a f81a8e04
 2200
 01
 
 93
 0000003d
 0002
 31363037 64326164 31373264 35323030
 31363037 64326164 31373264 35323031
 0006
 accf236ab936
 90a70f4c cba2607d bb43581a f81a8e04
 000c
 01
 
 93
 0000003d
 0002
 31363037 64326164 31373264 35323030 
 31363037 64326164 31373264 35323031
 0006
 accf236ab936
 90a70f4c cba2607d bb43581a f81a8e04
 0021
 05
 
 93
 0000003d
 0020
 31363037 64326164 31373264 35323030
 31363037 64326164 31373264 35323031
 0006
 accf236ab936
 90a70f4c cba2607d bb43581a f81a8e04
 001d
 05
 
 93             包头10010011
 0000003d       包数据长度
 0020           产品ID长度
 31363037 64326164 31373264 35323030
 31363037 64326164 31373264 35323031    产品ID
 0006           MAC长度
 accf236ab936   MAC
 90a70f4c cba2607d bb43581a f81a8e04    Authkey
 0014           Message ID
 05             Flags 0101 使用subKey
 */





