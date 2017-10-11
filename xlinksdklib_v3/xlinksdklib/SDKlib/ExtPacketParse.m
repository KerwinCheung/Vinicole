//
//  ExtPacketParse.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//
#import "ExtPacketParse.h"
#import "ExtHeader.h"
#import "XLinkCoreObject.h"
#import "PipeReturnPacket.h"
#import "PipeTwoReturnPacket.h"
#import "PipeTwoPacket.h"
#import "PipePacket.h"
#import "SyncCloudHeaderPacket.h"
#import "ExtFixHeader.h"
#import "CloudProbeReturnPacket.h"
#import "CloudSetAuthReturnPacket.h"
#import "XLinkExportObject.h"
#import "ConnectDeviceTask.h"
#import "MessageTraceItem.h"
#import "NotifyRetPacket.h"
#import "SubscribeByAuthReturnPacket.h"
#import "SetCloudDataPointReturnPacket.h"

static ExtPacketParse *_share;
@implementation ExtPacketParse
+(ExtPacketParse *)shareObject{
    @synchronized(self){
        if (_share==nil) {
            _share = [[ExtPacketParse alloc]init];
        }
    }
    return _share;
}

-(id)init{
    self = [super init];
    if (self) {
        
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

-(void)parserMachine:(NSData *)dataIncomming{
    
    if (dataIncomming.length==0) {
        return;
    }
    
    int offset = 0;
    const void * dataBuf = [dataIncomming bytes];
    while( offset < dataIncomming.length ) {
        
        // 还要再判断另外的一个条件
        if( (offset + 5) > dataIncomming.length ) {
            NSLog(@"校验云端数据长度失败 offset:%d, total:%lu", offset, (unsigned long)dataIncomming.length);
            break;
        }
        
        // 先拿5个字节出来
        int8_t msgType = 0;
        int32_t msgBodyLen = 0;
        memcpy(&msgType, dataBuf + offset, 1);  // 类型
        memcpy(&msgBodyLen, dataBuf + offset + 1, 4);   // 长度
        msgBodyLen = ntohl(msgBodyLen);
        // 太长的数据就错了
        if( (msgBodyLen + 5) > (dataIncomming.length - offset) ) {
            NSLog(@"校验云端数据实体长度失败 type:%d, offset:%d, body:%d, total:%lu", msgType, offset, msgBodyLen, (unsigned long)dataIncomming.length);
            break;
        }
        
        NSData * data = [NSData dataWithBytes:(dataBuf + offset) length:(msgBodyLen + 5)];
        
//        NSLog(@"收到云端数据>>>>");
//        [self printByteData:data];
//        NSLog(@"<<<<<<<<<<<<<<");
        
        // fix里面有当前数据包的长度
        FIX_EXT_HEADER fix;
        fix.MessageInfo = msgType;
        fix.DataLength = msgBodyLen;
        // 改变偏移量
        offset += 5;
        offset += fix.DataLength;

        switch (fix.MessageInfo & 0b11111000) {
                
#pragma mark----login
#pragma mark---------------云端登陆返回包
            case LOGIN_RSP_MESSAGE:
            {
                LOGIN_RETURN ret;
                [data getBytes:&ret range:NSMakeRange(sizeof(FIX_EXT_HEADER), sizeof(LOGIN_RETURN))];
                
                if (ret._code == 0) {
                    
                    NSLog(@"登录成功");
                    
                    [XLinkCoreObject sharedCoreObject].isLoginSuccessed = YES;
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onLogin:)]) {
                        [[XLinkExportObject sharedObject].delegate onLogin:ret._code];
                    }
                    
                    [[XLinkCoreObject sharedCoreObject] pingCloud];
                    
                    
                }else{
                    NSLog(@"登录失败,请检查秘密或者app ID");
                    
                    [[XLinkCoreObject sharedCoreObject] onLoginUnauthorized];
                    
                    [XLinkCoreObject sharedCoreObject].isLoginSuccessed = NO;
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onLogin:)]) {
                        [[XLinkExportObject sharedObject].delegate onLogin:ret._code];
                    }
                    
                }
                [[XLinkCoreObject sharedCoreObject] loginResponsed:ret._code];
                
            }
                break;
#pragma mark----pipe rsp
#pragma mark---------------云端pipe返回
            case PIPE_RSP_MESSAGE:
            {
                NSLog(@"透传返回");
                NSData *d =[data subdataWithRange:NSMakeRange(5, [PipeReturnPacket getPacketSize])];
                NSMutableData *tempData = [[NSMutableData alloc]initWithData:d];
                
                PipeReturnPacket *pipeRet = [[PipeReturnPacket alloc]initWithData:tempData];
                
                int msgID = [pipeRet getMessageID];
                
                DeviceEntity *device = (DeviceEntity *)[[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:msgID];
                [[XLinkCoreObject sharedCoreObject] onMessageTraceResponse:msgID];
                
                if (!device) {
                    NSLog(@"没有找到PIPE回报对应的发送方");
                    break;
                }
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSendPipeData:withResult:withMessageID:)]) {
                    [[XLinkExportObject   sharedObject].delegate onSendPipeData:device withResult:[pipeRet getCode] withMessageID:[pipeRet getMessageID]];
                    [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:[pipeRet getMessageID]];
                }
                
                
            }
                break;
                
#pragma mark-----pipe req
#pragma mark---------------云端pipe请求
            case PIPE_REQ_MESSAGE:
            {
                //得到pipe一个请求
                int sizeFilter = 5+[PipePacket getPacketSize];
                if (data.length<sizeFilter) {
                    break;
                }
                
                NSData * d =[data subdataWithRange:NSMakeRange(5, [PipePacket getPacketSize])];
                NSMutableData *tempData = [[NSMutableData alloc]initWithData:d];
                
                NSData *payload = [data subdataWithRange:NSMakeRange(sizeFilter, data.length-sizeFilter)];
                
                NSLog(@"收到透传数据长度为%lu", (unsigned long)[payload length]);
                
                //答应服务器，i get it.
                PipePacket *pipeRet = [[PipePacket alloc]initWithData:tempData];
                
                ExtFixHeader *fix = [ExtFixHeader pipeResponseHeader];
                PipeReturnPacket *ret = [[PipeReturnPacket alloc]init];
                
                [ret setToID:[pipeRet getDeviceID]];
                [ret setMessageID:[pipeRet getMessageID]];
                [ret setCode:0];
                
                NSMutableData *sendData = [fix getPacketData];
                [sendData appendData:[ret getPacketData]];
                
                //发送请求回报
                [[SenderEngine sharedEngine] directSendData:sendData];
                
                DeviceEntity *device = (DeviceEntity *)[[XLinkCoreObject sharedCoreObject] getDeviceByDeviceID:[pipeRet getDeviceID]];
                
                if (!device) {
                    NSLog(@"没有找到透传消息的发送者 %d 对应的本地设备实体，需要扫描添加该设备", [pipeRet getDeviceID] );
                    break;
                }
                
                // 如果是用户手动断开的设备，不要回调数据出去
                if( [device isUserDisconnect] ) {
                    NSLog(@"透传消息的发送者%d已经被用户断开,不需要处理数据.", [pipeRet getDeviceID]);
                    break;
                }
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onRecvPipeData:withPayload:)]) {
                    [[XLinkExportObject sharedObject].delegate onRecvPipeData:device withPayload:payload];
                }
                
            }
                break;
#pragma mark-----pipe sync
#pragma mark---------------云端pipe同步包
            case PIPE_SYNC_REQ_MESSAGE:
            {
                NSLog(@"收到PIPE广播包");
                int sizeFilter = 5+[PipeTwoPacket getPacketSize];
                
                if (data.length<sizeFilter) {
                    break;
                }
                NSData *d = [data subdataWithRange:NSMakeRange(5, [PipeTwoPacket getPacketSize])];
                NSMutableData *tempData = [[NSMutableData alloc]initWithData:d];
                
                PipeTwoPacket *pipeRet = [[PipeTwoPacket alloc]initWithSyncData:tempData];
                unsigned int deviceID = [pipeRet getDeviceID];
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getDeviceByDeviceID:deviceID];
                
                if (!device) {
                    //                NSLog(@"PIPE_SYNC Sender %d not exists in local device list.", deviceID);
                    NSLog(@"PIPE广播包发送者%d不在本地设备列表中，需要重新扫描加入该设备.", deviceID);
                    break;
                }
                
                // 如果是用户手动断开的设备，不要回调数据出去
                if( [device isUserDisconnect] ) {
                    NSLog(@"PIPE广播包发送者%d已经被用户断开,不需要处理数据.", deviceID);
                    break;
                }
                
                
                NSData *payload = [data subdataWithRange:NSMakeRange(sizeFilter, data.length-sizeFilter)];
                
                NSData *syncPayload =[data subdataWithRange:NSMakeRange(sizeFilter, data.length - sizeFilter)];
                if (!syncPayload.length) {
                    break;
                }
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onRecvPipeSyncData:withPayload:)]) {
                    [[XLinkExportObject sharedObject].delegate onRecvPipeSyncData:device withPayload:payload];
                }
                
                
            }
                break;
#pragma mark----subcribe
#pragma mark---------------云端订阅返回包
            case SUBSCRIPTION_RSP_MESSAGE:
            {
                NSLog(@"订阅返回包");
                
                int sizeFilter = 5 + 7;
                
                if (data.length < sizeFilter) {
                    break;
                }
                NSData *temp = [data subdataWithRange:NSMakeRange(5, 7)];
                
                SubscribeByAuthReturnPacket *subResp = [[SubscribeByAuthReturnPacket alloc]initWithData:temp];
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID: subResp.msgID];
                if( device == nil ) {
                    NSLog(@"订阅回包没找到目标设备！");
                    break;
                }
                
                if (subResp.code==0) {
                    NSLog(@"消息编号为%d的订阅成功", subResp.msgID);
                    NSLog(@"code = %d", subResp.code);
                    device.deviceID = subResp.deviceID;
                    [[XLinkCoreObject sharedCoreObject] initDevice:device];
                    [[XLinkExportObject sharedObject].delegate onSubscription:device withResult:0 withMessageID:0];
                }else{
                    NSLog(@"消息编号为%d的订阅失败", subResp.msgID);
                    NSLog(@"code = %d", subResp.code);
                    [[XLinkExportObject sharedObject].delegate onSubscription:device withResult:subResp.code withMessageID:0];
                }
                
                //如果是连接任务，进入处理
                if ((device.connectStatus & 0b1100) == 0) {
                    ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:device.macAddress];
                    [task onConnectDeviceSubscriptionBack:subResp];
                }
                
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:subResp.msgID];
                
            }
                break;
                
#pragma mark----password set
#pragma mark---------------云端设置密码返回
                
            case SETPWD_RSP_MESSAGE:
            {
                int sizeFilter = 5+[CloudSetAuthReturnPacket getPacketSize];
                if (data.length<sizeFilter) {
                    return;
                }
                
                NSData *retData = [data subdataWithRange:NSMakeRange(5, [CloudSetAuthReturnPacket getPacketSize])];
                CloudSetAuthReturnPacket *retPacket = [[CloudSetAuthReturnPacket alloc]initWithData:retData];
                // int appID = [retPacket getAppID];
                int messageID = [retPacket getMessageID];
                int code = [retPacket getCode];
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:messageID];
                if (!device) {
                    break;
                }
                
                [[XLinkCoreObject sharedCoreObject] onSetDeviceAuthCode:device withResult:code];
                
                BOOL backcall = [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetDeviceAuthorizeCode:withResult:withMessageID:)];
                if (backcall) {
                    [[XLinkExportObject sharedObject].delegate onSetDeviceAuthorizeCode:device withResult:code withMessageID:messageID];
                    [[XLinkCoreObject sharedCoreObject]removeMessageByMessageID:messageID];
                }
                
                
            }
                break;
                
#pragma mark----activate
#pragma mark---------------云端激活返回包
            case ACTIVATE_RSP_MESSAGE:
            {
                NSLog(@"激活返回");
                
                
                
            }
                break;
#pragma mark----connect
#pragma mark---------------云端连接返回包
            case CONNECT_RSP_MESSAGE:
            {
                NSLog(@"连接返回");
                
                
                
                
            }
                break;
#pragma mark----set
#pragma mark---------------云端设置返回包
            case SET_RSP_FLAG:
            {
                NSLog(@"设置返回");
                NSLog(@"设置返回");
                int sizeFilter = 5+[SetCloudDataPointReturnPacket getPacketSize];
                if(data.length<sizeFilter){
                    return;
                }
                
                NSData *retData = [data subdataWithRange:NSMakeRange(5, [SetCloudDataPointReturnPacket getPacketSize])];
                SetCloudDataPointReturnPacket *retPacket = [[SetCloudDataPointReturnPacket alloc]initWithData:retData];
                
                unsigned short msgID = [retPacket getMessageID];
                int code = [retPacket getCode];
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:msgID];
                if (!device) {
                    break;
                }
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetCloudDataPoint:withResult:withMsgID:)]) {
                    [[XLinkExportObject sharedObject].delegate onSetCloudDataPoint:device withResult:code withMsgID:msgID];
                }
                
            }
                break;
#pragma mark----probe
#pragma mark---------------云端探测返回
            case PROBE_RSP_MESSAGE:
            {
                NSLog(@"云端探测包返回");
                
                CloudProbeReturnPacket *packet = [[CloudProbeReturnPacket alloc]initWithData:[data subdataWithRange:NSMakeRange(5, data.length - 5)]];
                
                DeviceEntity *tempDevice = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:packet.msgID];
                if (!tempDevice) {
                    break;
                }
                
                tempDevice.deviceName = packet.name;
                
                if (packet.dataPoint.length && [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onCloudDataPoint2Update:withDataPoints:)]) {
                    [[XLinkExportObject sharedObject].delegate onCloudDataPoint2Update:tempDevice withDataPoints:[packet getDataPointArr]];
                }
                
                
                //如果是连接任务，进入处理
                if ((tempDevice.connectStatus & 0b1100) == 0) {
                    ConnectDeviceTask *task = [[XLinkCoreObject sharedCoreObject] getConnectDeviceTaskByDeviceMacAddress:tempDevice.macAddress];
                    [task onConnectDeviceProbeBack:packet];
                }
                
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onDeviceProbe:withResult:withMessageID:)]) {
//                    if (packet.code == 0) {
                        [[XLinkExportObject sharedObject].delegate onDeviceProbe:tempDevice withResult:packet.code withMessageID:packet.msgID];
//                    }else{
//                        //探测失败
//                        [[XLinkExportObject sharedObject].delegate onDeviceProbe:tempDevice withResult:packet.code withMessageID:packet.msgID];
//                    }
                }
                [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:packet.msgID];

            }
                break;
                
                
#pragma mark---sync
#pragma mark---------------云端同步返回包
            case SYNC_REQ_MESSAGE:
            {
                NSLog(@"云端同步返回包");
                SyncCloudHeaderPacket *packet = [[SyncCloudHeaderPacket alloc] initWithData:[data subdataWithRange:NSMakeRange(5, data.length - 5)]];
                
                DeviceEntity *device = [[XLinkCoreObject sharedCoreObject] getDeviceByDeviceID:packet.deviceID];
                
                if (!device) {
                    break;
                }
                
                device.deviceName = packet.name;
                
                if (packet.dataPoint.length && [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onCloudDataPoint2Update:withDataPoints:)]) {
                    [[XLinkExportObject sharedObject].delegate onCloudDataPoint2Update:device withDataPoints:[packet getDataPointArr]];
                }
                
            }
                break;
#pragma mark----ping
#pragma mark---------------云端ping返回包
            case PING_RSP_MESSAGE:
            {
                NSLog(@"ping返回");
            }
                break;
                
            case NOTIFY_REQ_FLAG:{
                NSLog(@"收到NOTIFY包");
                
                NSInteger sizeFilter = 5 + [NotifyRetPacket getPacketSize];
                if (data.length<sizeFilter) {
                    break;
                }
                
                NSData *mutateHeader = [data subdataWithRange:NSMakeRange(5, [NotifyRetPacket getPacketSize])];
                
                NotifyRetPacket *ret =[[NotifyRetPacket alloc] initWithData:mutateHeader];
                
                NSData *payload = [data subdataWithRange:NSMakeRange(sizeFilter, data.length - sizeFilter)];
                
                //接收到本地透传回调
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNotifyWithFlag:withMessageData:fromID:messageID:)]) {
                    [[XLinkExportObject sharedObject].delegate onNotifyWithFlag:[ret getFlag] withMessageData:payload fromID:[ret getFromID] messageID:[ret getMsgID]];
                }
            }
                break;

                
            default:
            {
                Byte typeBit = (fix.MessageInfo >> 4) & 0xFF;
#pragma mark --- MSG_XLINK_DISCONNECT 于云端断开
                if( typeBit == MSG_XLINK_DISCONNECT ) {
                    if(fix.DataLength > 0 && fix.DataLength == 1 ) {
                        NSData *retData = [data subdataWithRange:NSMakeRange(5, fix.DataLength)];
                        Byte reason = (Byte)(*(char *)retData.bytes);
                        if( reason == DISCONNECT_CODE_KICK ) {
                            NSLog(@"被踢下线");
                            [[XLinkCoreObject sharedCoreObject] onServerKicked];
                        }
                    }
                }
            }
                break;
        }
    }
}

//解析同步包
-(void)analyslsSyncPacket:(NSData*)data withOffset:(int)offset withDevice:(DeviceEntity*)device{
    
    int dataPointFlag = 0;
    [data getBytes:&dataPointFlag range:NSMakeRange(offset, 1)];

    offset++;
    
    if (data.length<offset) {
        return;
    }
    
    //获取到更换名字的同步包(未实现)
    if (dataPointFlag & 1) {
        int nameLenght = 0;
        [data getBytes:&nameLenght range:NSMakeRange(offset, 2)];
        nameLenght = htons(nameLenght);
        offset = offset + 2 + nameLenght;
    }
    
    //数据模板(暂用)
    NSArray *prodctid_value = [XLinkExportObject sharedObject].prodctid_value;
    if (!prodctid_value) {
        return;
    }
    
    //第二位为1代表有数据
    if (dataPointFlag & 2) {
        //得到数据模板占用的Byte的长度
        int prodctidLenght = (int)prodctid_value.count / 8 + (prodctid_value.count % 8 != 0);
        int dataPoint = 0;
        //得到数据端点，用于判断哪个数据端点有值
        [data getBytes:&dataPoint range:NSMakeRange(offset, prodctidLenght)];
        offset += prodctidLenght;
        for (int i = 0; i < prodctid_value.count; i++) {
            if (dataPoint >> i & 1) {
                int dataPointLenght = [prodctid_value[i] intValue];
                NSData *dataBuff = [data subdataWithRange:NSMakeRange(offset, dataPointLenght)];
                offset += dataPointLenght;
                
                if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onDataPointUpdata:withIndex:withDataBuff:withChannel:)]) {
                    [[XLinkExportObject sharedObject].delegate onDataPointUpdata:device withIndex:i withDataBuff:dataBuff withChannel:0];
                }
            }
        }
    }
}

@end

/*
 43
 00000036
 772a08b0
 0101
 06
 000001d0 01000187 02100232 ad033004 009896d5 049018e7 94b5e9a5 ade99485 656c6563 74726963 20636f6f 6b6572
 */
