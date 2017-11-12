//
//  SenderEngine.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "SenderEngine.h"
#import <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>
#import "GCDAsyncUdpSocket.h"


#import "XLinkExportObject.h"
#import "XLinkCoreObject.h"
#import "ScanHeader.h"
#import "ProbeHeaderPacket.h"
#import "PacketParseEngine.h"
#import "SetHeaderPacket.h"
#import "SetACKPacket.h"
#import "LoginPacket.h"
#import "ExtPacketParse.h"
#import "FixHeader.h"
#import "SetPSWDPacket.h"
#import "DeviceEntity.h"
#import "DataPointEntity.h"
#import "SetPSWDPacket.h"
#import "ExtFixHeader.h"
#import "PingPacket.h"
#import "PipePacket.h"
#import "AppPipeDevicePacket.h"
#import "ShakeHandWithPSWDPacket.h"
#import "SubscribeByAuthPacket.h"
#import "CloudSetAuthPacket.h"
#import "SetExtPacket.h"
#import "CloudProbePacket.h"
#import "SDKProperty.h"
#import "SubKeyHeader.h"
#import "SetLocalDataPointPacket.h"
#import "SetCloudDataPointPacket.h"

#define MSG_TYPE_SET_LOCAL_AUTH 11
#define MSG_TYPE_SEND_LOCAL_PIPE 22
#define MSG_TYPE_SUBSCRIBE_CLOUD 33
#define MSG_TYPE_SET_CLOUD_AUTH 44
#define MSG_TYPE_SEND_CLOUD_PIPE 55


//#define External_IP @"cm.xlink.cn"
//#define External_IP @"io.xlink.cn"
//#define External_IP @"52.18.176.89"

#define External_port 23778
// #define External_port 23779


#define Http_port 80


#define HttpHeader_Str @"CONNECT %s:%d HTTP/1.1\r\nHost: %s:%d\r\n\r\n"


static SenderEngine * _shareEngine;


@interface SenderEngine ()<NSURLConnectionDataDelegate>


@end


@implementation SenderEngine{
    
    NSMutableDictionary *_sslSetting;
    
    dispatch_source_t _timer;
    
    NSString *_currentIp;
    
    int _appID;
    
    NSString *_authStr;
    
    NSMutableData *_httpReceiveData;
    
    dispatch_source_t _extTimer;
    
    ExtFixHeader * _fix;
    
    LoginPacket  *_login;
    
    
    struct {
        
        unsigned short isHttpConnected:1;
        unsigned short isHttpConnectSuccessed:1;
        unsigned short isGoHttpProxy:1;
        
        unsigned short isDirectConnected:1;
        unsigned short isDirectConnectedSucessed:1;
        unsigned short isGoDirect:1;
        
        
        unsigned short isLoginSuccessed:1;
        unsigned short isTcpConnected:1;
        
    }_flag;
    
    // 线程锁
    NSLock * _lock;
    
    // 用户关闭
    BOOL    _userClose;
}

//md5运算
- (NSString *) md5:(NSString *) input
{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
    
}

- (NSString *)getServerAddress {
    return [[SDKProperty sharedProperty] getProperty:PROPERTY_CM_SERVER_ADDR];
}

-(NSData *)getPasswordHash:(NSNumber *)input withDevice:(DeviceEntity *)device{
    if( input == nil ) {
        NSLog(@"password input is nil");
        input = @(0);
    }
    
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    
    if (device.version == 1) {
        const char* ack_char = [[input stringValue] UTF8String];
        CC_MD5(ack_char, (uint32_t)strlen(ack_char), md5);
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            md5[i]^=53;
        }
    }else{
        const unsigned int ack_int = input.unsignedIntValue;
        CC_MD5(&ack_int, sizeof(ack_int), md5);
    }
    
    
    
    return [NSData dataWithBytes:md5 length:CC_MD5_DIGEST_LENGTH];
    
}


//-(NSData *)getPasswordData:(NSString *)password{
//    
//    NSString *md5Str = [self md5:password];
//    NSData *mdData = [md5Str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (mdData.length!=16) {
//        return nil;
//    }
//    
//    unsigned char buf[mdData.length];
//    [mdData getBytes:buf range:NSMakeRange(0, mdData.length)];
//    
//    unsigned char cypBuf[mdData.length];
//    for (int i=0; i<16; i++) {
//        cypBuf[i] = buf[i]^53;
//    }
//    
//    NSData *retData = [[NSData alloc]initWithBytes:cypBuf length:mdData.length];
//    
//    return retData;
//    
//}



-(void)directSendData:(NSData *)data{
    if (_externalSocket) {
        [_externalSocket writeData:data withTimeout:-1 tag:0];
    }
}

-(void)udpSendDevice:(DeviceEntity *)device andData:(NSData *)data{
    [_lock lock];
    
    if (_udpSocket) {
        if( ![_udpSocket isClosed] ) {
            [_udpSocket sendData:data toHost:device.fromIP port:device.devicePort withTimeout:-1 tag:0];
            [_udpSocket beginReceiving:nil];
        } else {
            NSLog(@"[WARRING] UDP Socket is closed!");
        }
    }
    
    [_lock unlock];
}

-(DeviceEntity *)getSubscriptionDeviceByMsgID:(int)msgID{
    if (_subscription) {
        DeviceEntity *device = [_subscription objectForKey:[NSString stringWithFormat:@"%d",msgID]];
        return device;
    }
    return nil;
}

+(SenderEngine *)sharedEngine{
    
    @synchronized(self){
        if (_shareEngine==nil) {
            _shareEngine = [[SenderEngine alloc] init];
        }
    }
    
    return _shareEngine;
}


-(void)start{
    
    NSLog(@"XLINK SDK Ver %@ start", XLINK_SDK_VER);
    
    _userClose = NO;
    
    //内网扫描socket
    [self initUdpSocket];
    
    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onStart)]) {
        
        [[XLinkExportObject sharedObject].delegate onStart];
    }
    
}

-(void)stop {
    
    _userClose = YES;
    
    [self uninitUdpSocket];
    
}

- (void)uninitUdpSocket {
    [_lock lock];
    if( _udpSocket ) {
        [_udpSocket close];
        _udpSocket = nil;
    }
    [_lock unlock];
}

-(id)init{
    self = [super init];
    if (self) {
        
        //外网socket
        _externalSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        //添加该设置，使socket支持IPV6的网络(by liang)
        [_externalSocket setIPv4PreferredOverIPv6:NO];

        _subscription = [[NSMutableDictionary alloc]init];
        
        _flag.isHttpConnected = NO;
        
        _flag.isHttpConnectSuccessed =NO;
        
        _sslSetting = [[NSMutableDictionary alloc] init];
        
        //[self configSSLSetting];
        
        _lock = [[NSLock alloc] init];
    }
    
    return self;
    
}

-(void)dealloc {
}

-(void)configSSLSetting{
    
    _sslSetting = [[NSMutableDictionary alloc] init];
    //
    
    //1.得到p12 buffer
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client" ofType:@"bks"]];
    
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
    
    //2.得到密码
    CFStringRef password = CFSTR("password");
    
    //3.key - value
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    //4.密码选项
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    //5.创建item
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    //6.p12与访问密码关联
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    
    //释放内存
    CFRelease(options);
    CFRelease(password);
    
    //7.判断证书是否打开成功
    if(securityError == errSecSuccess)
        NSLog(@"Success opening p12 certificate.");
    
    //8.得到身份字典
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
    
    //9.得到安全证书应用
    SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                  kSecImportItemIdentity);
    
    SecIdentityRef  certArray[1] = { myIdent };
    
    //10.创建证书数组
    CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
    
    //11.设置ssl证书
    [_sslSetting setObject:(id)CFBridgingRelease(myCerts) forKey:(NSString *)kCFStreamSSLCertificates];
    
    
    //12.设置ssl等级
    [_sslSetting setObject:NSStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString *)kCFStreamSSLLevel];
    
    //[_sslSetting setObject:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
    
    //13.设置连接的域名
    [_sslSetting setObject:@"CONNECTION ADDRESS" forKey:(NSString *)kCFStreamSSLPeerName];
    
    
}



//-(void)setListenPort:(int)port{
//
//    if (_scoket) {
//        [_scoket bindToPort:port error:nil];
//    }else{
//        _scoket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
//        [_scoket bindToPort:port error:nil];
//        [_scoket enableBroadcast:YES error:nil];
//    }
//
//
//}


/*
 *@discussion
 *  设备的属性设置
 */
//-(void)sendSetDevice:(DeviceEntity *)aDevice andSessionID:(int)aSessionID andMesaageID:(int)aMsgID{
//
//    if (!aDevice) {
//        return;
//    }
//
//    if (_udpSocket) {
//
//        FixHeader *fix = [FixHeader setFixHeader];
//        SetHeaderPacket *set = [[SetHeaderPacket alloc]initWithSessionID:aSessionID andMessageID:aMsgID andFlag:[aDevice getSettedFlag]];
//        //
//        NSMutableData *tempData = [fix getPacketData];
//
//        [tempData appendData:[set getPacketData]];
////        [tempData appendData:[aDevice getAfterSetDatapointData]];
//
//
////#warning debug print
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"$$$$$$$$$$$$$$$$$$$");
//            [self printByteData:tempData];
//            NSLog(@"$$$$$$$$$$$$$$$$$$$");
//        });
//
//
//        [self udpSendDevice:aDevice andData:tempData];
//
//    }
//
//}

/*
 *@discussion
 *
 *
 */

-(void)sendByeBye:(int)aSessionID andDevice:(DeviceEntity *)aDevice{
    
    if (aSessionID<0) {
        return;
    }
    
    if (_udpSocket) {
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:BYBBYE_REQ_FLAG | aDevice.version andDataLen:2];
        unsigned short session = aSessionID;
        session = htons(session);
        NSMutableData *tempData = [fix getPacketData];
        [tempData appendBytes:&session length:2];
        
        [self udpSendDevice:aDevice andData:tempData];
    }
    
}

-(void)sendPingWithSessionID:(int)aSessionID andDevice:(DeviceEntity *)aDevice{
    
    if (aSessionID<0) {
        return;
    }
    if (_udpSocket) {
        
        _timer = nil;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 160 * NSEC_PER_SEC, 5 * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(_timer, ^{
            
            PingPacket *ping = [[PingPacket alloc] initWithSessionID:aSessionID];
            
            FixHeader *fix = [[FixHeader alloc] initWithInfo:PING_REQ_FLAG | aDevice.version andDataLen:[ping getPacketSize]];
            
            NSMutableData * tempData = [fix getPacketData];
            
            [tempData appendData:[ping getPacketData]];
            
            // #warning debug print
            
            NSLog(@"ping字节");
            
            [self printByteData:tempData];
            
            NSLog(@"end ping字节");
            
            
            [self udpSendDevice:aDevice andData:tempData];
            
        });
        
        dispatch_resume(_timer);
        
    }
    
}

-(void)sendProbeWithSessionID:(int)aSessionID andDevice:(DeviceEntity *)aDevice{
    
    if (aSessionID<0) {
        return;
    }
    
    if (_udpSocket) {
        
        ProbeHeaderPacket *probe = [[ProbeHeaderPacket alloc] initWithSession:aSessionID andFlag:aDevice.flag & 0b00000011];
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:PROBE_REQ_FLAG | aDevice.version andDataLen:[probe getPacketSize]];
        
        NSMutableData *tempdata = [fix getPacketData];
        [tempdata appendData:[probe getPacketData]];
        
        [self udpSendDevice:aDevice andData:tempdata];
    }
}

#pragma mark
#pragma mark 外网 IP：10.0.1.172  PORT:23778

-(void)connect{
    [self connectExternal:[self getServerAddress] andPort:External_port];
}

-(void)connectExternal:(NSString *)aIp andPort:(int)aPort{
    if (_externalSocket) {
        
        NSError *err;
        
        if (_externalSocket.isConnected) {
            [_externalSocket disconnect];
        }
        
        [_externalSocket connectToHost:aIp onPort:aPort error:&err];
        
        NSLog(@"%@",[err localizedDescription]);
        
    }
}


#pragma mark
#pragma mark 用户登录
-(void)loginWithVersion:(int)aVersion andAppID:(int)appId andAuthLength:(int)alen andAuthStr:(NSString *)authStr andKeepLive:(int)aKeepLive{
    
    if (_externalSocket) {
        
        NSLog(@"version = %d",aVersion);
        
        NSLog(@"appid = %d",appId);
        
        NSLog(@"keep live = %d",aKeepLive);
        
        _fix = [ExtFixHeader loginExtFixHeader];
        
        _login = [[LoginPacket alloc]initWithVersion:aVersion andAppID:appId andAuthLen:alen andAuthStr:[authStr dataUsingEncoding:NSUTF8StringEncoding] andReserved:0 andKeepAlive:aKeepLive];
        
        [_externalSocket connectToHost:[self getServerAddress] onPort:External_port withTimeout:10.0 error:nil];
        
        // [self loginByHttpProxyWithHost:External_IP];
        
    }
}

-(void)loginByHttpProxyWithHost:(NSString *)host{
    
    if (_externalSocket) {
        
        _flag.isGoHttpProxy = YES;
        _flag.isGoDirect = NO;
        [_externalSocket connectToHost:host onPort:Http_port error:nil];
        
    }
    
}

-(void)loginByDirectWithHost:(NSString *)host andPort:(int)port{
    if (_externalSocket) {
        _flag.isGoDirect = YES;
        _flag.isGoHttpProxy = NO;
        [_externalSocket connectToHost:host onPort:port error:nil];
    }
}

-(void)senderpipeWithDeviceID:(int)deviceID andMessageID:(int)aMsgID andMessageFlag:(int)aFlag andPlaydata:(NSData *)playdata{
    
    if (_externalSocket) {
        
        ExtFixHeader *fix = [ExtFixHeader pipeExtFixHeader];
        
        PipePacket *pipe = [[PipePacket alloc]initWithDeviceId:deviceID andMessageID:aMsgID andFlag:aFlag];
        
        NSMutableData *temp  = [fix getPacketData];
        
        [temp appendData:[pipe getPacketData]];
        
        [temp appendData:playdata];
        
        [fix setDataLength:(int)[PipePacket getPacketSize]+(int)playdata.length];
        
        NSLog(@"透传发送");
        // NSLog(@">>>pipe>>>");
        // [self printByteData:temp];
        // NSLog(@"<<<pipe<<<");
        
        [_externalSocket writeData:temp withTimeout:-1 tag:aMsgID];
        
        
    }
}

//-(void)ticketWithDevice:(DeviceEntity *)device andAppID:(int)appID andMessageID:(int)msgID andFlag:(int)flag{
//
//    if (_subscription) {
//
//        [_subscription setObject:device forKey:[NSString stringWithFormat:@"%d",msgID]];
//
//    }
//
//    [self ticketWithSessionID:[device getSessionID] andAppID:appID andMessageID:msgID andFlag:flag andDevice:device];
//
//}

-(void)loginExt{
    
    if (_externalSocket) {
        
        NSError *err;
        if (_externalSocket.isConnected) {
            [_externalSocket disconnect];
        }
        
        [_externalSocket connectToHost:[self getServerAddress] onPort:External_port withTimeout:5 error:&err];
        
        if (err) {
            NSLog(@"%@",err);
        }
    }
    
}


-(void)pingExt{
    
    if (!_extTimer) {
        
        _extTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        
        dispatch_source_set_timer(_extTimer, DISPATCH_TIME_NOW, 150 * NSEC_PER_SEC, 5 * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(_extTimer, ^{
            FIX_EXT_HEADER fix;
            fix.MessageInfo = PING_REQ_MESSAGE;
            fix.DataLength = 0;
            
            NSMutableData *tempData = [[NSMutableData alloc]init];
            if (tempData) {
                [tempData appendBytes:&fix length:sizeof(FIX_EXT_HEADER)];
            }
            if (_externalSocket) {
                if ([_externalSocket isConnected]) {
                    [_externalSocket writeData:tempData withTimeout:-1 tag:0];
                }
            }
            
        });
        
        dispatch_resume(_extTimer);
        
    }else{
        
        dispatch_suspend(_extTimer);
        dispatch_resume(_extTimer);
        
    }
}



#pragma mark end外网

#pragma mark
#pragma mark 发送心跳包

-(void)stopHeart{
    
    if (_timer) {
        NSLog(@"停止心跳");
        dispatch_suspend(_timer);
    }
    
}

#pragma mark
#pragma mark 发送下线包


-(void)sendScanWithProductID:(NSString *)productId{
    
    if (_udpSocket) {
        
        //        [_udpSocket isClosed];
        
        NSLog(@"扫描");
        
        //扫描协议头
        ScanHeader *scan = [[ScanHeader alloc] initWithVersion:3 andPort:[[XLinkCoreObject sharedCoreObject] getListenPort] andProductID:productId];
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:SCAN_REQ_FLAG andDataLen:[scan getPacketSize]];
        
        NSMutableData *temp = [fix getPacketData];
        [temp appendData:[scan getPacketData]];
        
        // 扫描总包bytes
        //         [self printByteData:temp];
        
        // 发送广播包
        [self sendBoardcastWithData:temp];
        
        // 逐个扫描
        //        [self sendMessageToIntranet:temp];
        
        //         [_scoket sendData:temp toHost:@"255.255.255.255" port:5987 withTimeout:5 tag:1];
        
        //         [_scoket receiveOnce:nil];
        
    }
    
}

//-(void)sendScanWithMacAddress:(NSString *)macAddress withVersion:(uint8_t)version{
//    
//    if (_udpSocket) {
//        
//        //扫描协议头
//        ScanHeader *scan = [[ScanHeader alloc] initWithVersion:version andPort:[[XLinkCoreObject sharedCoreObject] getListenPort] andMacAddress:[macAddress dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        FixHeader *fix = [[FixHeader alloc] initWithInfo:SCAN_REQ_FLAG andDataLen:[scan getPacketSize]];
//        
//        NSMutableData *temp = [fix getPacketData];
//        [temp appendData:[scan getPacketData]];
//        
//        //扫描总包bytes
//        [self printByteData:temp];
//        //发送广播包
//        [self sendBoardcastWithData:temp];
//    }
//    
//}

-(void)sendBoardcastWithData:(NSData *)data{
    [_lock lock];
    
    if (_udpSocket) {
        [_udpSocket sendData:data toHost:@"255.255.255.255" port:5987 withTimeout:5 tag:1];
        [_udpSocket receiveOnce:nil];
    }
    
    [_lock unlock];
}

-(void)pingCloud{
    if (_externalSocket) {
        if (_externalSocket.isConnected) {
            ExtFixHeader *temp = [ExtFixHeader pingExtFixHeader];
            NSData *tempData = [temp getPacketData];
            [_externalSocket writeData:tempData withTimeout:-1 tag:0];
            [_externalSocket readDataWithTimeout:-1 tag:0];
        }
    }
}

-(void)closeCloud{
    
    if (_externalSocket.isConnected) {
        [_externalSocket disconnect];
    }
    
}

#pragma mark
#pragma mark -----------------start内网
-(void)sendLocalPipeWithDevice:(DeviceEntity *)device andMessageID:(int)msgID andPayload:(NSData *)payload andFlag:(int)flag{
    
    if (_udpSocket) {
        
        AppPipeDevicePacket *appToDvs = [[AppPipeDevicePacket alloc]initWithSessionID:[device getSessionID] andMessageID:msgID andFlag:flag];
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:PIPE_REQ_FLAG | device.version andDataLen:0];
        
        [[appToDvs getPacketData] appendData:payload];
        [fix setDataLength:(int)[appToDvs getPacketData].length];
        
        NSMutableData *data = [fix getPacketData];
        [data appendData:[appToDvs getPacketData]];
        
        NSLog(@"发送本地透传数据%lu字节", (unsigned long)[data length]);
        //        NSLog(@"LOCAL pipe >>>>");
        //        [self printByteData:data];
        //        NSLog(@"<<<<<<<<<<<<<<<");
        
        [self udpSendDevice:device andData:data];
        
    }

}

-(void)sendLocalSetDeviceAuthorize:(DeviceEntity *)device andMessageID:(int)msgID andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth andFlag:(int)flag{
    
    if (_udpSocket) {
        
        NSData *old = [self getPasswordHash:oldAuth withDevice:device];
        
        NSData *n= [self getPasswordHash:newAuth withDevice:device];
        
        int listenPort = [[XLinkCoreObject sharedCoreObject] getListenPort];
        
        SetPSWDPacket *p = [[SetPSWDPacket alloc]initWithMessageID:msgID andAppListenPort:listenPort andOldAuth:old andNewAuth:n andFlag:flag];
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:SETPSW_REQ_FLAG | device.version andDataLen:[p getPacketSize]];
        
        NSMutableData *senddata = [fix getPacketData];
        
        [senddata appendData:[p getPacketData]];
        
        [self printByteData:senddata];
        
        [self udpSendDevice:device andData:senddata];
        
    }
}

/*
 b0000000 09001100 efc30001 e240
 */

-(void)sendSetAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID withFlag:(unsigned char)flag{
    if (_udpSocket) {
        
        int listenPort = [[XLinkCoreObject sharedCoreObject] getListenPort];
        
        SetACKPacket *packet = [[SetACKPacket alloc] initWithMessageID:msgID andAppListenPort:listenPort andAccessKey:accessKey.unsignedIntValue andFlag:flag];
        
        FixHeader *fixHeader;
        if (device.version >= 3) {
            fixHeader = [[FixHeader alloc] initWithInfo:SETACK_REQ_FLAG | device.version andDataLen:[packet getPacketSize]];
        }else{
            fixHeader = [[FixHeader alloc] initWithInfo:SETACK_REQ_FLAG andDataLen:[packet getPacketSize]];
        }
        
        NSMutableData *sendData = [fixHeader getPacketData];
        
        [sendData appendData:[packet getPacketData]];

        [self udpSendDevice:device andData:sendData];
        
    }
}

-(void)getSubKeyWithAccessKey:(NSNumber *)accessKey withDevice:(DeviceEntity *)device withMessageID:(short)msgID{
    if (_udpSocket) {
        NSData *accessKeyMD5 = [self getPasswordHash:accessKey withDevice:device];
        SubKeyHeader *packet = [[SubKeyHeader alloc] initWithVersion:device.version withMessageID:msgID withAccessKeyMD5:accessKeyMD5 withFlag:0];
        
        NSData *subKeyData = [packet getPacketData];
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:SUBKEY_REQ_FLAG | device.version andDataLen:subKeyData.length];
        
        NSMutableData *sendData = [fix getPacketData];
        [sendData appendData:subKeyData];
        [self udpSendDevice:device andData:sendData];
    }
}

-(void)sendSetLocalDataPoints:(NSArray<DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID{
    SetLocalDataPointPacket *packet = [[SetLocalDataPointPacket alloc] initWithSessionID:[device getSessionID] withMessageID:msgID withFlag:0b00000110];
    
    FixHeader *fixHeader = [[FixHeader alloc] initWithInfo:SET_REQ_FLAG | device.version andDataLen:0];
    NSMutableData *data = [NSMutableData dataWithData:[packet getPacketData]];
    for (DataPointEntity *dataPointEntity in dataPoints) {
        [data appendData:[dataPointEntity getDataPointData]];
    }
    [fixHeader setDataLength:data.length];
    NSMutableData *fixData = [fixHeader getPacketData];
    [fixData appendData:data];
    
    [self udpSendDevice:device andData:fixData];
    
}

-(void)sendLocalHandShake:(DeviceEntity *)device withMessageID:(int16_t)messageID andVersion:(int)version andAuthKey:(NSNumber *)authKey andFlag:(int)flag{
    if (_udpSocket) {
        NSData *authKeyMd5 = [self getPasswordHash:authKey withDevice:device];
        NSLog(@"发送本地握手包，authKey : %@", authKeyMd5);
        ShakeHandWithPSWDPacket *p = [[ShakeHandWithPSWDPacket alloc] initWithVersion:version andMessageID:messageID andAuthKey:authKeyMd5 andListenPort:device.devicePort andFlag:0 andKeepAlive:[device getLocalKeepAlive]];
        
        NSData *handShakeData = [p getPacketData];
        
        FixHeader *fx = [[FixHeader alloc] initWithInfo:HANDSHAKE_REQ_FLAG | device.version andDataLen:handShakeData.length];
        
        NSMutableData *sendData = [fx getPacketData];
        [sendData appendData:handShakeData];
        [self udpSendDevice:device andData:sendData];
    }
}

//cf79ae6a ddba60ad 01834735 9bd144d2
//cf79ae6a ddba60ad 01834735 9bd144d2
//1427562b b29f88a1 161590b7 6398ab72

//-(void)sendLocalSetDevicePropertyWithDevice:(DeviceEntity *)device andMessageID:(int)msgID andFlag:(int)flag{
//    if (_udpSocket) {
//
//        FixHeader *fix = [FixHeader setFixHeader];
//        SetHeaderPacket *set = [[SetHeaderPacket alloc]initWithSessionID:[device getSessionID] andMessageID:msgID andFlag:flag];
//        [fix setDataLength:[SetHeaderPacket getPacketSize]];
//
//        NSMutableData *sendData = [fix getPacketData];
//        [sendData appendData:[set getPacketData]];
//        [self udpSendDevice:device andData:sendData];
//
//    }
//}

-(void)sendLocalProbeWithDevice:(DeviceEntity *)device{
    if (_udpSocket) {
        
        ProbeHeaderPacket *probe = [[ProbeHeaderPacket alloc]initWithSession:[device getSessionID] andFlag:0];
        
        FixHeader *fix = [[FixHeader alloc] initWithInfo:PROBE_REQ_FLAG | device.version andDataLen:[probe getPacketSize]];
        
        NSMutableData *sendData = [fix getPacketData];
        [sendData appendData:[probe getPacketData]];
        [self udpSendDevice:device andData:sendData];
    }
}

#pragma mark
#pragma mark -----------------end内网

#pragma mark
#pragma mark -----------------start外网

-(void)sendSetDeviceAuthorize:(DeviceEntity *)device andMessageID:(int)msgID andOldAuthKey:(NSNumber *)oldAuth andNewAuthKey:(NSNumber *)newAuth andFlag:(int)flag{
    if (_externalSocket) {
        if (_externalSocket.isConnected) {
            
            ExtFixHeader *fix = [ExtFixHeader CloudSetAuthHeader];
            CloudSetAuthPacket *setAuth = [[CloudSetAuthPacket alloc]initWithDeviceID:[device getDeviceID] andMessageID:msgID andFlag:flag andOldAuthKey:[self getPasswordHash:oldAuth withDevice:device] andNewAuth:[self getPasswordHash:newAuth withDevice:device]];
            [fix setDataLength:(int)[setAuth getPacketData].length];
            
            NSMutableData *senData = [fix getPacketData];
            [senData appendData:[setAuth getPacketData]];
            
            [self printByteData:senData];
            
            [_externalSocket writeData:senData withTimeout:-1 tag:msgID];
            
        }else{
            //网络异常状态回调
            if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
                [[XLinkExportObject sharedObject].delegate onNetStateChanged:-101];
            }
        }
    }
}

-(void)sendCloudSubscribeDevice:(DeviceEntity *)device andAuthKey:(NSNumber *)authKey andMessageID:(int)msgID andFlag:(int8_t)flag{
    if (_externalSocket) {
        if (_externalSocket.isConnected) {
            
            ExtFixHeader *extFix = [ExtFixHeader subscriptionExtFixHeaderWithVersion:device.version];
            
            if (device.version < 3) {
                //accessKey验证
                flag|=0b10;
            }else{
                //subkey验证
                flag|=0b100;
            }
            
            SubscribeByAuthPacket *mutate = [[SubscribeByAuthPacket alloc] initWithVersion:device.version withProductID:device.productID withMacAddrwss:device.macAddress withAuthKey:[self getPasswordHash:authKey withDevice:device] withMessageID:msgID withFlag:flag];
            
            [extFix setDataLength:(int)[mutate getPacketData].length];
            
            NSMutableData *sendData = [extFix getPacketData];
            [sendData appendData:[mutate getPacketData]];
            
            // 不用打印出来
            // [self printByteData:sendData];
            
            [_externalSocket writeData:sendData withTimeout:-1 tag:msgID];
            
        }else{
            //网络异常状态回调
            if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
                [[XLinkExportObject sharedObject].delegate onNetStateChanged:-101];
            }
            
        }
    }
}

/*
 93000000 3b
 0020
 31363066 61326165 32356636 32383030
 31363066 61326165 32356636 32383031
 
 accf2359dda2
 401e9c39 fd6f879f 25024b18 317c7794
 100003
 
 90000000 3b
 0020
 31363066 61326165 32356636 32383030
 31363066 61326165 32356636 32383031
 
 accf2359dda2
 401e9c39 fd6f879f 25024b18 317c7794
 000b03
 */

-(void)sendCloudSetPropertyWithDevice:(DeviceEntity *)device andMessageID:(int)messageID andFlag:(int)flag{
    if (_externalSocket) {
        if (_externalSocket.isConnected) {
            
            ExtFixHeader *fix = [ExtFixHeader setExtFixHeader];
            
            SetExtPacket *set = [[SetExtPacket alloc]initWithDeviceId:[device getDeviceID] andMsgID:messageID andFlag:flag];
            
            
            NSMutableData *sendData = [fix getPacketData];
            
            [sendData appendData:[set getPacketData]];
            
            //还要拼接设备的设置的属性
            
            [_externalSocket writeData:sendData withTimeout:-1 tag:0];
            
        }else{
            //网络异常状态回调
            if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
                [[XLinkExportObject sharedObject].delegate onNetStateChanged:-101];
            }
            
        }
    }
    
}


-(void)sendCloudProbeWithDevice:(DeviceEntity *)device andMessageID:(int)messageID andFlag:(int)flag{
    if (_externalSocket) {
        if (_externalSocket.isConnected) {
            
            ExtFixHeader *fix = [ExtFixHeader probeHeader];;
            
            if (device.version >= 3) {
                flag|=0b10;
            }
            
            CloudProbePacket *prob = [[CloudProbePacket alloc]initWithDeviceID:[device getDeviceID] andMessageID:messageID andFlag:flag];
            [fix setDataLength:(int)[prob getPacketData].length];
            
            NSMutableData *sendData = [fix getPacketData];
            [sendData appendData:[prob getPacketData]];
            
            [_externalSocket writeData:sendData withTimeout:-1 tag:0];
            
        }else{
            //网络异常状态回调
            if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
                [[XLinkExportObject sharedObject].delegate onNetStateChanged:-101];
            }
            
        }
    }
}

-(void)sendSetCloudDataPoints:(NSArray<DataPointEntity *> *)dataPoints withDevice:(DeviceEntity *)device withMessageID:(unsigned short)msgID{
    if (_externalSocket) {
        if (_externalSocket.isConnected) {
            
            SetCloudDataPointPacket *packet = [[SetCloudDataPointPacket alloc] initWithSessionID:[device getDeviceID] withMessageID:msgID withFlag:0b00000110];
            ExtFixHeader *fix = [ExtFixHeader dataPointHeader];
            
            NSMutableData *data = [NSMutableData dataWithData:[packet getPacketData]];
            for (DataPointEntity *dataPointEntity in dataPoints) {
                [data appendData:[dataPointEntity getDataPointData]];
            }
            
            [fix setDataLength:data.length];
            NSMutableData *sendData = [fix getPacketData];
            [sendData appendData:data];
            
            [_externalSocket writeData:sendData withTimeout:-1 tag:0];
            
        }
    }
}

-(void)sendDisconnectCM{
    if (_externalSocket) {
        
        //23779
        if (_externalSocket.isConnected) {
            
            ExtFixHeader *fix = [ExtFixHeader disconnectHeader];
            unsigned char reasson = 100;
            
            NSMutableData *temp = [fix getPacketData];
            
            [temp appendBytes:&reasson length:1];
            
            [_externalSocket writeData:temp withTimeout:-1 tag:0];
            
        }
    }
}

#pragma mark
#pragma mark -----------------end外网

#pragma mark
#pragma mark AsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"%s",__func__);
    [_udpSocket receiveOnce:nil];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    
}


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    
    //struct sockaddr_in *addr = address.bytes;
    struct sockaddr_in add;
    [address getBytes:&add length:sizeof(add)];
    _currentIp =[NSString stringWithFormat:@"%s",inet_ntoa(add.sin_addr)];
    NSLog(@"接受%@发送的本地数据包，长度:%lu字节", _currentIp, (unsigned long)[data length]);
    
    //解析器解析
    [[PacketParseEngine shareObject] parseMachine:data forIP:[NSString stringWithString:_currentIp]];
    [_udpSocket receiveOnce:nil];
    
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    if (tag == 1) {
        NSLog(@"扫描包发送失败，设备请检查网络");
    }
    
    if (tag == 2) {
        NSLog(@"握手包发送失败，请检查网络");
    }
    
    DeviceEntity * dev = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:tag];
    
    switch (dev.messageType) {
        case MSG_TYPE_SET_LOCAL_AUTH:
        {
            NSLog(@"本地秘密设置包发送失败,消息编号为%ld",tag);
            [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:(int)tag];
        }
            break;
        case MSG_TYPE_SEND_LOCAL_PIPE:
        {
            NSLog(@"本地pipe包发送失败,消息编号为%ld",tag);
            [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:(int)tag];
        }
            break;
        default:
            break;
    }
    
}


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if (tag == 1) {
        // NSLog(@"%s",__func__);
        NSLog(@"扫描包已经发送，如何没有扫描到设备请检查网络");
        
    }
    
    if (tag == 2) {
        NSLog(@"握手包发送成功，握手成功与否请关注握手回调");
    }
    
    DeviceEntity * dev = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:tag];
    
    switch (dev.messageType) {
        case MSG_TYPE_SET_LOCAL_AUTH:
        {
            NSLog(@"本地pipe包发送成功,消息编号为%ld",tag);
        }
            break;
        case MSG_TYPE_SEND_LOCAL_PIPE:
        {
            NSLog(@"本地pipe包发送成功,消息编号为%ld",tag);
        }
            break;
            
        default:
            break;
    }
    
    [_udpSocket receiveOnce:nil];
    
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
    NSLog(@"--%s",__func__);
    if( error != nil ) {
        NSLog(@"error = %@",[error localizedDescription]);
    }
    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
        [[XLinkExportObject sharedObject].delegate onNetStateChanged:-101];
    }
    
    // 这个时候应该要重置UDP SOCKET
    [self initUdpSocket];
}

-(void)initUdpSocket {
    [_lock lock];
    
    NSLog(@"UDP Init socket");
    
    if(!_userClose) {
        if (_udpSocket != nil) {
            if( ![_udpSocket isClosed] ) {
                [_udpSocket close];
            }
            _udpSocket = nil;
        }
        _udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        
        [_udpSocket enableBroadcast:YES error:nil];
        [_udpSocket bindToPort:0 error:nil];
        
        //得到任意监听的端口
        int _listenPort = [_udpSocket localPort];
        //设置监听的任意端口
        [[XLinkCoreObject sharedCoreObject] setListenPort:_listenPort];
        
        [_udpSocket receiveOnce:nil];
    } else {
        NSLog(@"[NOTIFY] User closed, will not init udp socket.");
    }
    
    [_lock unlock];
}

#pragma mark
#pragma mark GCDAsyncSocket

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    DeviceEntity * dev = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:tag];
    
    switch (dev.messageType) {
        case MSG_TYPE_SUBSCRIBE_CLOUD:
        {
            NSLog(@"云端订阅包已经发送,消息编号为%ld",tag);
        }
            break;
        case MSG_TYPE_SET_CLOUD_AUTH:
        {
            NSLog(@"云端设置密码已经发送,消息编号为%ld",tag);
        }
            break;
        case MSG_TYPE_SEND_CLOUD_PIPE:
        {
            NSLog(@"云端pipe包已经发送，消息编号为%ld",tag);
        }
            break;
        default:
            break;
    }
    
}


-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    
    // [sock startTLS:nil];
    
    
    if (port == Http_port) {
        
        //HTTP连接上了
        _flag.isHttpConnected = YES;
        _flag.isDirectConnected = NO;
        _flag.isTcpConnected = YES;
        
        
        NSString *httpHeader = [[NSString alloc]initWithFormat:@"%@",HttpHeader_Str];
        NSData *httpData = [httpHeader dataUsingEncoding:NSUTF8StringEncoding];
        [_externalSocket writeData:httpData withTimeout:-1 tag:-1];
        [_externalSocket readDataWithTimeout:-1 tag:0];
        
    }else if(port == External_port){
        
        Boolean ssl = false;
        
        if( ssl ) {
            NSMutableDictionary *sslSetting = [[NSMutableDictionary alloc]init];
            
            NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"root" ofType:@"p12"]];
            
            CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
            
            CFStringRef password = CFSTR("xt789456");
            
            const void *keys[] = { kSecImportExportPassphrase };
            
            const void *values[] = { password };
            
            CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            
            CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
            
            OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
            
            CFRelease(options);
            
            CFRelease(password);
            
            if(securityError == errSecSuccess)
                NSLog(@"Success opening p12 certificate.");
            
            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
            
            SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                          kSecImportItemIdentity);
            
            SecIdentityRef  certArray[1] = { myIdent };
            
            CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
            
            [sslSetting setObject:@0 forKey:GCDAsyncSocketSSLProtocolVersionMax];
            
            [sslSetting setObject:@YES forKey:GCDAsyncSocketManuallyEvaluateTrust];
            
            //[sslSetting setObject:NSStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString *)kCFStreamSSLLevel];
            
            [sslSetting setObject:(id)CFBridgingRelease(myCerts) forKey:GCDAsyncSocketSSLCertificates];
            
            [sock startTLS:sslSetting];
        } else {
            _flag.isDirectConnected = YES;
            _flag.isTcpConnected = YES;
            _flag.isHttpConnected = NO;
            _flag.isHttpConnectSuccessed = NO;
            
            NSMutableData *tempFixData = [_fix getPacketData];
            NSMutableData *temp = [_login getPacketData];
            
            [tempFixData appendData:temp];
            //            NSLog(@"发送云端数据>>>>");
            //            [self printByteData:tempFixData];
            //            NSLog(@"<<<<<<<<<<<<<<");
            [_externalSocket writeData:tempFixData withTimeout:-1 tag:-1];
            [sock readDataWithTimeout:-1 tag:0];
            
        }
        
    }
    
}

-(NSMutableDictionary *)getSSLSetting{
    
    NSMutableDictionary *sslSetting = [[NSMutableDictionary alloc]init];
    
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xlinkCer" ofType:@"cer"]];
    
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
    
    CFStringRef password = CFSTR("123456");
    
    const void *keys[] = { kSecImportExportPassphrase };
    
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    
    CFRelease(options);
    
    CFRelease(password);
    
    if(securityError == errSecSuccess)
        NSLog(@"Success opening p12 certificate.");
    
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
    
    SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                  kSecImportItemIdentity);
    
    //        NSData *certData = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xlinkCer" ofType:@"cer"]];
    //
    //        SecCertificateRef myIdent2 = SecCertificateCreateWithData(NULL, (CFDataRef)CFBridgingRetain(certData));
    
    SecIdentityRef  certArray[1] = { myIdent };
    
    CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
    
    [sslSetting setObject:@0 forKey:GCDAsyncSocketSSLProtocolVersionMax];
    
    [sslSetting setObject:@YES forKey:GCDAsyncSocketManuallyEvaluateTrust];
    
    //[sslSetting setObject:NSStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString *)kCFStreamSSLLevel];
    
    [sslSetting setObject:(id)CFBridgingRelease(myCerts) forKey:GCDAsyncSocketSSLCertificates];
    
    
    return sslSetting;
}


-(void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler{
    
    // SecKeyRef sk = SecTrustCopyPublicKey(trust);
    
    // NSLog(@"policies = %d",sizeof(*trust));
    completionHandler(YES);
    
}

-(void)ex:(GCDAsyncSocket *)sock{
    
    NSLog(@"socket 安全通道完成");
    
    _flag.isDirectConnected = YES;
    _flag.isTcpConnected = YES;
    _flag.isHttpConnected = NO;
    _flag.isHttpConnectSuccessed = NO;
    
    NSMutableData *tempFixData = [_fix getPacketData];
    NSMutableData *temp = [_login getPacketData];
    
    [tempFixData appendData:temp];
    [self printByteData:tempFixData];
    
    [_externalSocket writeData:tempFixData withTimeout:-1 tag:-1];
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSLog(@"外网接收的数据长度为%lu",(unsigned long)data.length);
    
    if ([ExtPacketParse shareObject]) {
        
        if (_flag.isHttpConnected) {
            
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",str);
            
            if (_flag.isHttpConnectSuccessed) {
                
                [[ExtPacketParse shareObject] parserMachine:data];
                
            }else{
                
                if ([str respondsToSelector:@selector(containsString:)]) {
                    if ([str containsString:@"200"]) {
                        
                        NSLog(@"http代理服务登录成功");
                        
                        _flag.isHttpConnectSuccessed = YES;
                        _flag.isDirectConnectedSucessed = NO;
                        NSMutableData *tempFixData = [_fix getPacketData];
                        NSMutableData *temp = [_login getPacketData];
                        [tempFixData appendData:temp];
                        [_externalSocket writeData:tempFixData withTimeout:-1 tag:-1];
                        //读取数据
                        [sock readDataWithTimeout:-1 tag:0];
                        
                    }
                    else{
                        NSLog(@"http代理服务登录失败");
                        _flag.isHttpConnectSuccessed = NO;
                        _flag.isHttpConnected = NO;
                        
                        if ([_externalSocket isConnected]) {
                            [_externalSocket disconnect];
                        }
                        
                        [self loginByDirectWithHost:[self getServerAddress] andPort:External_port];
                        
                    }
                    
                }else{
                    BOOL isOK = NO;
                    NSArray * tempArr = [str componentsSeparatedByString:@" "];
                    for (int i = 0; i<tempArr.count; i++) {
                        if ([tempArr[i] isEqualToString:@"200"]) {
                            isOK= YES;
                        }
                    }
                    
                    if (isOK) {
                        
                        NSLog(@"http代理服务连接成功");
                        
                        _flag.isHttpConnectSuccessed = YES;
                        
                        NSMutableData *tempFixData = [_fix getPacketData];
                        
                        NSMutableData *temp = [_login getPacketData];
                        
                        [tempFixData appendData:temp];
                        
                        
                        [_externalSocket writeData:tempFixData withTimeout:-1 tag:-1];
                        //读取数据
                        [sock readDataWithTimeout:-1 tag:0];
                    }
                    else{
                        
                        NSLog(@"http代理服务连接失败");
                        _flag.isHttpConnectSuccessed = NO;
                        _flag.isHttpConnected = NO;
                        if ([_externalSocket isConnected]) {
                            [_externalSocket disconnect];
                        }
                        
                        [self loginByDirectWithHost:[self getServerAddress] andPort:External_port];
                        
                        
                    }
                    
                    
                }
                
            }
            
        }
        
        if (_flag.isDirectConnected) {
            [[ExtPacketParse shareObject] parserMachine:data];
        }
        
        //解析数据
    }
    
    [sock readDataWithTimeout:-1 tag:0];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    if (_flag.isGoHttpProxy) {
        //NSLog(@"通过HTTP 代理服务失败");
        _flag.isGoHttpProxy = NO;
        _flag.isHttpConnected = NO;
        _flag.isHttpConnectSuccessed = NO;
        
        _flag.isDirectConnected = NO;
        _flag.isDirectConnectedSucessed = NO;
        _flag.isGoDirect = NO;
        
        [self loginByDirectWithHost:[self getServerAddress] andPort:External_port];
    }
    
    if (_flag.isDirectConnected) {
        
        _flag.isGoHttpProxy = NO;
        _flag.isHttpConnected = NO;
        _flag.isHttpConnectSuccessed = NO;
        
        _flag.isDirectConnected = NO;
        _flag.isDirectConnectedSucessed = NO;
        _flag.isGoDirect = NO;
    }
    
    [XLinkCoreObject sharedCoreObject].isLoginSuccessed = NO;
    
    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onLogin:)]) {
        [[XLinkExportObject sharedObject].delegate onLogin:CODE_STATE_OFFLINE];
    }
    
    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onNetStateChanged:)]) {
        [[XLinkExportObject sharedObject].delegate onNetStateChanged:CODE_STATE_OFFLINE];
    }
    
    NSLog(@"云端连接断开，将会自动重新登录");
    NSLog(@"%@",[err localizedDescription]);
    
    [[XLinkCoreObject sharedCoreObject] appLogout];
    // 这里，自动再次进入重新连接逻辑
    [[XLinkCoreObject sharedCoreObject] autoRelogin:NO];
}


#pragma mark
#pragma mark 打印bytes
-(void)printByteData:(NSData *)data{
    char temp[data.length];
    [data getBytes:temp range:NSMakeRange(0, data.length)];
    for (int i=0; i<data.length; i++) {
        NSLog(@"%d -> %02x",i,(Byte)temp[i]);
    }
}

@end
