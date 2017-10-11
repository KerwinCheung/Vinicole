//
//  ConnectDeviceTask.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/18.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "DeviceEntity.h"

@class DeviceEntity, ShakeHandByAuthReturnPacket, SubscribeByAuthReturnPacket, CloudProbeReturnPacket, SubKeyReturnHeader;

@interface ConnectDeviceTask : NSObject

@property (strong, nonatomic) DeviceEntity *deviceEntity;
@property (strong, nonatomic) NSNumber  *accessKey;

-(instancetype)initWithDevice:(DeviceEntity *)device;

-(int)connectWithAccessKey:(NSNumber *)accessKey;

//扫描回包
- (void)onConnectDeviceScanByMacBack;
//握手回包
- (void)onConnectDeviceHandshakeBack:(int8_t)result;
//订阅返回
-(void)onConnectDeviceSubscriptionBack:(SubscribeByAuthReturnPacket *)subResp;
//获取subkey返回
-(void)onGotSubKeyBack:(SubKeyReturnHeader *)subResp;
//probe返回
-(void)onConnectDeviceProbeBack:(CloudProbeReturnPacket *)packet;

@end
