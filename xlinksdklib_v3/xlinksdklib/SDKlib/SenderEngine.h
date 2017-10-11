//
//  SenderEngine.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "DeviceEntity.h"

@class DataPointEntity;

@interface SenderEngine : NSObject<GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>

@property (nonatomic,retain,readonly)GCDAsyncUdpSocket *udpSocket;

@property (nonatomic,readonly,retain)GCDAsyncSocket *externalSocket;

@property (nonatomic,retain)NSMutableDictionary *subscription;

-(void)start;

-(void)stop;



+(SenderEngine *)sharedEngine;


-(void)directSendData:(NSData *)data;


-(void)udpSendDevice:(DeviceEntity *)device andData:(NSData *)data;


-(DeviceEntity *)getSubscriptionDeviceByMsgID:(int)msgID;



#pragma mark
#pragma mark --------start内网

-(void)sendLocalPipeWithDevice:(DeviceEntity *)device andMessageID:(int)msgID andPayload:(NSData *)payload andFlag:(int)flag;

/**
 *  本地发送设置授权码消息
 *
 *  @param device  设备实体
 *  @param msgID   消息ID
 *  @param oldAuth 旧密码
 *  @param newAuth 新密码
 *  @param flag    flag
 */
-(void)sendLocalSetDeviceAuthorize:(DeviceEntity *)device andMessageID:(int)msgID andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth andFlag:(int)flag;

-(void)sendSetAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID withFlag:(unsigned char)flag;

-(void)sendSetLocalDataPoints:(NSArray <DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID;

-(void)sendSetCloudDataPoints:(NSArray <DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID;

-(void)getSubKeyWithAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID;

//-(void)sendLocalSetDevicePropertyWithDevice:(DeviceEntity *)device andMessageID:(int)msgID andFlag:(int)flag;
-(void)sendLocalProbeWithDevice:(DeviceEntity *)device;

#pragma mark
#pragma mark --------end内网


#pragma mark
#pragma mark --------start外网

-(void)sendCloudSetPropertyWithDevice:(DeviceEntity *)device andMessageID:(int)messageID andFlag:(int)flag;

-(void)sendCloudProbeWithDevice:(DeviceEntity *)device andMessageID:(int)messageID andFlag:(int)flag;

-(void)sendDisconnectCM;
#pragma mark
#pragma mark --------end外网

//设置监听端口
//-(void)setListenPort:(int)port;


/*
 *@discussion
 *  发送设置包
 *  @param
 */
//-(void)sendSetDevice:(DeviceEntity *)aDevice andSessionID:(int)aSessionID andMesaageID:(int)aMsgID;


/*
 *@disucssion
 *  发送ByeBye包
 *  @param
 */
-(void)sendByeBye:(int)aSessionID andDevice:(DeviceEntity *)aDevice;


/*
 *@discussion
 *  发送ping包
 *  @param
 */
-(void)sendPingWithSessionID:(int)aSessionID andDevice:(DeviceEntity *)aDevice;


/*
 *@discussion
 *  sync包
 *  @param
 */
-(void)sendSyncWithDevice:(DeviceEntity *)aDevice;


/*
 *@discusion
 *  @param
 */
-(void)sendProbeWithSessionID:(int)aSessionID andDevice:(DeviceEntity *)aDevice;


/*
 *@discussion
 *  ping
 *  @param
 */





/*
 *@discussion
 *
 */

-(void)sendBoardcastWithData:(NSData *)data;



-(void)connect;

-(void)connectExternal:(NSString *)aIp andPort:(int)aPort;


//外网登陆
-(void)loginWithVersion:(int)aVersion andAppID:(int)appId  andAuthLength:(int)alen andAuthStr:(NSString *)authStr andKeepLive:(int)aKeepLive;

//HTTP代理服务登录
-(void)loginByHttpProxyWithHost:(NSString *)host;

//直连登录
-(void)loginByDirectWithHost:(NSString *)host andPort:(int)port;

//透传
-(void)senderpipeWithDeviceID:(int)deviceID andMessageID:(int)aMsgID andMessageFlag:(int)aFlag andPlaydata:(NSData *)playdata;

//-(void)ticketWithSessionID:(int)aSessionID andAppID:(int)appID andMessageID:(int)aMsgID andFlag:(int)aFlag andDevice:(DeviceEntity *)aDevice;

//-(void)ticketWithDevice:(DeviceEntity *)device andAppID:(int)appID andMessageID:(int)msgID andFlag:(int)flag;

-(void)sendLocalHandShake:(DeviceEntity *)device withMessageID:(int16_t)messageID andVersion:(int)version andAuthKey:(NSNumber *)authKey andFlag:(int)flag;

-(void)sendScanWithProductID:(NSString *)productId;

//-(void)sendScanWithMacAddress:(NSString *)macAddress withVersion:(uint8_t)version;

-(void)pingCloud;

-(void)closeCloud;

-(void)sendCloudSubscribeDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey andMessageID:(int)msgID andFlag:(int8_t)flag;

-(void)sendSetDeviceAuthorize:(DeviceEntity *)device andMessageID:(int)msgID andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth andFlag:(int)flag;

/*
 内网操作   以下为测试专用
 */


// -(void)heartBeat;               //发送心跳包

-(void)stopHeart;               //停止心跳




-(void)pingExt;                 //ping

// -(void)disconnect;              //断开连接

@end
