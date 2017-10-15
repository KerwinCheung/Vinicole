//
//  SendPacketModel.m
//  lightify
//
//  Created by xtmac on 22/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "SendPacketModel.h"
#import "PacketModel.h"
#import "DeviceEntity.h"
#import "DeviceModel.h"
#import "RecvAndSendEngine.h"

@implementation SendPacketModel

+(void)queryDeviceDataPoint:(DeviceEntity *)device{
    PacketModel *packetModel = [[PacketModel alloc] init];
    packetModel.command = 0xca;
    
    NSMutableData *data = [NSMutableData data];

    unsigned char dataValue = 0x00;
    [data appendBytes:&dataValue length:1];

    packetModel.data = [NSData dataWithData:data];
    
    [[RecvAndSendEngine shareEngine] sendPacket:packetModel withDevice:device];
}

+(void)controlDevice:(DeviceEntity *)device withSendDataArray:(NSMutableArray *)sendDataArray{
    PacketModel *packetModel = [[PacketModel alloc] init];
    packetModel.command = 0xc5;
    
    NSMutableData *data = [NSMutableData data];
    
    NSData *abData = sendDataArray[1];
    [data appendBytes:abData.bytes length:abData.length];
    
    NSData *hourData = sendDataArray[2];
    [data appendBytes:hourData.bytes length:hourData.length];
    
    NSData *minData = sendDataArray[3];
    [data appendBytes:minData.bytes length:minData.length];
    
    NSData *secData = sendDataArray[4];
    [data appendBytes:secData.bytes length:secData.length];
    
    NSData *speedData = sendDataArray[5];
    [data appendBytes:speedData.bytes length:speedData.length];
    
    NSData *bhourData = sendDataArray[10];
    [data appendBytes:bhourData.bytes length:bhourData.length];
    
    NSData *bminData = sendDataArray[11];
    [data appendBytes:bminData.bytes length:bminData.length];
    
   /* 
    for (int i = 0; i<sendDataArray.count; i++) {
        NSData *pointData = sendDataArray[i];
        [data appendBytes:pointData.bytes length:pointData.length];
    }
    */

    packetModel.data = [NSData dataWithData:data];
    
    [[RecvAndSendEngine shareEngine] sendPacket:packetModel withDevice:device];
    
}

+(void)clocsDevice:(DeviceEntity *)device withSendDataArray:(NSMutableArray *)sendDataArray{
    PacketModel *packetModel = [[PacketModel alloc] init];
    packetModel.command = 0xc5;
    
    NSMutableData *data = [NSMutableData data];
    
//    unsigned char closeValue = 0xff;
//    [data appendBytes:&closeValue length:1];
    
    NSData *abData = sendDataArray[0];
    [data appendBytes:abData.bytes length:abData.length];
    
    NSData *hourData = sendDataArray[2];
    [data appendBytes:hourData.bytes length:hourData.length];
    
    NSData *minData = sendDataArray[3];
    [data appendBytes:minData.bytes length:minData.length];
    
    NSData *secData = sendDataArray[4];
    [data appendBytes:secData.bytes length:secData.length];
    
    NSData *speedData = sendDataArray[5];
    [data appendBytes:speedData.bytes length:speedData.length];
    
    NSData *bhourData = sendDataArray[10];
    [data appendBytes:bhourData.bytes length:bhourData.length];
    
    NSData *bminData = sendDataArray[11];
    [data appendBytes:bminData.bytes length:bminData.length];
    
    packetModel.data = [NSData dataWithData:data];
    
    [[RecvAndSendEngine shareEngine] sendPacket:packetModel withDevice:device];
    
}

+(void)controlDevice:(DeviceEntity *)device withSendData:(NSData *)sendData Command:(unsigned char)command{
    PacketModel *packetModel = [[PacketModel alloc] init];
    packetModel.command = 0xc5;
    
    NSMutableData *data = [NSMutableData data];

    [data appendBytes:&command length:1];
    
    [data appendBytes:sendData.bytes length:sendData.length];
    
    packetModel.data = [NSData dataWithData:data];
    
    [[RecvAndSendEngine shareEngine] sendPacket:packetModel withDevice:device];
}

+(BOOL)isSend{
    static NSTimeInterval time = 0;
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    BOOL isSend = false;
    if (curTime - time >= SendPacketTime) {
        time = curTime;
        isSend = true;
    }
    return isSend;
}

@end
