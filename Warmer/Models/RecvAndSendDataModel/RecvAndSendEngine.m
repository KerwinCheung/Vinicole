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

        while (recvData.length >= 13) {
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
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           [NSMutableData dataWithLength:1],
                                                           nil];
            
            [self getDataPoint:dataPoint RecvData:recvData];
            
            
            [recvData replaceBytesInRange:NSMakeRange(0, recvData.length) withBytes:nil length:0];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kQueryDeviceDataPoint object:@{@"result" : @(0), @"device" : [recvDataDic objectForKey:@"device"], @"dataPoint" : dataPoint}];
            
            return;
            headIndex = 0;
            UInt16 recvDataChar[recvData.length];
            [recvData getBytes:recvDataChar length:recvData.length];
            //找到包头
            while (headIndex < recvData.length && (recvDataChar[headIndex] != DATAPACKETHEAD)) {
                headIndex++;
            }
            
            //如果找不到包头
            if (headIndex >= recvData.length) {
                recvData.length = 0;
                return;
            }
            
            //如果包头不是第一位，把包头前面的数据删掉
            if (headIndex != 0) {
                [recvData replaceBytesInRange:NSMakeRange(0, headIndex) withBytes:nil length:0];
                [recvData getBytes:recvDataChar length:recvData.length];
            }

            //获取头
            NSData *headData = [NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(0, 1)]];
            UInt16 head;
            [headData getBytes:&head length:1];
            
            if (head == DATAPACKETHEAD) {
                //状态数据
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
                                                               [NSMutableData dataWithLength:1],
                                                               [NSMutableData dataWithLength:1],
                                                               nil];
                
                [self getDataPoint:dataPoint RecvData:recvData];
                
                
                [recvData replaceBytesInRange:NSMakeRange(0, recvData.length) withBytes:nil length:0];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kQueryDeviceDataPoint object:@{@"result" : @(0), @"device" : [recvDataDic objectForKey:@"device"], @"dataPoint" : dataPoint}];
                
            }else{
                return;
            }

        }

    }
    
    
}

-(void)getDataPoint:(NSMutableArray *)dataPoint RecvData:(NSMutableData *)recvData{
    /*aaaa 0000 c8 00 
     01 01 01 01 01 01 01 00 00 21 23 59
     00 5555
     */
    //1开关机（1byte）
    [dataPoint replaceObjectAtIndex:0 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(0, 1)]]];
    
    //2功能（1byte）
    [dataPoint replaceObjectAtIndex:1 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(1, 1)]]];
    //3运行的时钟（1byte）
    [dataPoint replaceObjectAtIndex:2 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(2, 1)]]];
    //4运行的分钟（1byte）
    [dataPoint replaceObjectAtIndex:3 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(3, 1)]]];
    //5运行的秒（1byte）
    [dataPoint replaceObjectAtIndex:4 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(4, 1)]]];
    //6速度（1byte）
    [dataPoint replaceObjectAtIndex:5 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(6, 1)]]];
    //7当前的温度（1byte）
    [dataPoint replaceObjectAtIndex:6 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(7, 1)]]];
    //8备用（1byte）
    [dataPoint replaceObjectAtIndex:7 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(8, 1)]]];
    //9故障（1byte）
    [dataPoint replaceObjectAtIndex:8 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(9, 1)]]];
    /*10工作状态显示（1byte）
     Bit4~bit7:0=无工作状态显示 1=完成 2=加热 3=搅拌 4=暂停
     Bit0~bit3: 0=无工作状态显示 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY 0x07 其他：预留*/
    [dataPoint replaceObjectAtIndex:9 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(10, 1)]]];
    
    //11预约剩余小时（1byte）
    [dataPoint replaceObjectAtIndex:10 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(11, 1)]]];
    //12预约剩余分钟（1byte）
    [dataPoint replaceObjectAtIndex:11 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(12, 1)]]];
    //13设置的保温温度
    [dataPoint replaceObjectAtIndex:12 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(5, 1)]]];
    
    /*
    //1开关机（1byte）
    [dataPoint replaceObjectAtIndex:0 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(6, 1)]]];
 
    //2功能（1byte）
    [dataPoint replaceObjectAtIndex:1 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(7, 1)]]];
    //3运行的时钟（1byte）
    [dataPoint replaceObjectAtIndex:2 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(8, 1)]]];
    //4运行的分钟（1byte）
    [dataPoint replaceObjectAtIndex:3 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(9, 1)]]];
    //5运行的秒（1byte）
    [dataPoint replaceObjectAtIndex:4 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(10, 1)]]];
    //6速度（1byte）
    [dataPoint replaceObjectAtIndex:5 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(11, 1)]]];
    //7当前的温度（1byte）
    [dataPoint replaceObjectAtIndex:6 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(12, 1)]]];
    //8备用（1byte）
    [dataPoint replaceObjectAtIndex:7 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(13, 1)]]];
    //9故障（1byte）
    [dataPoint replaceObjectAtIndex:8 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(14, 1)]]];
     */
    /*10工作状态显示（1byte） 
    Bit4~bit7:0=无工作状态显示 1=完成 2=加热 3=搅拌 4=暂停
    Bit0~bit3: 0=无工作状态显示 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY 0x07 其他：预留
     */
    /*
    [dataPoint replaceObjectAtIndex:9 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(15, 1)]]];

    //11预约剩余小时（1byte）
    [dataPoint replaceObjectAtIndex:10 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(16, 1)]]];
    //12预约剩余分钟（1byte）
    [dataPoint replaceObjectAtIndex:11 withObject:[NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(17, 1)]]];
     */
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
