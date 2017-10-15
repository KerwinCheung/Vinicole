//
//  RecvAndSendEngine.m
//  lightify
//
//  Created by xtmac on 19/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "RecvAndSendEngine.h"
#import "PacketModel.h"
#import "XLinkExportObject.h"
#import "DeviceEntity.h"
#import "NSTools.h"


#define DATAPACKETHEAD  (0xaaaa)
#define PACKETTAIL  (0x5555)

@implementation RecvAndSendEngine{
    NSMutableArray  *_recvDeviceDataArr;
    NSThread        *_recvThread;
    NSMutableArray  *_packetList;
    
    NSThread        *_timeOutThread;
    NSTimer         *_timeOutTimer;
}

+(RecvAndSendEngine *)shareEngine{
    static dispatch_once_t once;
    static RecvAndSendEngine *recvAndSendEngine;
    dispatch_once(&once, ^{
        recvAndSendEngine = [[RecvAndSendEngine alloc] init];
    });
    return recvAndSendEngine;
}

-(void)initProperty{
    _recvThread = [[NSThread alloc] initWithTarget:self selector:@selector(breakUpPacketThread) object:nil];
    [_recvThread start];
}

-(void)recvData:(NSData *)data withDevice:(DeviceEntity *)device{
    
    if (!_recvThread) {
        [self initProperty];
    }
    NSString *address = [device getMacAddressSimple];
    NSDictionary *oldDataDic = nil;
    for (NSUInteger i = 0; i < _recvDeviceDataArr.count; i++) {
        NSDictionary *dic = _recvDeviceDataArr[i];
        DeviceEntity *temp = [dic objectForKey:@"device"];
        if ([address isEqualToString:[temp getMacAddressSimple]]) {
            oldDataDic = dic;
            break;
        }
    }
    if (!oldDataDic) {
        oldDataDic = @{@"device" : device, @"data" : [NSMutableData data]};
        [_recvDeviceDataArr addObject:oldDataDic];
    }
    NSMutableData *oldData = [oldDataDic objectForKey:@"data"];
    [oldData performSelector:@selector(appendData:) onThread:_recvThread withObject:data waitUntilDone:YES];
//    [_recvData performSelector:@selector(appendData:) onThread:_recvThread withObject:data waitUntilDone:YES];
}

-(void)checkTimeOut{
    
    for (NSInteger i = _packetList.count - 1; i >= 0; i--) {
        NSMutableDictionary *packetDic = _packetList[i];
        NSInteger time = [[packetDic objectForKey:@"time"] integerValue];
        time--;
        if (!time) {
            //超时
            PacketModel *sendPacketModel = [packetDic objectForKey:@"packetModel"];
            PacketModel *tempPacketModel = [[PacketModel alloc] init];
            tempPacketModel.command = sendPacketModel.command | 0b10000000;
//            [ParsingPacketModel parsingPacketWithRecvPacket:tempPacketModel withSendPacket:sendPacketModel withDevice:[packetDic objectForKey:@"device"]];
            [_packetList removeObjectAtIndex:i];
        }else{
            [packetDic setObject:@(time) forKey:@"time"];
        }
    }
    
    if (!_packetList.count) {
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    }
    
}

-(PacketModel *)removePacketWithSerial:(unsigned short)serial{
    PacketModel *sendPacketModel = nil;
    for (NSInteger i = _packetList.count - 1; i >= 0; i--) {
        PacketModel *packetModel = [_packetList[i] objectForKey:@"packetModel"];
        if (serial == packetModel.serial) {
            sendPacketModel = packetModel;
            [_packetList removeObjectAtIndex:i];
            break;
        }
    }
    return sendPacketModel;
}

+(void)ignore:(id)_{}

-(void)breakUpPacketThread{
    
    NSLog(@"Recv Data Thread Start");
    
    [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:self selector:@selector(ignore:) userInfo:nil repeats:YES];
    
    _recvDeviceDataArr = [NSMutableArray array];
    
    while ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        NSLog(@"%@", _recvDeviceDataArr);
        [self breakUpPacket];
    }
    
    _recvThread = nil;
    _recvDeviceDataArr = nil;
    
    NSLog(@"Recv Data Thread End");
    
}

-(void)breakUpPacket{
    
    unsigned short headIndex;
    
    for (NSDictionary *recvDataDic in _recvDeviceDataArr) {
        NSMutableData *recvData = [recvDataDic objectForKey:@"data"];

        while (recvData.length >= 10) {
            NSMutableArray <NSMutableData *>* dataPoint = [NSMutableArray arrayWithObjects:
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           nil];
            
            [self getDataPoint:dataPoint RecvData:recvData];
            
            
            [recvData replaceBytesInRange:NSMakeRange(0, recvData.length) withBytes:nil length:0];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kQueryDeviceDataPoint object:@{@"result" : @(0), @"device" : [recvDataDic objectForKey:@"device"], @"dataPoint" : dataPoint}];
            
            return;
//            headIndex = 0;
//            UInt16 recvDataChar[recvData.length];
//            [recvData getBytes:recvDataChar length:recvData.length];
//            //找到包头
//            while (headIndex < recvData.length && (recvDataChar[headIndex] != DATAPACKETHEAD)) {
//                headIndex++;
//            }
//
//            //如果找不到包头
//            if (headIndex >= recvData.length) {
//                recvData.length = 0;
//                return;
//            }
//
//            //如果包头不是第一位，把包头前面的数据删掉
//            if (headIndex != 0) {
//                [recvData replaceBytesInRange:NSMakeRange(0, headIndex) withBytes:nil length:0];
//                [recvData getBytes:recvDataChar length:recvData.length];
//            }
//
//            //获取头
//            NSData *headData = [NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(0, 1)]];
//            UInt16 head;
//            [headData getBytes:&head length:1];
//
//            if (head == DATAPACKETHEAD) {
//                //状态数据
//                NSMutableArray <NSMutableData *>* dataPoint = [NSMutableArray arrayWithObjects:
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               [NSMutableData dataWithLength:1],
//                                                               nil];
//
//                [self getDataPoint:dataPoint RecvData:recvData];
//
//
//                [recvData replaceBytesInRange:NSMakeRange(0, recvData.length) withBytes:nil length:0];
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:kQueryDeviceDataPoint object:@{@"result" : @(0), @"device" : [recvDataDic objectForKey:@"device"], @"dataPoint" : dataPoint}];
//
//            }else{
//                return;
//            }

        }

    }
    
    
}

-(void)getDataPoint:(NSMutableArray *)dataPoint RecvData:(NSMutableData *)recvData{
    /*aaaa 0000 c8 00
     开关    灯开关    玻璃门除雾开关状态    温度单位    温度设定值    湿度设定值    实际温度值    实际湿度    工作状态    故障
    <01       01        01                  01      24          81          4e          14 0000
     */
    //1  开关 1byte 0=关，1=开
    [dataPoint replaceObjectAtIndex:0 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(0, 1)]]];
    
    //2  灯开关 1byte 0=关，1=开
    [dataPoint replaceObjectAtIndex:1 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(1, 1)]]];
    
    //3  玻璃门除雾开关状态 1byte 0=关，1=开
    [dataPoint replaceObjectAtIndex:2 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(2, 1)]]];
    
    //4  温度单位 1byte 0=关，1=开
    [dataPoint replaceObjectAtIndex:3 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(3, 1)]]];
    
    //5  温度设定值 1byte 5~20 步长为1
    [dataPoint replaceObjectAtIndex:4 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(4, 1)]]];
    
    //6  湿度设定值 1byte 20~99 步长为1
    [dataPoint replaceObjectAtIndex:5 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(5, 1)]]];
    
    //7  实际温度值 1byte 0~129 步长为1(实际温度为值-30)
    [dataPoint replaceObjectAtIndex:6 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(6, 1)]]];
    
    //8  实际湿度 1byte 0~99 步长为1
    [dataPoint replaceObjectAtIndex:7 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(7, 1)]]];
    
    //9  工作状态 1byte 0=制冷 1=恒温 2=制热
    [dataPoint replaceObjectAtIndex:8 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(8, 1)]]];
    
    //10 故障 1byte 0=正常 1=E1 2=E2 。。。。 10=E10
    [dataPoint replaceObjectAtIndex:9 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(9, 1)]]];
}

-(void)sendPacket:(PacketModel *)packetModel withDevice:(DeviceEntity *)deviceEntity{
    
    static unsigned short serial = 0;
    
    serial++;
    
    packetModel.serial = serial;
    
    if (!_packetList) {
        _packetList = [NSMutableArray array];
    }
    
    [_packetList addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"device" : deviceEntity, @"time" : @(3), @"packetModel" : packetModel}]];
    
    [self performSelectorOnMainThread:@selector(createTimeOutThread) withObject:nil waitUntilDone:YES];
    
    NSLog(@"%@", [packetModel getData]);
    
    if (deviceEntity.isLANOnline) {
        
        [[XLinkExportObject sharedObject] sendLocalPipeData:deviceEntity andPayload:[packetModel getData]];
        
    }else if (deviceEntity.isWANOnline){
        
        [[XLinkExportObject sharedObject] sendPipeData:deviceEntity andPayload:[packetModel getData]];

    }else{

    }
    
}

-(void)createTimeOutThread{
    if (!_timeOutThread) {
        NSLog(@"startTime_1");
        _timeOutThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimeOutThread) object:nil];
        [_timeOutThread start];
    }
}

-(void)startTimeOutThread{
    _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTimeOut) userInfo:nil repeats:YES];
    NSLog(@"startTime_2");
    while ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
        
    }
    _timeOutThread = nil;
}

@end
