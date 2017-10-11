//
//  ShakeHandByAuthReturnPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ShakeHandByAuthReturnPacket.h"

#define PACKETSIZE 17

@implementation ShakeHandByAuthReturnPacket{
    
    NSMutableData *_packetData;
    
    struct {
        unsigned short code_offset:8;
        unsigned short code_len:8;
        
        unsigned short version_offset:8;
        unsigned short version_len:8;
        
        unsigned short macAddress_offset:8;
        unsigned short macAddress_len:8;
        
        unsigned short deviceID_offset:8;
        unsigned short deviceID_len:8;
        
        unsigned short mcuSoft_offset:8;
        unsigned short mcuSoft_len:8;
        
        unsigned short sessionID_offset:8;
        unsigned short sessionID_len:8;
        
        unsigned short crypType_offset:8;
        unsigned short crypType_len:8;
        
        
    }_packetFlag;
}

-(void)initProtocolLayout{
    _packetFlag.code_offset = 0;
    _packetFlag.code_len = 1;
    
    _packetFlag.version_offset =1;
    _packetFlag.version_len =1;
    
    _packetFlag.macAddress_offset = 2;
    _packetFlag.macAddress_len = 6;
    
    _packetFlag.deviceID_offset = 8;
    _packetFlag.deviceID_len = 4;
    
    _packetFlag.mcuSoft_offset =12;
    _packetFlag.mcuSoft_len = 2;
    
    _packetFlag.sessionID_offset =14;
    _packetFlag.sessionID_len =2;
    
    _packetFlag.crypType_offset =16;
    _packetFlag.crypType_len =1;
    
}

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]initWithData:data];
    }
    return self;
}

+(int)getPacketSize{
    return PACKETSIZE;
}

-(NSMutableData *)getPacketData{
    
    return _packetData;
}

-(int)getCode{
    if (_packetData.length>0) {
        unsigned char code;
        [_packetData getBytes:&code range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
        return code;
    }return -1;
}

-(int)getVersion{
    int code = [self getCode];
    switch (code) {
        case 0:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
            unsigned char version;
            [_packetData getBytes:&version range:NSMakeRange(_packetFlag.version_offset, _packetFlag.version_len)];
            return version;
        }
            break;
        case 2:
        {
            if (_packetData.length != 8) {
                return -1;
            }
            unsigned char version;
            [_packetData getBytes:&version range:NSMakeRange(_packetFlag.version_offset, _packetFlag.version_len)];
            return version;
        }
            break;
        default:
            break;
    }return -1;
}

-(NSData *)getMacAddress{
    int code = [self getCode];
    switch (code) {
        case 0:
        {
            if (_packetData.length != PACKETSIZE) {
                return nil;
            }
            
            NSData *mac = [_packetData subdataWithRange:NSMakeRange(_packetFlag.macAddress_offset, _packetFlag.macAddress_len)];
            return mac;
            
        }
            break;
        case 1:
        case 2:
        {
            if (_packetData.length != 8) {
                return nil;
            }
            
            NSData *mac = [_packetData subdataWithRange:NSMakeRange(_packetFlag.macAddress_offset, _packetFlag.macAddress_len)];
            return mac;
            
        }
            break;
        default:
            break;
    }return nil;
}

-(int)getDeviceID{
    int code = [self getCode];
    switch (code) {
        case 0:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
            
            unsigned int temp;
            [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len)];
            return ntohl(temp);
            
        }
            break;
        case 2:
        {
            if (_packetData.length != 8) {
                return -1;
            }
        }
            break;
        default:
            break;
    }return -1;

}

-(int)getSessionID{
    int code = [self getCode];
    switch (code) {
        case 0:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
            
            unsigned short temp;
            [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.sessionID_offset, _packetFlag.sessionID_len)];
            return ntohs(temp);
            
        }
            break;
        case 2:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
        }
            break;
        default:
            break;
    }return -1;
}

-(int)getMcuSoftVersion{
    int code = [self getCode];
    switch (code) {
        case 0:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
            
            unsigned short temp;
            [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.mcuSoft_offset, _packetFlag.mcuSoft_len)];
            return ntohs(temp);
            
        }
            break;
        case 2:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
        }
            break;
        default:
            break;
    }return -1;
}

-(int)getCrypTpye{
    int code = [self getCode];
    switch (code) {
        case 0:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
            
            unsigned char temp;
            [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.crypType_offset, _packetFlag.crypType_len)];
            return temp;
            
        }
            break;
        case 2:
        {
            if (_packetData.length != PACKETSIZE) {
                return -1;
            }
        }
            break;
        default:
            break;
    }return -1;
}


-(int)getMessageID{
    return -1;
}

@end
