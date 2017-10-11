//
//  ActivatePacket.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtHeader.h"

/*
 typedef struct ACTIVATE_HEADER{
 __b1 _version;            //byte 1 协议版本
 __b1 _macAddress[6];      //byte 2-7 Mac地址
 __b1 _hardIdentifier;     //byte 8 wifi设备厂商标示
 __b2 _softIdentifier;     //byte 9-10 wifi软件版本
 __b1 _mcuHardVersion;     //byte 11  mcu硬件版本
 __b2 _mcuSoftVersion;     //byte 12-13  mcu 软件版本
 __b2 _activateStrLength;  //byte 14-15  激活码长度
 __b1 _activateStr[32];    //byte 16-47  激活码
 __b1 _activateReserved;   //byte 48     预留
 }ACTIVATE_HEADER;
 */

@interface ActivatePacket : NSObject
@property (nonatomic,retain,readonly)NSMutableData *data;

+(ActivatePacket *)packetWithVersion:(__b1)version andMacAddrs:(__b1[])mac andHardIdentf:(__b1)hardidf andSoftIdtf:(__b2)softIdf andMcuHardVsion:(__b1)hardVersion andMcuSoftVsion:(__b2)sofVersion andActvLen:(__b2)len andAtvtStr:(__b1[])str andReserved:(__b1)reserved;


-(id)initWithVersion:(int)version andMacAddress:(NSData *)address andWFHardIdtif:(int)hardidtf andWFSoftIdtf:(int)softidtf andMCUHardVsion:(int)hardVsion andMCUSoftVsion:(int)softVsion andActivateStrLen:(int)activateLen andActivateStr:(NSData *)activateStr andReserved:(int)resvd;


-(id)initWithData:(NSData *)data;

-(NSMutableData *)getPacketData;

-(NSInteger)getPacketSize;

+(NSInteger)getPacketSize;
//get method

-(int)getVersion;

-(NSData *)getMacAddress;

-(int)getWFHardIdentifier;

-(int)getWFSoftIdentifier;

-(int)getMCUHardVsion;

-(int)getMCUSoftVsion;

-(int)getActivateStrLen;

-(NSData *)getActivateStr;

-(int)getReserved;



//set method
-(void)setVesrion:(int)vsion;

-(void)setMacAddress:(NSData *)dataAddress;

-(void)setHard_WF_Identifier:(int)sender;

-(void)setSoft_WF_Identifier:(int)sender;

-(void)setMCUHardVsion:(int)vsion;

-(void)setMCUFoftVsion:(int)vsion;

-(void)setActivateStrLen:(int)len;

-(void)setActivateStr:(NSData *)data;

-(void)setReserved:(int)sender;


@end
