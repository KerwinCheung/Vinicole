//
//  XLinkCoreObject.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/25.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"
#import "SenderEngine.h"

@class DataPointEntity;

/*
 *@discussion
 * 通知常量声明
 */

extern NSString * const XLinkSyncDeviceNotification;
extern NSString * const XLinkGetDeviceNotification;
extern NSString * const XLinkDeviceListUpdateNotification;



#define ExtLoginState @"extLoginState"

@class ConnectDeviceTask;
@class MessageTraceItem;

/*
 sdk接口
 */


@protocol ScanDeviceDelegate <NSObject>

-(void)scanGotDeviceEntity:(DeviceEntity *)device;

@end

@interface XLinkCoreObject : NSObject


/*
 *@discussion
 *  xlink 代理
 */
@property (nonatomic,retain,readonly)NSMutableArray *allDeviceKey;
@property (nonatomic,assign)BOOL isLoginSuccessed;
@property (nonatomic,assign)BOOL isTcpConnected;
@property (nonatomic,assign)double lastGetPingReturn;

+(XLinkCoreObject *)sharedCoreObject;

-(NSThread *)getDelayThread;

/**
 * 获取SDK的APP ID
 */
-(int)getAppID;

-(void)initDevice:(DeviceEntity *)device;

//得到连接任务
-(ConnectDeviceTask *)getConnectDeviceTaskByDeviceMacAddress:(NSData *)macData;
-(ConnectDeviceTask *)getConnectDeviceTaskByDeviceID:(int)device;

/*
 *@discussion
 *  通过Macstr  得到设备
 */
-(DeviceEntity *)getDeviceByMacAddress:(NSData *)macData;
-(DeviceEntity *)getDeviceByDeviceID:(int)device;

/*
 *@discussion
 *  设置设置设备的属性
 */
//-(void)sendSetWithDevice:(DeviceEntity *)aDevice withSessionID:(int)aSessionID withMessageID:(int)aMsgID;


//进入后台调用的操作
//-(void)enterBackground;

//进入前台调用的操作
//-(void)enterForeground;

/**
 *  清理本地设备数据列表
 */
-(void)clearDeviceList;

/*
 *@discussion
 * 停止心跳
 */
-(void)stopHeart;

//设计监听的随机可用的端口如果没设置 SDK默认设端口号
-(void)setListenPort:(int)port;

//获得监听的端口
-(int)getListenPort;

//开始初始化操作 监听的app本地UDP端口 用于SDK监听WiFi设备数据回包
//note: 理论上该端口是随机得到当前可用的端口
-(int)start;

//通过设备Mac地址扫描设备 设置扫描的回调代理
//-(void)scanByDeviceMacAddress:(NSString *)macAddress withVersion:(uint8_t)version andDelegate:(id<ScanDeviceDelegate>)dlgt;

//通过产品ID扫描设备 设置扫描的回调代理
-(void)scanByDeviceProductID:(NSString *)productID andDelegate:(id<ScanDeviceDelegate>)dlgt;

//清理操作 关掉远程端口 清除掉缓存设备
-(void)stop;

//登陆外网
-(void)loginWithAppID:(int)appId andAuthStr:(NSString *)authStr andKeepLive:(int)aKeepLive;

//登出
-(void)logout;

// 自动重练
-(void)autoRelogin:(BOOL)now;

/**
 *  Login包有返回了，用来终止自动重练的过程
 */
-(void)loginResponsed:(int)code;

//app被断掉
-(void)appLogout;

//订阅设备
// -(void)subscriptionWithDevice:(DeviceEntity *)device andFlag:(int)flag;

//云端透传数据
-(int)pipeWithDevice:(DeviceEntity *)device andMessageFlag:(int)flag andPlayData:(NSData *)playdata;

-(MessageTraceItem *)getMessageTraceItem:(short)messageID;

//通过消息获得发送的device
-(DeviceEntity *)getMessageDeviceByMessageID:(short)messageID;

- (void)onMessageTraceResponse:(short)messageID;

//生产messageID
-(unsigned short)getMessageID;

//设置指定的消息对象
-(void)setMessageTraceObject:(id)object andMessage:(unsigned short)msgID;

-(void)removeMessageByMessageID:(int)message;

-(int)sendCloudPipe:(DeviceEntity *)device andPayload:(NSData *)payload;

//ping云端
-(void)pingCloud;

//停止ping云
-(void)stopPingCloud;

//通过local向设备发送下线
-(int)sendLocalByeBye:(DeviceEntity *)device;


//通过local向设备发送设备包
-(int)sendLocalSetWithDevice:(DeviceEntity *)device;

//发送本地透传包
-(int)sendLocalPipeWithDevice:(DeviceEntity *)device andPayload:(NSData *)payload andFlag:(int)flag;
-(int)sendLocalPipeWithDevice:(DeviceEntity *)device andPayload:(NSData *)payload andFlag:(int)flag withMsgID:(int)msgID;

//发送本地探测包
-(int)sendLocalProbeWithDevice:(DeviceEntity *)device andFlag:(int)flag;


//发送云端探测
-(int)sendCloudProbe:(DeviceEntity *)device andFlag:(int)flag;

//发送云端属性设置
-(int)sendCloudPropertySetWithDevice:(DeviceEntity *)device;

//本地绑定设备
-(int)setAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device;

//本地设置DataPoint
-(unsigned short)setLocalDataPoints:(NSArray <DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device;

//云端设置DataPoint
-(unsigned short)setCloudDataPoints:(NSArray <DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device;

//获取subkey
-(void)getSubKeyWithAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device;

//设置本地设备的新密码
-(int)setLocalDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthCode:(NSNumber *)oldAuth andNewAuthCode:(NSNumber *)newAuth;

//握手，新版本
-(void)handShakeWithDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey;

//订阅设备
-(int)subscribeDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey andFlag:(int8_t)flag;

//通过云端
-(int)setDeviceAuthorizeCode:(DeviceEntity *)device andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth;

//云端属性设置
-(void)setDevicePropertyViaCloud:(DeviceEntity *)device andFlag:(int)flag;

//////////////////////

//-(void)sendSetDevicePropertyViaLocal:(DeviceEntity *)device andFlag:(int)flag;

-(void)sendProbeViaLocal:(DeviceEntity *)device;

/**
 *  设备被网关
 */
-(void)onServerKicked;

-(void)onLoginUnauthorized;

/**
 *  设置设备密码回调
 *
 *  @param device 设备实体
 *  @param result 结果
 */
-(void)onSetDeviceAuthCode:(DeviceEntity *)device withResult:(int)result;


/**
 *  发送数据SessionID错误
 *
 *  @param device 
 */
-(void)onSessionIdError:(DeviceEntity *)device;

/**
 *  重新连接设备
 *
 *  @param device
 */
-(void)reconnectDevice:(DeviceEntity *)device;

@end
