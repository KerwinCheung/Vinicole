//
//  PacketParseEngine.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"
#import "DeviceEntity.h"
#import "XLinkCoreObject.h"


@class PacketParseEngine;

//被抛弃了
@protocol packParseEngineDelegate <NSObject>
/*
 *@discussion
 *  扫描之后得到的 （key:设备deviceKey value:deviceEntity）的字典
 */
//-(void)packParse:(PacketParseEngine *)parseEngine  scannedWithDevices:(NSMutableDictionary *)scanDict;

/*
 *@discussion
 *  握手成功
 */
//-(void)packParse:(PacketParseEngine *)parseEngine andHandshakeState:(NSMutableDictionary *)dict;

@end

@interface PacketParseEngine : NSObject

@property (nonatomic,assign)id<packParseEngineDelegate> delegate;//抛弃

@property (nonatomic,retain,readonly)id data;

@property (nonatomic,retain)NSString *appid; //app 的ID

@property (nonatomic,retain)NSString *password;//登陆密码

//@property (nonatomic,copy)NSString *productIDFilter;//扫描pid过滤

//@property (nonatomic,copy)NSString *macAddressFilter;//扫描Mac地址过滤

@property (nonatomic,assign)id<ScanDeviceDelegate> scanDelegate;//pid扫描

@property (nonatomic,assign)id<ScanDeviceDelegate> scanByMacDelegate;//Mac扫描

+(PacketParseEngine *)shareObject;    //共享对象

-(void)parseMachine:(NSData *)data forIP:(NSString *)ipStr;   //解析机器

@end
