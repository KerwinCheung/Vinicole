//
//  SendPacketModel.h
//  lightify
//
//  Created by xtmac on 22/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceEntity, DeviceModel, ActionModel;


typedef enum : unsigned char {
    SwitchStatusOFF,
    SwitchStatusON
}SwitchStatus;

@interface SendPacketModel : NSObject

//查询设备状态
+(void)queryDeviceDataPoint:(DeviceEntity *)device;

/**
 *  控制设备
 *  @param sendDataArray 发送的数据数组
 *  @param device   要控制的设备
 */
+(void)controlDevice:(DeviceEntity *)device withSendDataArray:(NSMutableArray *)sendDataArray;

+(void)clocsDevice:(DeviceEntity *)device withSendDataArray:(NSMutableArray *)sendDataArray;

+(void)controlDevice:(DeviceEntity *)device withSendData:(NSData *)sendData Command:(unsigned char)command;

+(BOOL)isSend;

@end
