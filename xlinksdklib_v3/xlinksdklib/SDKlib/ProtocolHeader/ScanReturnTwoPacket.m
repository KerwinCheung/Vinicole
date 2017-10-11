//
//  ScanReturnTwoPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ScanReturnTwoPacket.h"
#define PACKETSIZE 49
@implementation ScanReturnTwoPacket{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned int _version_offset:8;
        unsigned int _version_len:8;
        
        unsigned int _macAddress_offset:8;
        unsigned int _macAddress_len:8;
        
        unsigned int _productId_len_offset:8;
        unsigned int _productId_len_len:8;
        
        unsigned int _productId_offset:8;
        unsigned int _productId_len:8;
        
        unsigned int _mcuHardVersion_offset:8;
        unsigned int _mcuHardVersion_len:8;
        
        unsigned int _mcuSoftVersion_offset:8;
        unsigned int _mcuSoftVersion_len:8;
        
        unsigned int _deviceUdpPort_offset:8;
        unsigned int _deviceUdpPort_len:8;
        
        unsigned int _deviceType_offset:8;
        unsigned int _deviceType_len:8;
        
        unsigned int _flag_offset:8;
        unsigned int _flag_len:8;
        
    }_packetFlag;
}

/*
 *@discussion
 *  协议字节布局
 */
-(void)initProtocolLayout{
    _packetFlag._version_offset = 0;
    _packetFlag._version_len = 1;
    
    _packetFlag._macAddress_offset = 1;
    _packetFlag._macAddress_len =6;
    
    _packetFlag._productId_len_offset=7;
    _packetFlag._productId_len_len =2;
    
    _packetFlag._productId_offset = 9;
    _packetFlag._productId_len= 32;
    
    _packetFlag._mcuHardVersion_offset = 41;
    _packetFlag._mcuHardVersion_len = 1;
    
    _packetFlag._mcuSoftVersion_offset =42;
    _packetFlag._mcuSoftVersion_len= 2;
    
    
    _packetFlag._deviceUdpPort_offset = 44;
    _packetFlag._deviceUdpPort_len = 2;
    
    _packetFlag._deviceType_offset = 46;
    _packetFlag._deviceType_len = 2;
    
    _packetFlag._flag_offset = 48;
    _packetFlag._flag_len = 1;
    
}

/*
 *@discussion
 *  初始化成员变量
 */
-(id)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData  =[[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
    }
    return self;
}
/*
 *@discussion
 *  通过网络字节bytes初始化包
 */
-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        
        if (data.length != PACKETSIZE) {
            return nil;
        }
        
        [self initProtocolLayout];
        _packetData  = [NSMutableData dataWithData:data];
    }
    return self;
    
}
/*
 *@discussion
 *  设置包bytes
 */
-(void)setPacketData:(NSData *)data{
    if (data.length == PACKETSIZE) {
        
        [_packetData replaceBytesInRange:NSMakeRange(0, PACKETSIZE) withBytes:data.bytes length:PACKETSIZE];
        
    }
}
/*
 *@discussion
 *  获得包的Bytes
 */
-(NSMutableData *)getPacketData{
    return _packetData;
}
/*
 *@discussion
 *  得到包的大小
 */
+(int)getPacketSize{
    return PACKETSIZE;
}
/*
 *@discussion
 *  得到协议版本
 */
-(int)getVersion{
    if (_packetData.length == PACKETSIZE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len)];
        return temp;
    }
    return -1;
}
/*
 *@discussion
 *  得到Mac地址bytes
 */
-(NSData *)getMacAddress{
    if (_packetData.length == PACKETSIZE) {
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len)];
        return temp;
    }
    return nil;
}

-(NSString *)getMacAddressString {
    if (_packetData.length == PACKETSIZE) {
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len)];
        return [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", (Byte)((const char *)temp.bytes)[0], (Byte)((const char *)temp.bytes)[1], (Byte)((const char *)temp.bytes)[2], (Byte)((const char *)temp.bytes)[3], (Byte)((const char *)temp.bytes)[4], (Byte)((const char *)temp.bytes)[5]];
    }
    return nil;

}

/*
 *@discussion
 *  得到产品ID的长度
 */
-(int)getPruductIDLength{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._productId_len_offset, _packetFlag._productId_len_len)];
        return ntohs(temp);
    }
    return -1;
}
/*
 *@discussion
 *  得到产品ID
 */
-(NSData *)getPruductID{
    if (_packetData.length == PACKETSIZE) {
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._productId_offset, _packetFlag._productId_len)];
        return temp;
    }
    return nil;
}
/*
 *@discussion
 *  得到MCU 硬件版本
 */
-(int)getMCUHardVersion{
    if (_packetData.length == PACKETSIZE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._mcuHardVersion_offset, _packetFlag._mcuHardVersion_len)];
        return temp;
    }
    return -1;
}
/*
 *@discussion
 *  得到MCU软件版本
 */
-(int)getMCUSoftVersion{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._mcuSoftVersion_offset, _packetFlag._mcuSoftVersion_len)];
        return ntohs(temp);
    }
    return -1;
}


/*
 *@discussion
 *  得到设备UDP的监听端口号
 */
-(int)getDeviceUdpPort{
    if (_packetData.length == PACKETSIZE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._deviceUdpPort_offset, _packetFlag._deviceUdpPort_len)];
        int pt = ntohs(temp);
        if( pt == 0 ) {
            pt = 5987;
        }
        return pt;
    }
    return -1;
}

/*
 *@discussion
 *  得到协议的DeviceType标示
 */
-(unsigned short)getDeviceType{
    unsigned short deviceType = -1;
    if (_packetData.length == PACKETSIZE) {
        [_packetData getBytes:&deviceType range:NSMakeRange(_packetFlag._deviceType_offset, _packetFlag._deviceType_len)];
    }
    return ntohs(deviceType);
}

/*
 *@discussion
 *  得到协议的datapoint标示
 */
-(unsigned char)getFlag{
    if (_packetData.length == PACKETSIZE) {
        unsigned char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len)];
        return temp ;
    }
    return -1;
}

/*
 *@discussion
 *  得到协议的描述文件
 */
-(NSString *)description{
    if (_packetData.length == PACKETSIZE) {
        char temp[PACKETSIZE];
        [_packetData getBytes:temp range:NSMakeRange(0, PACKETSIZE)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for ( int i = 0; i < PACKETSIZE; i++) {
            [str appendFormat:@"#%d = %02x\n",i,temp[i]];
        }
        return str;
    }
    return nil;
}

@end
