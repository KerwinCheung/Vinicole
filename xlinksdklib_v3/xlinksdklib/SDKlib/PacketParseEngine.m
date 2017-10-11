//
//  PacketParseEngine.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "PacketParseEngine.h"
#import "MessageTraceItem.h"
#import "FixHeader.h"
#import "XLinkExportObject.h"
#import "XLinkCoreObject.h"
#import "ConnectDeviceTask.h"

#import "ScanReturnPacket.h"
#import "HandShakeRetPacket.h"
//?probe
#import "SetResponsePacket.h"
#import "SyncRetHeaderPacket.h"
#import "SubKeyReturnHeader.h"
#import "LocalPipeReturnPacket.h"
#import "DevicePipeAppPacket.h"
#import "SetACKReturnPacket.h"
#import "PingRetPacket.h"
#import "SetPSWDReturnPacket.h"
#import "SetLocalDataPointReturnPacket.h"

static PacketParseEngine *shareObject;

@interface PacketParseEngine ()<GCDAsyncUdpSocketDelegate>

@end

@implementation PacketParseEngine
{
    
}

+(PacketParseEngine *)shareObject{
    
    @synchronized(self){
        if (shareObject == nil) {
            shareObject = [[PacketParseEngine alloc]init];
        }
    }
    return shareObject;
}

-(id)init{
    
    if (self == [super init]) {
    }
    return self;
}

-(void)printByteData:(NSData *)data{
    
    unsigned char temp[data.length];
    [data getBytes:temp range:NSMakeRange(0, data.length)];
    for (int i=0; i<data.length; i++) {
        NSLog(@"%d <- %02x",i,temp[i]);
    }
    
}

-(void)parseMachine:(NSData *)dataIncomming forIP:(NSString *)ipStr{
    
    if (dataIncomming.length < [FixHeader getPacketSize]) {
        return;
    }
    
    // NSLog(@"message info=%d",[fix getMessageInfo]);
    // NSLog(@"data length = %ld",(unsigned long)data.length);
    
    int offset = 0;
    while( offset < dataIncomming.length ) {
        // 还要再判断另外的一个条件
        if( (offset + [FixHeader getPacketSize]) > dataIncomming.length ) {
            NSLog(@"校验本地数据长度失败 offset:%d, total:%lu", offset, (unsigned long)dataIncomming.length);
            break;
        }
        // 获取固定头
        FixHeader *fix = [[FixHeader alloc] initWithFixData:[dataIncomming subdataWithRange:NSMakeRange(offset, [FixHeader getPacketSize])]];
        // 太长的数据就错了
        if( ([fix getDataLength] + [FixHeader getPacketSize]) > (dataIncomming.length - offset) ) {
            NSLog(@"校验本地数据实体长度失败 type:%d, offset:%d, body:%d, total:%lu", [fix getMessageInfo], offset, [fix getDataLength], (unsigned long)dataIncomming.length);
            break;
        }
        //获取固定头 + 数据
        NSData *data = [dataIncomming subdataWithRange:NSMakeRange(offset, [FixHeader getPacketSize] + [fix getDataLength])];
        
        //NSLog(@"fix bytes>>>");
        // [self printByteData:data];
        //NSLog(@"<<<fix bytes");
        
        
        // 偏移量转换
        offset += [FixHeader getPacketSize];
        offset += [fix getDataLength];
        
        switch ([fix getMessageInfo] & 0b11111000) {
                
#pragma mark ----------------扫描返回
            case SCAN_RSP_FLAG:{
                
                /*
                 03
                 0006
                 accf236ab936
                 0020
                 313630666132
                 6164333961313563
                 3030313630666132
                 6164333961313563
                 30
                 3101
                 000117 63000101 0009786c 696e6b5f 64657600 000000
                 */
                
                NSMutableData *scanRet = [NSMutableData dataWithData:[data subdataWithRange:NSMakeRange(5, data.length - 5)]];  //获取减去包头的扫描包
                
                ScanReturnPacket *packet = [[ScanReturnPacket alloc] initWithData:scanRet];
                
                
                
                // 初始化设备
                // 计算出PID
                char buf[33] = {0};
                memcpy(buf, packet.productIDData.bytes, 32);
                NSMutableData *tempPid = [[NSMutableData alloc] initWithBytes:buf length:33];
                NSString *pidStr = [NSString stringWithUTF8String:tempPid.bytes];
                
                DeviceEntity *device = nil;
                device = [[XLinkCoreObject sharedCoreObject] getDeviceByMacAddress:packet.macData];
                if( device == nil ) {
                    device = [[DeviceEntity alloc] init];
                    // 在这里把设备加到列表中
                    [[XLinkExportObject sharedObject] initDevice:device];
                } else if( ![device.productID isEqualToString:pidStr] ) {
                    NSLog(@"ProductID错误，设备无效");
                    return;
                }
                
                device.fromIP = ipStr;
                device.version = packet.version;
                device.macAddress = packet.macData;
                device.productID = pidStr;
                device.mcuHardVersion = packet.mcuHardVersion;
                device.mcuSoftVersion = packet.mcuSoftVersion;
                device.devicePort = packet.port;
                device.deviceType = packet.deviceType;
                
                
                if (packet.version < 3) {
                    device.flag = packet.flag;
                    device.deviceName = packet.name;
                    device.accessKey = @(packet.accessKey);
                    NSLog(@"扫描到设备 name：%@；mac：%@；初始化：%@",device.deviceName, [device getMacAddressString], [NSNumber numberWithBool:[device getInitStatus]]);
                    if ((device.connectStatus & 0b0011) == 0) {
                        NSLog(@"Connect device task exists, process the task...");
                        ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:device.macAddress];
                        [task onConnectDeviceScanByMacBack];
                        break;
                    }
                    
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onGotDeviceByScan:)]) {
                        [[XLinkExportObject sharedObject].delegate onGotDeviceByScan:device];
                    }
                }else{
                    if (packet.mode & 0b01){
                        if ((device.connectStatus & 0b0011) == 0) {
                            NSLog(@"Connect device task exists, process the task...");
                            ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:device.macAddress];
                            [task onConnectDeviceScanByMacBack];
                        }
                    }else if (packet.mode & 0b10){
                        device.flag = packet.flag;
                        device.deviceName = packet.name;
                        device.accessKey = @(packet.accessKey);
                        if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onGotDeviceByScan:)]) {
                            [[XLinkExportObject sharedObject].delegate onGotDeviceByScan:device];
                        }
                    }
                }
                
            }
                break;
#pragma mark ----------------设置本地授权码回调
            case SETPSW_RSP_FLAG:{
                NSLog(@"设置本地授权返回");
                
                int sizeFilter = 5+[SetPSWDReturnPacket getPacketSize];
                
                if (data.length<sizeFilter) {
                    
                    break;
                    
                }
                
                NSData *retData = [data subdataWithRange:NSMakeRange(5, [SetPSWDReturnPacket getPacketSize])];
                
                SetPSWDReturnPacket *retPacket = [[SetPSWDReturnPacket alloc]initWithData:retData];
                
                int messageID = [retPacket getMessageID];
                
                int code = [retPacket getCode];
                
                DeviceEntity * device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:messageID];
                
                if (!device) {
                    break;
                }
                
                [[XLinkCoreObject sharedCoreObject] onSetDeviceAuthCode:device withResult:code];
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetLocalDeviceAuthorizeCode:withResult:withMessageID:)]) {
                    
                    [[XLinkExportObject sharedObject].delegate onSetLocalDeviceAuthorizeCode:device withResult:code withMessageID:messageID];
                    
                }
                
                
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:messageID];
                
            }
                break;
                
#pragma mark ----------------握手返回
            case HANDSHAKE_RSP_FLAG:{
                NSMutableData *hsret = [NSMutableData dataWithData:[data subdataWithRange:NSMakeRange(5, data.length - 5)]];  //获取减去包头的扫描包
                
                HandShakeRetPacket *packet = [[HandShakeRetPacket alloc] initWithData:hsret];
                
                ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:packet.macData];
                
                if (!task || !task.deviceEntity) {
                    NSLog(@"[WARNING] 在SDK中没有找到连接任务%@", packet.macData);
                    break;
                }
                
                if (packet.result == 0) {
                    task.deviceEntity.sessionID = packet.sessionID;
                    task.deviceEntity.deviceID = packet.deviceID;
                }
                
                // 如果任务处于连接状态，则进入connect队列处理
                if ((task.deviceEntity.connectStatus & 0b0011) == 0) {
                    [task onConnectDeviceHandshakeBack:packet.result];
                }
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:packet.messageID];
            }
                break;
#pragma mark ----------------SUBKEY返回
            case SUBKEY_RSP_FLAG:{
                NSData *subkeyData = [data subdataWithRange:NSMakeRange([FixHeader getPacketSize], data.length - [FixHeader getPacketSize])];
                
                SubKeyReturnHeader *subkeyRet = [[SubKeyReturnHeader alloc] initWithData:subkeyData];
                
                NSLog(@"收到SUBKEY : %ld", subkeyRet.subKey);
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:subkeyRet.messageID];
                
                device.subKey = subkeyRet.subKey;
                
                if ((device.connectStatus & 0b1100) == 0) {
                    ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:device.macAddress];
                    [task onGotSubKeyBack:subkeyRet];
                }
                
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:-1];
                
            }
                break;
#pragma mark ----------------pipe本地请求
            case PIPE_REQ_FLAG:{
//                int sizeFilter = [FixHeader getPacketSize]+[DevicePipeAppPacket getPacketSize];
//                if (data.length<sizeFilter) {
//                    break;
//                }
                
//                NSLog(@"接收到本地透传数据%lu字节", (unsigned long)data.length);
                
//                NSData *mutateHeader = [data subdataWithRange:NSMakeRange([FixHeader getPacketSize], [DevicePipeAppPacket getPacketSize])];
                
                DevicePipeAppPacket *packet =[[DevicePipeAppPacket alloc] initWithData:[data subdataWithRange:NSMakeRange(5, data.length - 5)] withVersion:[fix getMessageInfo] & 0b00000111];
                
                DeviceEntity * device = [[XLinkCoreObject sharedCoreObject] getDeviceByMacAddress:packet.mac];
                
                if( !device ) {
                    NSLog(@"接收到的本地透传数据(MAC:%@)没找到对应的设备!", packet.mac);
                    break;
                }
                
                // 如果是用户手动断开的设备，不要回调数据出去
                if( [device isUserDisconnect] ) {
                    NSLog(@"本地透传数据发送者(MAC:%@)已经被用户断开,不需要处理数据.", packet.mac);
                    break;
                }
                
                //接收到本地透传回调
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onRecvLocalPipeData:withPayload:)]) {
                    [[XLinkExportObject sharedObject].delegate onRecvLocalPipeData:device withPayload:packet.payload];
                }
                
            }
                break;
                
                
#pragma mark ----------------pipe返回
            case PIPE_RSP_FLAG:{
                int sizeFilter = [FixHeader getPacketSize]+[LocalPipeReturnPacket getPacketSize];
                if (data.length<sizeFilter) {
                    break;
                }
                
                NSLog(@"接收到本地透传应答%lu字节", (unsigned long)data.length);
                
                LocalPipeReturnPacket *pRet = [[LocalPipeReturnPacket alloc]initWithData:[data subdataWithRange:NSMakeRange([FixHeader getPacketSize], [LocalPipeReturnPacket getPacketSize])]];
                
                int msgID = [pRet getMessageID];
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:msgID];
                
                if (!device) {
                    NSLog(@"本地透传应答包(ID:%d)没找到对应的设备!", msgID);
                    break;
                }
                
                int code  = [pRet getCode];
                
                // SESSION ID 错误
                if( code == 1 ) {
                    NSLog(@"Session id error when send PIPE, try reconnect device");
                    [[XLinkCoreObject sharedCoreObject] onSessionIdError:device];
                }
                
                //本地pipe回调
                BOOL backCall = [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSendLocalPipeData:withResult:withMessageID:)];
                
                if (backCall) {
                    [[XLinkExportObject sharedObject].delegate onSendLocalPipeData:device withResult:code withMessageID:[pRet getMessageID]];
                }
                
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:[pRet getMessageID]];
                
            }
                break;
                
#pragma mark ----------------设置返回
            case SET_RSP_FLAG:{
                NSLog(@"set返回包");
                
                NSRange rg = NSMakeRange([FixHeader getPacketSize], [SetLocalDataPointReturnPacket getPacketSize]);
                
                SetLocalDataPointReturnPacket *st = [[SetLocalDataPointReturnPacket alloc]initWithData:[data subdataWithRange:rg]];
                
                unsigned short msgID = [st getMessageID];
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:msgID];
                
                if (!device) {
                    NSLog(@"本地 Set DataPoint 应答包(ID:%d)没找到对应的设备!", msgID);
                    break;
                }
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetLocalDataPoint:withResult:withMsgID:)]) {
                    [[XLinkExportObject sharedObject].delegate onSetLocalDataPoint:device withResult:[st getState] withMsgID:msgID];
                }
                
            }
                break;
#pragma mark ----------------ping返回
            case PING_RSP_FLAG:{
                
                NSLog(@"ping返回包，还存活着");
                
                uint8_t version = ((uint8_t *)data.bytes)[0] & 0b11;
                NSData *pingData = [data subdataWithRange:NSMakeRange([FixHeader getPacketSize], data.length - [FixHeader getPacketSize])];
                
                PingRetPacket *packet = [[PingRetPacket alloc] initWithData:pingData withVersion:version];
                
                NSData *macData = [packet getMAC];
                
                DeviceEntity *device =  [[XLinkCoreObject sharedCoreObject] getDeviceByMacAddress:macData];
                
                if( device != nil ) {
                    [device setLastgetPingReturn:[[NSDate date] timeIntervalSince1970]];
                    [device setLocalAddress:ipStr];
                }
                
                unsigned char  macBytes[6];
                [macData getBytes:macBytes length:6];
                
                NSString *macStr = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",(Byte)macBytes[0],(Byte)macBytes[1],(Byte)macBytes[2],(Byte)macBytes[3],(Byte)macBytes[4],(Byte)macBytes[5]];
                NSLog(@"mac str = %@",macStr);
                
            }
                break;
#pragma mark ---------------SYNC返回
            case SYNC_REQ_FLAG:{
                
                SyncRetHeaderPacket *packet = [[SyncRetHeaderPacket alloc] initWithData:[data subdataWithRange:NSMakeRange(5, data.length - 5)] withVersion:[fix getMessageInfo] & 0b00000111];
                
                DeviceEntity *device =[[XLinkCoreObject sharedCoreObject] getDeviceByMacAddress:packet.mac];
                
                if (!device) {
                    break;
                }
                
                device.deviceName = packet.name;
                
                if (packet.dataPoint.length && [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onLocalDataPoint2Update:withDataPoints:)]) {
                    [[XLinkExportObject sharedObject].delegate onLocalDataPoint2Update:device withDataPoints:[packet getDataPointArr]];
                }
            }
                break;
#pragma mark ---------------同步返回
            case SYNC_RSP_FLAG:{
                // 原理上，同步包是不会从APP发出的**********
                //                NSLog(@"sync message request");
                //                NSLog(@"-------------------------------");
                //
                //                int offset = [FixHeader getPacketSize]+[SyncHeaderPacket getPacketSize];
                //                if (data.length<offset) {
                //                    break;
                //                }
                
            }
                break;
                
#pragma mark --------------- 设置AccessKey返回
            case SETACK_RSP_FLAG:{
                NSLog(@"设置AccessKey返回");
                
                if (data.length < [FixHeader getPacketSize] + [SetACKReturnPacket getPacketSize]) {
                    break;
                }
                
                NSData *retData = [data subdataWithRange:NSMakeRange([FixHeader getPacketSize], [SetACKReturnPacket getPacketSize])];
                
                SetACKReturnPacket *retPacket = [[SetACKReturnPacket alloc] initWithData:retData];
                
                int messageId = [retPacket getMessageID];
                
                int code = [retPacket getCode];
                
                MessageTraceItem *item = [[XLinkCoreObject sharedCoreObject] getMessageTraceItem:messageId];
                DeviceEntity *device = item.object[@"device"];
                
                if (!device) {
                    break;
                }
                
                if (code == 0) {
                    device.flag|=0b100;
                    device.accessKey = item.object[@"accessKey"];
                }else{
                    device.accessKey = @(0);
                }
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetDeviceAccessKey:withResult:withMessageID:)]) {
                    [[XLinkExportObject sharedObject].delegate onSetDeviceAccessKey:device withResult:code withMessageID:messageId];
                }
                
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:messageId];
                
            }
                break;
                //            case NOTIFY_REQ_FLAG:{
                //                NSLog(@"收到NOTIFY包");
                //
                //                NSInteger sizeFilter = [FixHeader getPacketSize] + [NotifyRetPacket getPacketSize];
                //                if (data.length<sizeFilter) {
                //                    break;
                //                }
                //
                //                NSData *mutateHeader = [data subdataWithRange:NSMakeRange([FixHeader getPacketSize], [NotifyRetPacket getPacketSize])];
                //
                //                NotifyRetPacket *ret =[[NotifyRetPacket alloc] initWithData:mutateHeader];
                //
                //                NSData *payload = [data subdataWithRange:NSMakeRange(sizeFilter, data.length - sizeFilter)];
                //
                //                //接收到本地透传回调
                //                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNotifyWithFlag:withMessageData:fromID:messageID:)]) {
                //                    [[XLinkExportObject sharedObject].delegate onNotifyWithFlag:[ret getFlag] withMessageData:payload fromID:[ret getFromID] messageID:[ret getMsgID]];
                //                }
                //            }
                //                break;
                
            default:
                break;
        }
    }
}

@end
