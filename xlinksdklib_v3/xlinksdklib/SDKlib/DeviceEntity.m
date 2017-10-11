//
//  DeviceEntity.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/8.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "DeviceEntity.h"
#import "ExtHeader.h"
#import "FixHeader.h"
#import "PingPacket.h"
#import "SenderEngine.h"
#import "XLinkCoreObject.h"
#import "XLinkExportObject.h"
#import "Utils.h"

@implementation DeviceEntity{
    NSMutableDictionary *_valueSetDic;
    
    NSData *_partDispointData;
    
    int _part_datapoint_flag;
    
    //    int _part_name_flag;
    
    NSString *_ticketStr;
    
    BOOL _isTimerSuppend;
    
    BOOL _isHeatInit;
    
//    BOOL _isConnecting;             // 是否正在连接设备
//    BOOL _isConnected;              // 已经和设备连接上
    
    BOOL _userDisconnect;           // 用户断开
    
    time_t _lastDisconnectTime;     // 上次断开的时间
    
    BOOL    _HeartBeating;           // 是否正在进行心跳
    int     _localKeepAliveInterval; // 本地心跳监听
    
    NSTimer *_pingTimer;
    
    NSString * _localAddress;       // 内网通讯IP
}

-(void)initPropertyWithData:(NSData *)data{
    if (data.length) {
        if ([self isHaveDeviceName]) {
            
            if (data.length>2) {
                unsigned short nameLen;
                [data getBytes:&nameLen range:NSMakeRange(0, 2)];
                nameLen = ntohs(nameLen);
                int temp = 2+nameLen;
                
                if (data.length>temp ||data.length == temp) {
                    NSData * nameData = [data subdataWithRange:NSMakeRange(2, nameLen)];
                    _deviceName = [NSString stringWithUTF8String:[nameData bytes]];
                }
            }
            //
        }
        
        if ([self isHaveDataPoint]) {
            
            if ([self isHaveDeviceName]) {
                unsigned short nameLen;
                [data getBytes:&nameLen range:NSMakeRange(0, 2)];
                nameLen = ntohs(nameLen);
                _partDispointData = [data subdataWithRange:NSMakeRange(2+nameLen, data.length - 2 - nameLen)];
            }else{
                _partDispointData = [data subdataWithRange:NSMakeRange(0, data.length)];
            }
            
        }
        
    }
}

- (void)startHeatBeat{
    if( _localKeepAliveInterval == 0 ) {
        _localKeepAliveInterval = 30;
    }
    
    if( _pingTimer == nil ) {
        [self performSelector:@selector(startPingTimer) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:nil waitUntilDone:YES];
    }
}

-(void)startPingTimer{
    [NSThread currentThread].name = @"Ping Cloud Thread";
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:_localKeepAliveInterval / 3 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
}

- (void)stopHeatBeat {
    _lastGetPingReturn = 0;
    if( _pingTimer != nil ) {
        [_pingTimer invalidate];
        _pingTimer = nil;
    }
}

-(void)heartBeat {
    
    // 如果内网有连接
    if (_connectStatus & ConnectStatusLANConnectSuccessfully) {
//        if( _sessionID > -1 ){
        
            if( _lastGetPingReturn == 0 ) {
                _lastGetPingReturn = [[NSDate date] timeIntervalSince1970];
            }
            
            int interval =(int)([[NSDate date] timeIntervalSince1970]- _lastGetPingReturn);
            
            NSLog(@"上次心跳间隔%d", interval);
            
            if (abs(interval) > (_localKeepAliveInterval * 1.5)) {
                NSLog(@"心跳超时，设备下线了");
                _sessionID = -1;
                _HeartBeating = NO;
                
                [self onDisconnectByConnectStatus:ConnectStatusLANConnectFailed];
                
                // 关闭计时器
                if( _pingTimer != nil) {
                    [_pingTimer invalidate];
                    _pingTimer = nil;
                }
                
                // 开始一个自动重练
//                NSLog(@"心跳超时，自动重连");
//                [[XLinkCoreObject sharedCoreObject] reconnectDevice:self];
                
                return;
            }
            
            PingPacket *ping = [[PingPacket alloc]initWithSessionID:[self getSessionID]];
            
            FixHeader *fix = [[FixHeader alloc] initWithInfo:PING_REQ_FLAG andDataLen:[ping getPacketSize]];
            
            NSMutableData *sendData = [fix getPacketData];
            
            [sendData appendData:[ping getPacketData]];
            
            [[SenderEngine sharedEngine] udpSendDevice:self andData:sendData];
        }
//    }
    
}

-(BOOL)getInitStatus{
    return [self isDeviceInitted];
}

-(BOOL)isDeviceInitted{
    unsigned char tempFlag = self.flag;
    BOOL isValid = (BOOL)(tempFlag>>2&1);
    return isValid;
}

-(BOOL)isDeviceBinded {
    unsigned char tempFlag = self.flag;
    BOOL binded = (BOOL)(tempFlag >> 3 & 1);
    return binded;
}

-(BOOL)isHaveDeviceName{
    unsigned char  tempFlag = self.flag;
    BOOL isValid = (BOOL)(tempFlag>>0&1);
    return isValid;
}

-(BOOL)isHaveDataPoint{
    unsigned char  tempFlag = self.flag;
    BOOL isValid = (BOOL)(tempFlag>>1&1);
    return isValid;
}

-(void)setDeviceInit:(BOOL)init {
    unsigned char tempFlag = self.flag;
    if( init ) {
        tempFlag |= 0x04;   // 标志为置1
    } else {
        tempFlag &= 0xFB;   // 标志为清0
    }
    self.flag = tempFlag;
}

-(void)setLastgetPingReturn:(double)time{
    //    NSLog(@"收到上次心跳间隔%d", (int)(time - _lastGetPingReturn));
    _lastGetPingReturn = time;
}

-(NSString *)getMacAddressString{
    
    if (_macAddress.length) {
        unsigned char buff[_macAddress.length];
        memset(buff, 0, _macAddress.length);
        [_macAddress getBytes:buff length:_macAddress.length];
        
        NSString *macStr = [NSString stringWithFormat:@"%02x",(Byte)buff[0]];
        for (NSUInteger i = 1; i < _macAddress.length; i++) {
            macStr = [macStr stringByAppendingString:[NSString stringWithFormat:@"%02x",(Byte)buff[i]]];
        }
        
        return macStr;
    }
    return nil;
}

-(NSString *)getMacAddressSimple{
    if (self.macAddress.length) {
        
        unsigned char buff[self.macAddress.length];
        memset(buff, 0, self.macAddress.length);
        [self.macAddress getBytes:buff length:self.macAddress.length];
        
        NSMutableString *macStr = [NSMutableString string];
        
        for (NSUInteger i = 0; i < self.macAddress.length; i++) {
            [macStr appendFormat:@"%02X", (Byte)buff[i]];
        }
        
        return [NSString stringWithString:macStr];
        
    }return nil;
}

-(NSString *)getLocalAddress{
    //没有内网
    if((_connectStatus & ConnectStatusLANConnectSuccessfully) == 0) {
        return @"";
    }
    
    if( _localAddress == nil ) {
        return self.fromIP;
    }
    
    return _localAddress;
}

-(void)initProperty {
    _version = 1;
    
    _localKeepAliveInterval = 30;
    
    _HeartBeating = NO;
    
    _deviceName = @"";
    
    _connectStatus = ConnectStatusLANAndWANConnectFailed;
}

-(NSDictionary *)getDictionaryFormatWithProtocol:(int)protocol {
    
    NSMutableDictionary * dictFormat = [[NSMutableDictionary alloc] init];
    
    if( protocol == 1 ) {
        
        NSMutableDictionary * device = [[NSMutableDictionary alloc] init];
        
        /*
         {
         "protocol": 1,
         "device": {
         "version": 1,
         "deviceID": 1234,
         "deviceName": "设备名称",
         "deviceIP": "192.168.1.127",
         "devicePort": 5987,
         "macAddress": "8C8C8C8C8C8C",
         "deviceInit": true,
         "mcuHardVersion": 1,
         "mucSoftVersion": 1,
         "productID": "faf9a0964c3c450a9c2a6dbbe0028391"
         }
         }
         */
        
        // version
        [device setObject:[NSNumber numberWithInt:_version] forKey:@"version"];
        
        // deviceID
        [device setObject:[NSNumber numberWithInt:_deviceID] forKey:@"deviceID"];
        
        // deviceName
        [device setObject:_deviceName forKey:@"deviceName"];
        
        // deviceIP
        if (self.fromIP) {
            [device setObject:self.fromIP forKey:@"deviceIP"];
        }
        
        // devicePort
        [device setObject:[NSNumber numberWithInt:self.devicePort] forKey:@"devicePort"];
        
        // macAddress
        [device setObject:[self getMacAddressSimple] forKey:@"macAddress"];
        
        // init
        [device setObject:[NSNumber numberWithBool:[self isDeviceInitted]] forKey:@"deviceInit"];
        
        // mcuHardVersion
        [device setObject:[NSNumber numberWithInt:self.mcuHardVersion] forKey:@"mcuHardVersion"];
        
        // mcuSoftVersion
        [device setObject:[NSNumber numberWithInt:self.mcuSoftVersion] forKey:@"mcuSoftVersion"];
        
        // productid
        [device setObject:self.productID forKey:@"productID"];
        
        if (_accessKey) {
            [dictFormat setObject:_accessKey forKey:@"accessKey"];
        }
        
        [dictFormat setObject:@(_subKey) forKey:@"subKey"];
        
        // to dict
        [dictFormat setObject:device forKey:@"device"];
        [dictFormat setObject:[NSNumber numberWithInt:protocol] forKey:@"protocol"];
        
        /* 测试，打出JSON窜
         NSError *error = nil;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictFormat
         options:NSJSONWritingPrettyPrinted
         error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData
         encoding:NSUTF8StringEncoding];
         
         NSLog(@"Device json: %@", jsonString);
         */
    } else if( protocol == 100 ) {
        // for old android
        [dictFormat setObject:[NSNumber numberWithInt:_deviceID] forKey:@"did"];
        [dictFormat setObject:_deviceName forKey:@"dname"];
        [dictFormat setObject:[NSNumber numberWithInt:[self isDeviceInitted]] forKey:@"init"];
        [dictFormat setObject:_fromIP forKey:@"ip"];
        [dictFormat setObject:[self getMacAddressSimple] forKey:@"mac"];
        [dictFormat setObject:[NSNumber numberWithInt:_mcuHardVersion] forKey:@"mhv"];
        [dictFormat setObject:[NSNumber numberWithInt:_mcuSoftVersion] forKey:@"msv"];
        [dictFormat setObject:_productID forKey:@"pid"];
        [dictFormat setObject:[NSNumber numberWithInt:_devicePort] forKey:@"port"];
        [dictFormat setObject:[NSNumber numberWithInt:_version] forKey:@"version"];
        if (_accessKey) {
            [dictFormat setObject:_accessKey forKey:@"accessKey"];
        }
        [dictFormat setObject:@(_subKey) forKey:@"subKey"];
        
    }
    
    return dictFormat;
}

-(NSDictionary *)getDictionaryFormat{
    
    NSMutableDictionary * dictFormat = [[NSMutableDictionary alloc] init];
    
    
    
    if (self.version) {
        [dictFormat setObject:[NSString stringWithFormat:@"%d",self.version] forKey:@"version"];
    }
    
    if (self.macAddress.length) {
        [dictFormat setObject:[self getMacAddressSimple] forKey:@"macAddress"];
    }
    
    if(self.productID.length ==32){
        [dictFormat setObject:self.productID forKey:@"productID"];
    }
    
    [dictFormat setObject:[NSString stringWithFormat:@"%d",self.mcuHardVersion] forKey:@"mcuHardVersion"];
    [dictFormat setObject:[NSString stringWithFormat:@"%d",self.mcuSoftVersion] forKey:@"mcuSoftVersion"];
    
    if (self.deviceKey) {
        [dictFormat setObject:self.deviceKey forKey:@"deviceKey"];
    }
    
    
    [dictFormat setObject:[NSString stringWithFormat:@"%d",self.devicePort] forKey:@"devicePort"];
    [dictFormat setObject:[NSString stringWithFormat:@"%d",_deviceID] forKey:@"deviceID"];
    if (self.fromIP) {
        [dictFormat setObject:self.fromIP forKey:@"fromIP"];
    }
    
    if (_deviceName) {
        [dictFormat setObject:_deviceName forKey:@"deviceName"];//崩溃
    }
    
    if (_accessKey) {
        [dictFormat setObject:_accessKey forKey:@"accessKey"];
    }
    
    [dictFormat setObject:@(_subKey) forKey:@"subKey"];
    
    [dictFormat setObject:@(_deviceType) forKey:@"deviceType"];
    
    [dictFormat setObject:[NSString stringWithFormat:@"%d",self.flag] forKey:@"flag"];
    
    return dictFormat;
}

-(id)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        
        [self initProperty];
        
        if( [dict objectForKey:@"protocol"] != nil ) {
            
            int formatProtocol = [[dict objectForKey:@"protocol"] intValue];
            
            [self initWithDictionary:dict andProtocol:formatProtocol];
            
        } else {
            
            if( [dict objectForKey:@"did"] != nil && [dict objectForKey:@"dname"] != nil ) {
                // 兼容旧android的格式
                
                self.version = [[dict objectForKey:@"version"] intValue];
                
                self.deviceID = [[dict objectForKey:@"did"] intValue];
                
                _deviceName = [dict objectForKey:@"dname"];
                
                int init = [[dict objectForKey:@"init"] intValue];
                if( init == 1 ) {
                    self.flag |= 0x04;
                }
                
                self.fromIP = [dict objectForKey:@"ip"];
                
                NSString * macAddress = [dict objectForKey:@"mac"];
                if( macAddress != nil && [macAddress length] > 0 ) {
                    self.macAddress = [Utils hexToData:macAddress];
                }
                
                self.mcuHardVersion = [[dict objectForKey:@"mhv"] intValue];
                
                self.mcuSoftVersion = [[dict objectForKey:@"msv"] intValue];
                
                self.productID = [dict objectForKey:@"pid"];
                
                self.devicePort = [[dict objectForKey:@"port"] intValue];
                
                self.deviceType = [[dict objectForKey:@"deviceType"] unsignedShortValue];
                
                self.accessKey = [dict objectForKey:@"accessKey"];
                
                self.subKey = [[dict objectForKey:@"subKey"] intValue];
                
            } else {
                
                self.version = [[dict objectForKey:@"version"] intValue];
                
                //                self.macAddress = [dict objectForKey:@"macAddress"];
                NSString * macAddress = [dict objectForKey:@"macAddress"];
                if( macAddress != nil && [macAddress length] > 0 ) {
                    self.macAddress = [Utils hexToData:macAddress];
                }
                
                self.productID = [dict objectForKey:@"productID"];
                
                self.mcuHardVersion = [[dict objectForKey:@"mcuHardVersion"]intValue];
                
                
                self.mcuSoftVersion = [[dict objectForKey:@"mcuSoftVersion"]intValue];
                
                self.deviceKey = [dict objectForKey:@"deviceKey"];
                
                self.deviceID = [[dict objectForKey:@"deviceID"] intValue];
                
                self.fromIP = [dict objectForKey:@"fromIP"];
                
                self.devicePort = [[dict objectForKey:@"devicePort"] intValue];
                
                self.flag = [[dict objectForKey:@"flag"] intValue];
                
                _deviceName = [dict objectForKey:@"deviceName"];
                
                self.deviceType = [[dict objectForKey:@"deviceType"] unsignedShortValue];
                
                self.accessKey = [dict objectForKey:@"accessKey"];
                
                self.subKey = [[dict objectForKey:@"subKey"] intValue];
                
            }
        }
    }
    return self;
}

-(void)initWithDictionary:(NSDictionary *)propertyDict andProtocol:(int)protocol{
    
    if( protocol == 1 ) {
        
        // Device dict
        NSDictionary * dict = [propertyDict objectForKey:@"device"];
        if( dict != nil ) {
            
            /*
             {
             "protocol": 1,
             "device": {
             "version": 1,
             "deviceID": 1234,
             "deviceName": "设备名称",
             "deviceIP": "192.168.1.127",
             "devicePort": 5987,
             "macAddress": "8C8C8C8C8C8C",
             "deviceInit": true,
             "mcuHardVersion": 1,
             "mucSoftVersion": 1,
             "productID": "faf9a0964c3c450a9c2a6dbbe0028391"
             }
             }
             */
            
            // version
            self.version = [[dict objectForKey:@"version"] intValue];
            
            // deviceID
            self.deviceID = [[dict objectForKey:@"deviceID"] intValue];
            
            // deviceName
            _deviceName = [dict objectForKey:@"deviceName"];
            
            // deviceIP
            self.fromIP = [dict objectForKey:@"deviceIP"];
            
            // devicePort
            self.devicePort = [[dict objectForKey:@"devicePort"] intValue];
            
            // macAddress
            NSString * macAddress = [dict objectForKey:@"macAddress"];
            if( macAddress != nil && [macAddress length] > 0 ) {
                self.macAddress = [Utils hexToData:macAddress];
            }
            
            // init
            self.flag = [[dict objectForKey:@"flag"] intValue];
            BOOL init = [[dict objectForKey:@"deviceInit"] boolValue];
            if( init ) {
                self.flag |= 0x04;
            }
            
            // mcuHardVersion
            self.mcuHardVersion = [[dict objectForKey:@"mcuHardVersion"]intValue];
            
            // mucSoftVersion
            self.mcuSoftVersion = [[dict objectForKey:@"mcuSoftVersion"]intValue];
            
            // productID
            self.productID = [dict objectForKey:@"productID"];
            
            // 扩展属性
            self.deviceKey = [dict objectForKey:@"deviceKey"];
        }
        else {
            NSLog(@"Error protocol device node missed.");
        }
    } else {
        NSLog(@"Error format protocol unsupport.");
    }
}

-(id)initWithMac:(NSString *)mac andProductID:(NSString *)pid {
    self = [self init];
    if (self) {
        
        [self initProperty];
        
        [self setProductID:pid];
        self.macAddress = [Utils hexToData:mac];
        [self setDeviceInit:YES];
    }
    return self;
}

-(void)setSessionID:(int16_t)sessionID{
    _sessionID = sessionID;
}

-(int)getSessionID{
    return _sessionID;
}

-(void)setTicketString:(NSString *)ticket{
    _ticketStr = [[NSString alloc]initWithString:ticket];
}

-(NSString *)getTicketString{
    return _ticketStr;
}

-(void)setDeviceID:(int32_t)deviceId{
    _deviceID = deviceId;
}

-(int)getDeviceID{
    return _deviceID;
}

/*
 *成员变量初始化
 */
-(id)init{
    self = [super init];
    if (self) {
        
        [self initProperty];
        
        //        _dataPoint = [[NSMutableData alloc]init];
        _valueSetDic = [[NSMutableDictionary alloc]init];
        
        //        _dataPointModel = @"[{\"index\":0,\"type\":1},{\"index\":1,\"type\":1},{\"index\":2,\"type\":1}, {\"index\":3,\"type\":1}]";
        
        _deviceKey =nil;
    }
    return self;
}

/*
 *设置解析模版  解析模版
 */
//-(void)setDataPointModel:(NSString *)dataPointModel{
//
//    if (!dataPointModel) {
//        return;
//    }
//    if (dataPointModel.length == 0) {
//        return;
//    }
//
//
//    if (!_dataPointModel) {
//        _dataPointModel = [[NSString alloc]initWithString:dataPointModel];
//
//    }else{
//        _dataPointModel = nil;
//        _dataPointModel = [[NSString alloc]initWithString:dataPointModel];
//    }
//
//}

-(NSString *)getDeviceKeyString{
    return _deviceKey;
}

-(NSData *)getDeviceKeyData{
    return [_deviceKey dataUsingEncoding:NSUTF8StringEncoding];
}


/*
 *设置deviceKey
 */

-(void)setDeviceKey:(NSString *)deviceKey{
    
    if (!deviceKey) {
        return;
    }
    
    if (deviceKey.length == 0) {
        return;
    }
    
    if (!_deviceKey) {
        
        if ([_deviceKey isEqualToString:deviceKey]) {
            return;
        }else{
            _deviceKey = nil;
            _deviceKey = [[NSString alloc]initWithString:deviceKey];
        }
    }
    
}
/*
 *@discussion
 *  重置设备状态
 */
-(void)resetDevice{
    _part_datapoint_flag = 0;
    [_valueSetDic removeAllObjects];
}

-(bool)isConnected{
    return (bool)(_connectStatus & ConnectStatusLANAndWANConnectSuccessfully);
}

-(bool)isConnecting{
    return (![self isConnected] && _connectStatus != ConnectStatusLANAndWANConnectFailed);
}

-(bool)isLANOnline{
    return (bool)(_connectStatus & ConnectStatusLANConnectSuccessfully);
}

-(bool)isWANOnline{
    return (bool)(_connectStatus & ConnectStatusWANConnectSuccessfully);
}

- (void)onConnected {
    _userDisconnect = NO;
    
    // 本地设备，需要内网维护心态
    if(_connectStatus & ConnectStatusLANConnectSuccessfully) {
        [self startHeatBeat];
    }
}

- (void)onDisconnectByConnectStatus:(ConnectStatus)connectStatus{
    //有改变
    if ((_connectStatus | connectStatus) != _connectStatus) {
        _lastDisconnectTime = time(NULL);
        if (connectStatus == ConnectStatusLANConnectFailed) {
            _connectStatus = (_connectStatus & 0b1100) | ConnectStatusLANConnectFailed;
            [self stopHeatBeat];
        }else if (connectStatus == ConnectStatusWANConnectFailed){
            _connectStatus = (_connectStatus & 0b0011) | ConnectStatusWANConnectFailed;
        }else if (connectStatus == ConnectStatusLANAndWANConnectFailed){
            _connectStatus = ConnectStatusLANAndWANConnectFailed;
            [self stopHeatBeat];
        }
        if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onDeviceStatusChanged:)]) {
            [[XLinkExportObject sharedObject].delegate onDeviceStatusChanged:self];
        }
    }
}

-(void)onNetworkChange{
    if (_userDisconnect) {
        NSLog(@"用户手动断开的设备，不要自动重连.");
    }else{
        if (_lastDisconnectTime != 0 || (_connectStatus & 0b0101)) {
            //连接过的设备重新连接
            [self onDisconnectByConnectStatus:ConnectStatusLANAndWANConnectFailed];
            [[XLinkCoreObject sharedCoreObject] reconnectDevice:self];
        }
    }
}

- (void)onAppLogined{
    
    if (_userDisconnect) {
        NSLog(@"用户手动断开的设备，不要自动重连.");
    }else{
        if ((_connectStatus & 0b1000) && _lastDisconnectTime != 0) {
            //未连接的设备和连接过的设备重新连接
            NSLog(@"APP重新登录，重新连接设备 %@ %d", [self getMacAddressString], [self deviceID]);
            [self onDisconnectByConnectStatus:ConnectStatusLANAndWANConnectFailed];
            [[XLinkCoreObject sharedCoreObject] reconnectDevice:self];
        }
    }
}

-(void)onAppLogout{
    [self onDisconnectByConnectStatus:ConnectStatusWANConnectFailed];
}

- (void)userDisconnect {
    _userDisconnect = YES;
//    _lastUserDisconnect = time(NULL);
    [self onDisconnectByConnectStatus:ConnectStatusLANAndWANConnectFailed];
}

- (BOOL)isUserDisconnect {
    return _userDisconnect;
}

-(int)getLocalKeepAlive {
    return _localKeepAliveInterval;
}

-(void)setLocalAddress:(NSString *)ip {
    _localAddress = ip;
}

@end
