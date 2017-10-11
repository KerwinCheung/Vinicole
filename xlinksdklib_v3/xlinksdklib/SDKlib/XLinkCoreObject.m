    //
//  XLinkCoreObject.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/25.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "XLinkCoreObject.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "AsyncUdpSocket.h"
#import "SDKHeader.h"
#import "SenderEngine.h"
#import "PacketParseEngine.h"
#import "XlinkMessage.h"
#import "FixHeader.h"
#import "XLinkExportObject.h"
#import "ConnectDeviceTask.h"
#import "XLReachability.h"
#import "AutoReloginTask.h"
#import "DeviceEntity.h"
#import "MessageTraceItem.h"
#import "SDKProperty.h"

NSString * const XLinkSyncDeviceNotification = @"DeviceSyncNotification";


NSString * const XLinkDeviceListUpdateNotification = @"DeviceListUpdateNotification";


static XLinkCoreObject * shareCoreObject;


@interface XLinkCoreObject ()<packParseEngineDelegate>

@end

@implementation XLinkCoreObject
{
    
    NSMutableDictionary *_ip_Devices;
    
    NSMutableDictionary *_all_device;
    
    unsigned short _listenPort;
    
    int _currentVersion;
    int _currerntAppID;
    NSString * _currentAuthStr;
    
    unsigned short _messageID;
    
    NSMutableDictionary *_messageTrace;
    
    NSMutableDictionary *_messageQueue;
    
    NSMutableArray <ConnectDeviceTask *> *_connectDeviceTaskList;
    
    int _keepAliveInterval;
    NSTimer *_pingTimer;
    BOOL _isUserStop;
    BOOL _isServerKicked;
    BOOL _isLoginUnauthorized;
    BOOL _isDelayThreadRun;
    NSThread *_delayThread;
    
    struct {
        unsigned short isStarted:1;
    }_flag;
    
    XLReachability * _networkReachability;
    
    // 自动重新连接的任务
    AutoReloginTask * _autoReloginTask;
}

-(SenderEngine *)senderEngine{
    
    return [SenderEngine sharedEngine];
}

+(XLinkCoreObject *)sharedCoreObject{
    
    @synchronized(self){
        if (shareCoreObject==nil) {
           shareCoreObject = [[XLinkCoreObject alloc]init];
        }
    }
    return shareCoreObject;
    
}

//初始化函数
-(id)init{
    self = [super init];
    if (self) {
        
        //默认的监听端口号
        _listenPort = 0;
        // 用户登录过吗
//        _userLogined = NO;
        //设置当前的设备ID
        _currerntAppID = -1;
        //设置当前的消息ID
        _messageID = 10;
        //消息跟踪字典
        _messageTrace = [[NSMutableDictionary alloc]init];
        //
        _messageQueue = [[NSMutableDictionary alloc]init];
        //连接任务的队列
        _connectDeviceTaskList  = [[NSMutableArray alloc]init];
        
        self.isLoginSuccessed = NO;
        self.isTcpConnected = NO;
        _flag.isStarted = NO;
        
        //
        _keepAliveInterval = 30;
        
        //
        _isUserStop = NO;
        
    }
    return self;
}

-(void)setListenPort:(int)port{
    _listenPort = port;
}

-(int)getListenPort{
    return _listenPort;
}
// 设置监听端口 初始化[XLinkCoreObject shareObject]  初始化[SenderEngine sharedEngine]
-(int)start{
   
    _isServerKicked = NO;
    _isLoginUnauthorized = NO;
    _isUserStop = NO;
    
    _isDelayThreadRun = YES;
    
    [[SenderEngine sharedEngine] start];
    
    [self registerNetworkNotify];
    
    return 0;
    
}

-(void)clearDeviceList {
    for (ConnectDeviceTask *connectDeviceTask in _connectDeviceTaskList) {
        [connectDeviceTask.deviceEntity stopHeatBeat];
    }
    
    if (_connectDeviceTaskList != nil) {
        [_connectDeviceTaskList removeAllObjects];
    }
}

- (BOOL)needCheckSendOvertime {
    if( [[SDKProperty sharedProperty] getProperty:PROPERTY_SEND_OVERTIME_CHECK] ) {
        return [[[SDKProperty sharedProperty] getProperty:PROPERTY_SEND_OVERTIME_CHECK] boolValue];
    }
    return YES;
}


//-(void)sendSetWithDevice:(DeviceEntity *)aDevice withSessionID:(int)aSessionID withMessageID:(int)aMsgID{
//    
//    if (!aDevice) {
//        return;
//    }
//    
//    [[SenderEngine sharedEngine] sendSetDevice:aDevice andSessionID:aSessionID andMesaageID:aMsgID];
//    
//}

-(void)sendByeByeSessionID:(int)aSessionID withDevice:(DeviceEntity *)aDevice{
    
    if (aSessionID<0) {
        return;
    }
    
    [[SenderEngine sharedEngine] sendByeBye:aSessionID andDevice:aDevice];
    
}

-(void)sendPingWithSessionID:(int)aSessionID andDevice:(DeviceEntity *)adevice{
    
    if (aSessionID<0) {
        return;
    }
    
    [[SenderEngine sharedEngine] sendPingWithSessionID:aSessionID andDevice:adevice];
    
}

-(void)sendProbeWithSessionID:(int)aSessionID andDevice:(DeviceEntity *)aDevice{
    
    if (aSessionID<0) {
        return;
    }
    
    [[SenderEngine sharedEngine] sendProbeWithSessionID:aSessionID andDevice:aDevice];
    
}

-(void)startHeartBeatWithSessionID:(int)assessionID andDevice:(DeviceEntity *)aDevice{
    if (assessionID<0) {
        return;
    }
    
    if (!aDevice) {
        return;
    }
    
    [[SenderEngine sharedEngine] sendPingWithSessionID:assessionID andDevice:aDevice];
    
}

-(void)initDevice:(DeviceEntity *)device{

    NSLog(@"SDK初始化设备 %@ %d ...", [device getMacAddressString], [device getDeviceID]);
    
    if (_connectDeviceTaskList) {
        if (_connectDeviceTaskList.count>0) {
            for (int i = 0; i < _connectDeviceTaskList.count; i++) {
                DeviceEntity *temp = _connectDeviceTaskList[i].deviceEntity;
                if ([temp.macAddress isEqualToData:device.macAddress]) {
                    _connectDeviceTaskList[i].deviceEntity = device;
                    
//                    temp.macAddress = device.macAddress;
//                    temp.fromIP = device.fromIP;
//                    temp.flag = device.flag;
//                    if( device.deviceID > 0 ) {
//                        temp.deviceID = device.deviceID;
//                    }
                    return;
                }
            }
            
            [_connectDeviceTaskList addObject:[[ConnectDeviceTask alloc] initWithDevice:device]];
            
        }else{
            
            [_connectDeviceTaskList addObject:[[ConnectDeviceTask alloc] initWithDevice:device]];
            
        }
        
        
    }else{
        
        _connectDeviceTaskList = [[NSMutableArray alloc] initWithObjects:[[ConnectDeviceTask alloc] initWithDevice:device], nil];
        
    }
}

-(void)stopHeart{
    [[SenderEngine sharedEngine] stopHeart];
}

-(int)getAppID{
    return _currerntAppID;
}

-(NSThread *)getDelayThread{
    if (_delayThread) {
        return _delayThread;
    }else{
        if (_isDelayThreadRun) {
            _delayThread = [[NSThread alloc] initWithTarget:self selector:@selector(startDelayThread) object:nil];
            [_delayThread start];
            return _delayThread;
        }else{
            return nil;
        }
    }
}

-(void)startDelayThread{
    [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:self selector:@selector(ignore) userInfo:nil repeats:YES];
    
    [NSThread currentThread].name = @"Xlink Delay Thread";
    NSRunLoop *curRunLoop = [NSRunLoop currentRunLoop];
    
    while (_isDelayThreadRun && [curRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        
    }
    
    _delayThread = nil;
    
}

-(void)ignore{}

#pragma mark
#pragma mark 获取连接任务
-(ConnectDeviceTask *)getConnectDeviceTaskByDeviceMacAddress:(NSData *)macData{
    for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
        ConnectDeviceTask *task = _connectDeviceTaskList[i];
        if ([task.deviceEntity.macAddress isEqualToData:macData]) {
            return task;
        }
    }
    return nil;
}

-(ConnectDeviceTask *)getConnectDeviceTaskByDeviceID:(int)device{
    for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
        ConnectDeviceTask *task = _connectDeviceTaskList[i];
        if ([task.deviceEntity getDeviceID] == device) {
            return task;
        }
    }
    return nil;
}

#pragma mark
#pragma mark 获得设备方法
-(DeviceEntity *)getDeviceByMacAddress:(NSData *)macData{
    
    return [self getConnectDeviceTaskByDeviceMacAddress:macData].deviceEntity;

}

-(DeviceEntity *)getDeviceByDeviceID:(int)device{
    
    return [self getConnectDeviceTaskByDeviceID:device].deviceEntity;
    
}

#pragma mark
#pragma mark 扫描

//-(void)scanByDeviceMacAddress:(NSString *)macAddress withVersion:(uint8_t)version andDelegate:(id<ScanDeviceDelegate>)dlgt{
//    
//    [PacketParseEngine shareObject].scanByMacDelegate = dlgt;
//    [[SenderEngine sharedEngine] sendScanWithMacAddress:macAddress withVersion:version];
//    
//}

//-(void)scanNeiWangDeviceWithMacAddress:(NSString *)macAddress{
//
//    [[SenderEngine sharedEngine] sendScanWithMacAddress:macAddress];
//    
//}

-(void)scanByDeviceProductID:(NSString *)productID andDelegate:(id<ScanDeviceDelegate>)dlgt{
    
    [PacketParseEngine shareObject].scanDelegate = dlgt;
//    [PacketParseEngine shareObject].productIDFilter = productID;
    [self scanNeiWangDeviceWithProductID:productID];
    
}

-(void)scanNeiWangDeviceWithProductID:(NSString *)productID{
    [[SenderEngine sharedEngine] sendScanWithProductID:productID];
}

#pragma mark
#pragma mark 外网
-(void)connectExternal:(NSString *)aIp andPort:(int)aPort{
    [[SenderEngine sharedEngine] connectExternal:aIp andPort:aPort];
}

-(void)loginWithAppID:(int)appId andAuthStr:(NSString *)authStr andKeepLive:(int)aKeepLive{
    _keepAliveInterval = aKeepLive;
    _isUserStop = NO;
    _isServerKicked = NO;
    _isLoginUnauthorized = NO;
    [self loginWithVersion:3 andAppID:appId andAuthLength:16 andAuthStr:authStr andKeepLive:aKeepLive];
   
}

-(void)loginWithVersion:(int)aVersion andAppID:(int)appId andAuthLength:(int)alen andAuthStr:(NSString *)authStr andKeepLive:(int)aKeepLive{
    _currentVersion = aVersion;
    _currerntAppID = appId;
    _currentAuthStr = [[NSString alloc] initWithString: authStr];
    [[SenderEngine sharedEngine] loginWithVersion:aVersion andAppID:appId andAuthLength:alen andAuthStr:authStr andKeepLive:aKeepLive];
}

-(void)logout{
    _isUserStop = YES;
    _isServerKicked = NO;
    [[SenderEngine sharedEngine] sendDisconnectCM];
    [[SenderEngine sharedEngine] closeCloud];
}

-(void)autoRelogin:(BOOL)now {
    if( _isLoginSuccessed ) {
        return;
    }
    
    if( _isUserStop ) {
        NSLog(@"User stop, do not auto relogin!");
        return;
    }
    
    if (_isLoginUnauthorized) {
        NSLog(@"Server Unauthorized! Do not auto relogin!");
        return;
    }
    
    if (_isServerKicked) {
        NSLog(@"Server kicked! Do not auto relogin!");
        return;
    }
    
    if(_currerntAppID != 0 && _currentAuthStr != nil && _currentAuthStr.length > 0 ) {
        // 没有就创建一个
        if( _autoReloginTask == nil ) {
            _autoReloginTask = [[AutoReloginTask alloc] initWithLoginVersion:_currentVersion AppID:_currerntAppID AuthStr:_currentAuthStr andKeepAliveInterval:_keepAliveInterval];
        }
        if( now ) {
            [_autoReloginTask autoReloginRightNow];
        } else {
            [_autoReloginTask autoRelogin];
        }
    } else {
        NSLog(@"Auto relogin can not be access for invalid param.");
    }
}

-(void)loginResponsed:(int)code {
    if( _autoReloginTask ) {
        [_autoReloginTask onLoginResponsedWithCode:code];
    }
    
    if( code == 0 ) {
        for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
            ConnectDeviceTask *task = _connectDeviceTaskList[i];
            [task.deviceEntity onAppLogined];
        }
    }
}

-(void)appLogout{
    for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
        ConnectDeviceTask *task = _connectDeviceTaskList[i];
        [task.deviceEntity onAppLogout];
    }
}

-(void)pipeWithDeviceID:(int)deviceID andMessageID:(int)aMsgID andMessageFlag:(int)aFlag andPlayData:(NSData *)playdata{
    
    [[SenderEngine sharedEngine] senderpipeWithDeviceID:deviceID andMessageID:aMsgID andMessageFlag:aFlag andPlaydata:playdata];

}

-(int)sendCloudProbe:(DeviceEntity *)device andFlag:(int)flag{
    unsigned short msgID = [self getMessageID];
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SEND_CLOUD_PROBE;
    [[XLinkCoreObject sharedCoreObject] setMessageTraceObject:device andMessage:msgID];
    [_messageQueue setObject:m forKeyedSubscript:[NSString stringWithFormat:@"%d",msgID]];
    
    [[SenderEngine sharedEngine] sendCloudProbeWithDevice:device andMessageID:msgID andFlag:flag];
    
    // 超时不妨在这里处理
    // [m checkTimeOut];
    
    return msgID;
}

#pragma mark
#pragma mark>>>>>>>>start内网
-(int)sendLocalPipeWithDevice:(DeviceEntity *)device andPayload:(NSData *)payload andFlag:(int)flag{
    if (!device) {
        return -1;
    }
    
    unsigned short msgID = [[XLinkCoreObject sharedCoreObject] getMessageID];
    
    return [self sendLocalPipeWithDevice:device andPayload:payload andFlag:flag withMsgID:msgID];
}

-(int)sendLocalPipeWithDevice:(DeviceEntity *)device andPayload:(NSData *)payload andFlag:(int)flag withMsgID:(int)msgID{
    if (!device) {
        return -1;
    }
    
    [[XLinkCoreObject sharedCoreObject] setMessageTraceObject:device andMessage:msgID];
    
    // 确定是否需要跟踪超时
    if( [self needCheckSendOvertime ] ) {
        XlinkMessage *m = [[XlinkMessage alloc]init];
        m.messageID = msgID;
        m.messageType = MSG_TYPE_SEND_LOCAL_PIPE;
        [_messageQueue setObject:m  forKey:[NSString stringWithFormat:@"%d",msgID]];
        [m checkTimeOut];
    }
    
    [[SenderEngine sharedEngine] sendLocalPipeWithDevice:device andMessageID:msgID andPayload:payload andFlag:flag];
    
    return msgID;
}

-(int)sendLocalProbeWithDevice:(DeviceEntity *)device andFlag:(int)flag{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    [[SenderEngine sharedEngine] sendLocalProbeWithDevice:device];
    
    return 0;
}

-(int)sendLocalSetWithDevice:(DeviceEntity *)device{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    return 0;
}

-(int)setAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    unsigned short msgID = [self getMessageID];
    
    XlinkMessage *m = [[XlinkMessage alloc] init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SEND_SET_ACK;
    
    [self setMessageTraceObject:@{@"device" : device, @"accessKey" : accessKey} andMessage:msgID];
    [_messageQueue setObject:m forKey:@(msgID).stringValue];
    
    [[SenderEngine sharedEngine] sendSetAccessKey:accessKey withDevice:device withMessageID:msgID withFlag:0];
    
    return msgID;
    
}

-(unsigned short)setLocalDataPoints:(NSArray<DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device{
    short msgID = [self getMessageID];
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SET_DATAPOINT;
    [[XLinkCoreObject sharedCoreObject] setMessageTraceObject:device andMessage:msgID];
    [_messageQueue setObject:m forKeyedSubscript:[NSString stringWithFormat:@"%d",msgID]];
    
    [[SenderEngine sharedEngine] sendSetLocalDataPoints:dataPoints withDevice:device withMessageID:msgID];
    return msgID;
}


-(unsigned short)setCloudDataPoints:(NSArray<DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device{
    short msgID = [self getMessageID];
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SET_DATAPOINT;
    [[XLinkCoreObject sharedCoreObject] setMessageTraceObject:device andMessage:msgID];
    [_messageQueue setObject:m forKeyedSubscript:[NSString stringWithFormat:@"%d",msgID]];
    
    [[SenderEngine sharedEngine] sendSetCloudDataPoints:dataPoints withDevice:device withMessageID:msgID];
    return msgID;
}

-(void)getSubKeyWithAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device{
//    short msgID = [self getMessageID];
    short msgID = 1234;
    XlinkMessage *m = [[XlinkMessage alloc] init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_GET_SUBKEY;
    
    [self setMessageTraceObject:device andMessage:msgID];
    [_messageQueue setObject:m forKey:@(msgID).stringValue];
    
    [[SenderEngine sharedEngine] getSubKeyWithAccessKey:accessKey withDevice:device withMessageID:msgID];
    
}

-(int)setLocalDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthCode:(NSNumber *)oldAuth andNewAuthCode:(NSNumber *)newAuth{
    
    if (device== nil) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (!newAuth) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    unsigned short msgID =[self getMessageID];
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SET_LOCAL_AUTH;
    
    [self setMessageTraceObject:device andMessage:msgID];
    [_messageQueue setObject:m forKey:[NSString stringWithFormat:@"%d",msgID]];
    
    //[[SenderEngine sharedEngine] sendLocalSetDeviceAuthorize:device andOldAuthKey:oldAuth andNewAuthKey:newAuth andFlag:0];
    [[SenderEngine sharedEngine] sendLocalSetDeviceAuthorize:device andMessageID:msgID andOldAuthKey:oldAuth andNewAuthKey:newAuth andFlag:0];
    
    [m checkTimeOut];
    
    return msgID;
    
}

- (void)handShakeWithDevice:(DeviceEntity *)device {
    if (device== nil)
        return;
        
     //[[SenderEngine sharedEngine] sendLocalHandShake:device andVersion:1 andAuthKey:authKey andFlag:0];
    
}

//握手
-(void)handShakeWithDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey{
    if (device== nil) {
        return;
    }
    
    if(!authKey){
        return;
    }
    
    short msgID = [self getMessageID];
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SEND_LOCAL_HANK;
    
    [self setMessageTraceObject:device andMessage:msgID];
    [_messageQueue setObject:m forKey:[NSString stringWithFormat:@"%d",msgID]];
    
    [[SenderEngine sharedEngine] sendLocalHandShake:device withMessageID:msgID andVersion:device.version andAuthKey:authKey andFlag:0];
    
    [m checkTimeOut];
    
}

//-(void)sendSetDevicePropertyViaLocal:(DeviceEntity *)device andFlag:(int)flag{
//    if(!device){
//        return;
//    }
//    
//    unsigned short messageID = [self getMessageID];
//    [self setMessageTraceObject:device andMessage:messageID];
//    
//    [self sendSetDevicePropertyViaLocal:device andMessageID:messageID andFlag:flag];
//}

//-(void)sendSetDevicePropertyViaLocal:(DeviceEntity *)device andMessageID:(int)messageID andFlag:(int)flag{ƒ
//    if(!device){
//        return;
//    }
//    
//    [[SenderEngine sharedEngine] sendLocalSetDevicePropertyWithDevice:device andMessageID:messageID andFlag:flag];
//
//}

-(void)sendProbeViaLocal:(DeviceEntity *)device{
    if(!device){
        return;
    }
    
    [[SenderEngine sharedEngine] sendLocalProbeWithDevice:device];
    
}

-(void)onServerKicked {
    
    _isServerKicked = YES;  // 阻止自动登录
    
    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
        [[XLinkExportObject sharedObject].delegate onNetStateChanged:CODE_STATE_KICK_OFFLINE];
    }
    if( [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onLogin:)]) {
        [[XLinkExportObject sharedObject].delegate onLogin:CODE_SERVER_KICK_DISCONNECT];
    }
    [self appLogout];
}

- (void)onLoginUnauthorized {
    _isLoginUnauthorized = YES;    // 阻止自动登录
}


#pragma mark
#pragma mark<<<<<<<<end 内网



#pragma mark
#pragma mark>>>>>>>>start外网
-(int)subscribeDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey andFlag:(int8_t)flag{
    
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    if (device.productID.length!=32) {
        return CODE_FUNC_DEVICE_ERROR;
    }
    
//    if (device.macAddress.length!=6) {
//        return CODE_FUNC_DEVICE_MAC_ERROR;
//    }
    
    int msgID = [[XLinkCoreObject sharedCoreObject] getMessageID];
    [self setMessageTraceObject:device andMessage:msgID];
    
    
    XlinkMessage *m= [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SUBSCRIBE_CLOUD;
    [_messageQueue setObject:m forKey:[NSString stringWithFormat:@"%d",msgID]];
    
    
    [[SenderEngine sharedEngine] sendCloudSubscribeDevice:device andAuthKey:authKey andMessageID:msgID andFlag:flag];
    [m checkTimeOut];
    return msgID;
}

-(int)setDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth{
    
    if (!device) {
        return -1;
    }
    
    if (!oldAuth) {
        return -1;
    }
    
    if (!newAuth) {
        return -1;
    }
    
    unsigned short msgID = [[XLinkCoreObject sharedCoreObject] getMessageID];
    [self setMessageTraceObject:device andMessage:msgID];
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = msgID;
    m.messageType = MSG_TYPE_SET_CLOUD_AUTH;
    [_messageQueue setObject:m forKey:[NSString stringWithFormat:@"%d",msgID]];
    
    [[SenderEngine sharedEngine] sendSetDeviceAuthorize:device andMessageID:msgID andOldAuthKey:oldAuth andNewAuthKey:newAuth andFlag:0];
    
    [m checkTimeOut];
    
    return msgID;

}


-(void)setDevicePropertyViaCloud:(DeviceEntity *)device andFlag:(int)flag{
    if (!device) {
        return;
    }
    
    unsigned short messageID = [self getMessageID];
    [self setMessageTraceObject:device andMessage:messageID];
    [self setDevicePropertyViaCloud:device andMessageId:messageID andFlag:flag];
}

-(void)setDevicePropertyViaCloud:(DeviceEntity *)device andMessageId:(int)messageID andFlag:(int)flag{
    
    [[SenderEngine sharedEngine] sendCloudSetPropertyWithDevice:device andMessageID:messageID andFlag:flag];
    
}

-(int)sendCloudPipe:(DeviceEntity *)device andPayload:(NSData *)payload{

    if (!device) {
        return -1;
    }
    
    unsigned short messageID = [self getMessageID];
    
    [self setMessageTraceObject:device andMessage:messageID];
    device.messageType = MSG_TYPE_SEND_CLOUD_PIPE;
    
    XlinkMessage *m = [[XlinkMessage alloc]init];
    m.messageID = messageID;
    m.messageType = MSG_TYPE_SEND_CLOUD_PIPE;
    
    [_messageQueue setObject:m forKey:[NSString stringWithFormat:@"%d",messageID]];
    
    [[SenderEngine sharedEngine] senderpipeWithDeviceID:device.deviceID andMessageID:messageID andMessageFlag:0 andPlaydata:payload];
    
    [m checkTimeOut];
    
    return messageID;
    
}

-(void)sendProbeViaCloud:(DeviceEntity *)device andMessageID:(int)messageID andFlag:(int)flag{
    if (!device) {
        return;
    }
    
    [[SenderEngine sharedEngine] sendCloudProbeWithDevice:device andMessageID:messageID andFlag:flag];
    
    
}

-(int)sendCloudPropertySetWithDevice:(DeviceEntity *)device{
    if (!device) {
        return CODE_FUNC_PARAM_ERROR;
    }
    
    return 0;
}

#pragma mark
#pragma mark>>>>>>>>end外网
//生成消息ID
-(unsigned short)getMessageID{
    
    _messageID++;
    
    if (_messageID>65534) {
        _messageID=10;
    }
    
    return _messageID;
    
}

//对象消息绑定
-(void)setMessageTraceObject:(id)object andMessage:(unsigned short)msgID{
    
     if(_messageTrace == nil){
        _messageTrace = [[NSMutableDictionary alloc]init];
    }
    
    MessageTraceItem * traceItem = [[MessageTraceItem alloc] initWithObject:object andMessageID:msgID];
    [_messageTrace setObject:traceItem forKey:[NSString stringWithFormat:@"%d",msgID]];
    
}

-(void)removeMessageByMessageID:(int)message{
    
    if (_messageTrace) {
        [_messageTrace removeObjectForKey:[NSString stringWithFormat:@"%d",message]];
        [_messageQueue removeObjectForKey:[NSString stringWithFormat:@"%d",message]];
    }else{
        _messageTrace = [[NSMutableDictionary alloc]init];
        _messageQueue = [[NSMutableDictionary alloc]init];
    }
    
}

//app心跳包
-(void)pingCloud{
    
    [[SenderEngine sharedEngine] pingCloud];
    
    if (!_pingTimer) {
        [self performSelector:@selector(startPingTimer) onThread:[self getDelayThread] withObject:nil waitUntilDone:YES];
    }
    
    [_pingTimer fire];
    
}

-(void)startPingTimer{
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:_keepAliveInterval target:self selector:@selector(pingMethod:) userInfo:nil repeats:YES];
}

-(void)stopPingCloud{
    
    [_pingTimer invalidate];
    _pingTimer = nil;
    
}


-(int)sendLocalByeBye:(DeviceEntity *)device{
    
    if(!device){
        return CODE_FUNC_PARAM_ERROR;
    }
    
    FixHeader *byeBye = [[FixHeader alloc] initWithInfo:BYBBYE_REQ_FLAG andDataLen:2];
    
    unsigned short sessionID = device.sessionID;
    sessionID = htons(sessionID);
    
    NSMutableData *sendData = [byeBye getPacketData];
    [sendData appendBytes:&sessionID length:2];
    
    [[SenderEngine sharedEngine] udpSendDevice:device andData:sendData];
    
    return 0;

}



-(void)pingMethod:(id)sender{
    
      NSLog(@"ping cloud");
     [[SenderEngine sharedEngine] pingCloud];

}

-(int)pipeWithDevice:(DeviceEntity *)device andMessageFlag:(int)flag andPlayData:(NSData *)playdata{
    
    if (device ==nil) {
        NSLog(@"nil device in pipeWithDevice");
        return -1;
    }

    int msgID  = [[XLinkCoreObject sharedCoreObject] getMessageID];
    [self setMessageTraceObject:device andMessage:msgID];
    [self pipeWithDeviceID:[device getDeviceID] andMessageID:[[XLinkCoreObject sharedCoreObject] getMessageID] andMessageFlag:flag andPlayData:playdata];
    return msgID;
    
}

-(MessageTraceItem *)getMessageTraceItem:(short)messageID {
    return [_messageTrace objectForKey:[NSString stringWithFormat:@"%d",messageID]];
}

-(DeviceEntity *)getMessageDeviceByMessageID:(short)messageID{
    
    MessageTraceItem * traceItem = [_messageTrace objectForKey:[NSString stringWithFormat:@"%d",messageID]];
    if( traceItem == nil ) {
        return nil;
    }
    id object = [traceItem object];
    if( [object isKindOfClass:[DeviceEntity class]] ) {
        return (DeviceEntity *)object;
    }
    return nil;
}

- (void)onMessageTraceResponse:(short)messageID {
    MessageTraceItem * traceItem = [[XLinkCoreObject sharedCoreObject] getMessageTraceItem:messageID];
    if( traceItem != nil ) {
        [traceItem onMessageResponse];
    }
}

//-(void)ticketWithSessionID:(int)aSessionID andAppID:(int)appID andMessageID:(int)aMsgID andFlag:(int)aFlag andDevice:(DeviceEntity *)adevice{
//    [[SenderEngine sharedEngine] ticketWithSessionID:aSessionID andAppID:appID andMessageID:aMsgID andFlag:aFlag andDevice:adevice];
//}

//停止清理操作
-(void)stop{
    _isUserStop = YES;
    _isServerKicked = NO;
    _isDelayThreadRun = NO;
    [self performSelector:@selector(ignore) onThread:_delayThread withObject:nil waitUntilDone:YES];
    [self unregisterNetworkNotify];
    [self stopPingCloud];
    //停止发送设备心跳包
    for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
        ConnectDeviceTask *task = _connectDeviceTaskList[i];
        [task.deviceEntity userDisconnect];
    }
    [_connectDeviceTaskList removeAllObjects];
    [[SenderEngine sharedEngine] sendDisconnectCM];
    [[SenderEngine sharedEngine] closeCloud];
    [[SenderEngine sharedEngine] stop];
//    [[SenderEngine sharedEngine] uninitUdpSocket];
}

-(void)onSetDeviceAuthCode:(DeviceEntity *)device withResult:(int)result {
    if( result == 0 ) {
        if( device != nil ) {
            [device setDeviceInit:YES];
        }
    }
}

#pragma mark 重新连接设备

/**
 *
 */
-(void)reconnectDevices {
    for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
        ConnectDeviceTask *task = _connectDeviceTaskList[i];
        [task.deviceEntity onNetworkChange];
    }
}

-(void)reconnectDevice:(DeviceEntity *)device {
    NSLog(@"Auto reconnect device %@ ...", [device getMacAddressString]);
    for (NSUInteger i = 0; i < _connectDeviceTaskList.count; i++) {
        ConnectDeviceTask *task = _connectDeviceTaskList[i];
        if ([task.deviceEntity.macAddress isEqualToData:device.macAddress]) {
            [task connectWithAccessKey:task.accessKey];
            break;
        }
    }
}


-(void)onSessionIdError:(DeviceEntity *)device {
    // 直接开始重练设备
    // 这个动作一定要在主线程内发起
//    [[XLinkCoreObject sharedCoreObject] performSelectorOnMainThread:@selector(reconnectDevice:) withObject:device waitUntilDone:NO];
    [[XLinkCoreObject sharedCoreObject] reconnectDevice:device];
    
}

#pragma mark 网络监控

-(void)registerNetworkNotify {
    //注册网络变化监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kXLReachabilityChangedNotification object:nil];
    
    // Set up Reachability
    _networkReachability = [XLReachability reachabilityForInternetConnection];
    [_networkReachability startNotifier];
}

-(void)unregisterNetworkNotify {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)checkNetworkStatus:(NSNotification *)notify {
    
    XLNetworkStatus internetStatus = [_networkReachability currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case XLNotReachable:
        {
            NSLog(@"The internet is down.");
            
            // 外网中断了，尝试内网连接一下
            [self reconnectDevices];
            break;
        }
        case XLReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI");
            [self autoRelogin:YES];
            
            // 网络切换了，重新连接一下设备
//            if( _isLoginSuccessed ) {
                [self reconnectDevices];
//            }
            break;
        }
        case XLReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN!");
            [self autoRelogin:YES];
            
            // 网络切换了，重新连接一下设备
            [self reconnectDevices];
            break;
        }
    }
}


@end
