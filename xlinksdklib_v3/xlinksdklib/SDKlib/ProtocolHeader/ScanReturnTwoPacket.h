//
//  ScanReturnTwoPacket.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanReturnTwoPacket : NSObject

/*
 *@discussion
 *  接收到网络数据初始化扫描返回包
 */
-(id)initWithData:(NSData *)data;
/*
 *@discussion
 *  设置包bytes
 */
-(void)setPacketData:(NSData *)data;
/*
 *@discussion
 *  获得bytes
 */
-(NSMutableData *)getPacketData;
/*
 *@discussion
 *  获得包大小
 */
+(int)getPacketSize;
/*
 *@discussion
 *  获得协议版本
 */
-(int)getVersion;
/*
 *@discussion
 *  获得MAC地址
 */
-(NSData *)getMacAddress;

-(NSString *)getMacAddressString;
/*
 *@discussion
 *  获得产品ID长度
 */
-(int)getPruductIDLength;
/*
 *@discussion
 *  获得产品ID bytes
 */
-(NSData *)getPruductID;
/*
 *@discussion
 *  获得MCU硬件版本
 */
-(int)getMCUHardVersion;

/*
 *@discussion
 *  获得MCU软件版本
 */
-(int)getMCUSoftVersion;

/*
 *@discussion
 *  获得设备UDP 端口
 */
-(int)getDeviceUdpPort;

-(unsigned short)getDeviceType;

/*
 *@discussion
 *  datapoint 标示
 */
-(unsigned char)getFlag;

@end
