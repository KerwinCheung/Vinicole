//
//  ActivatePacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/6.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "ActivatePacket.h"

#define PACKETSIZE_ACTIVATE 48

@implementation ActivatePacket{
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short _version_offset:8;
        unsigned short _version_len:8;
        
        unsigned short _macAddress_offset:8;
        unsigned short _macAddress_len:8;
        
        unsigned short _WF_hard_offset:8;
        unsigned short _WF_hard_len:8;
        
        unsigned short _WF_soft_offset:8;
        unsigned short _WF_soft_len:8;
        
        unsigned short _MCU_hard_vsion_offset:8;
        unsigned short _MCU_hard_vsion_len:8;
        
        unsigned short _MCU_soft_vsion_offset:8;
        unsigned short _MCU_soft_vsion_len:8;
        
        unsigned short _activate_len_offset:8;
        unsigned short _activate_len_len:8;
        
        unsigned short _activate_str_offset:8;
        unsigned short _activate_str_len:8;
        
        unsigned short _reserved_offset:8;
        unsigned short _reserved_len:8;
    }_packetFlag;
}

-(void)initProtocolLayout{
    _packetFlag._version_offset = 0;
    _packetFlag._version_len = 1;
    
    _packetFlag._macAddress_offset = 1;
    _packetFlag._macAddress_len =6;
    
    _packetFlag._WF_hard_offset = 7;
    _packetFlag._WF_hard_len =1;
    
    _packetFlag._WF_soft_offset =8;
    _packetFlag._WF_soft_len =2;
    
    _packetFlag._MCU_hard_vsion_offset = 10;
    _packetFlag._MCU_hard_vsion_len = 1;
    
    _packetFlag._MCU_soft_vsion_offset = 11;
    _packetFlag._MCU_soft_vsion_len =2;
    
    _packetFlag._activate_len_offset =13;
    _packetFlag._activate_len_len =2;
    
    _packetFlag._activate_str_offset =15;
    _packetFlag._activate_str_len = 32;
    
    _packetFlag._reserved_offset = 47;
    _packetFlag._reserved_len =1;
    
    _packetSize = PACKETSIZE_ACTIVATE;

}

+(ActivatePacket *)packetWithVersion:(__b1)version andMacAddrs:(__b1 [])mac andHardIdentf:(__b1)hardidf andSoftIdtf:(__b2)softIdf andMcuHardVsion:(__b1)hardVersion andMcuSoftVsion:(__b2)sofVersion andActvLen:(__b2)len andAtvtStr:(__b1 [])str andReserved:(__b1)reserved{return nil;}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_ACTIVATE);
}

-(id)initWithVersion:(int)version andMacAddress:(NSData *)address andWFHardIdtif:(int)hardidtf andWFSoftIdtf:(int)softidtf andMCUHardVsion:(int)hardVsion andMCUSoftVsion:(int)softVsion andActivateStrLen:(int)activateLen andActivateStr:(NSData *)activateStr andReserved:(int)resvd{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE_ACTIVATE)];
        if (_packetData.length == PACKETSIZE_ACTIVATE) {
            char vs = version;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&vs length:_packetFlag._version_len];
            
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len) withBytes:address.bytes length:_packetFlag._macAddress_len];
            
            char wfhard = hardidtf;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._WF_hard_offset, _packetFlag._WF_hard_len) withBytes:&wfhard length:_packetFlag._WF_hard_len];
            
            unsigned short wfSoft =softidtf;
            wfSoft = htons(wfSoft);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._WF_soft_offset, _packetFlag._WF_soft_len) withBytes:&wfSoft length:_packetFlag._WF_soft_len];
            
            char mcuHard = hardVsion;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._MCU_hard_vsion_offset, _packetFlag._MCU_hard_vsion_len) withBytes:&mcuHard length:_packetFlag._MCU_hard_vsion_len];
            
            unsigned short mcuSoft = softVsion;
            mcuSoft = htons(mcuSoft);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._MCU_soft_vsion_offset, _packetFlag._MCU_soft_vsion_len) withBytes:&mcuSoft length:_packetFlag._MCU_soft_vsion_len];
            
            unsigned short strLen = activateLen;
            strLen = htons(strLen);
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._activate_len_offset, _packetFlag._activate_len_len) withBytes:&strLen length:_packetFlag._activate_len_len];
            
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._activate_str_offset, _packetFlag._activate_str_len) withBytes:activateStr.bytes length:_packetFlag._activate_str_len];
            
            char tempResvd = resvd;
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&tempResvd length:_packetFlag._reserved_len];
            
            
        }else return nil;
        
    }
    return self;

}

-(id)initWithData:(NSData *)data{
    return nil;
}

//get method

-(int)getVersion{
    if (_packetData.length ==PACKETSIZE_ACTIVATE) {
        
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len)];
        return temp;
        
        
    }else
    return -1;
}

-(NSData *)getMacAddress{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len)];
        return temp;
    }
    
    return nil;
}

-(int)getWFHardIdentifier{
    
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._WF_hard_offset, _packetFlag._WF_hard_len)];
        return temp;
    }
    
    return -1;
}

-(int)getWFSoftIdentifier{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._WF_soft_offset, _packetFlag._WF_soft_len)];
        return ntohs(temp);
    }
    
    return -1;
}

-(int)getMCUHardVsion{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._MCU_hard_vsion_offset, _packetFlag._MCU_hard_vsion_len)];
        return temp;
    }
    
    return -1;
}

-(int)getMCUSoftVsion{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._MCU_soft_vsion_offset, _packetFlag._MCU_soft_vsion_len)];
        return ntohs(temp);
    }
    
    return -1;
}

-(int)getActivateStrLen{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._activate_len_offset, _packetFlag._activate_len_len)];
        return ntohs(temp);
    }
    
    return -1;
}

-(NSData *)getActivateStr{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        NSData *temp = [_packetData subdataWithRange:NSMakeRange(_packetFlag._activate_str_offset, _packetFlag._activate_str_len)];
        return temp;
    }
    
    return nil;
}

-(int)getReserved{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len)];
        return temp;
    }
    
    return -1;
}



//set method
-(void)setVesrion:(int)vsion{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp = vsion;
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._version_offset, _packetFlag._version_len) withBytes:&temp length:_packetFlag._version_len];
        
    }
}

-(void)setMacAddress:(NSData *)dataAddress{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._macAddress_offset, _packetFlag._macAddress_len) withBytes:dataAddress.bytes length:_packetFlag._macAddress_len];
    }
}

-(void)setHard_WF_Identifier:(int)sender{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp = sender;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._WF_hard_offset, _packetFlag._WF_hard_len) withBytes:&temp length:_packetFlag._WF_hard_len];
        
    }
}

-(void)setSoft_WF_Identifier:(int)sender{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        unsigned short temp = sender;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._WF_soft_offset, _packetFlag._WF_soft_len) withBytes:&temp length:_packetFlag._WF_soft_len];
    }
}

-(void)setMCUHardVsion:(int)vsion{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp = vsion;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._MCU_hard_vsion_offset, _packetFlag._MCU_hard_vsion_len) withBytes:&temp length:_packetFlag._MCU_hard_vsion_len];
    }
}

-(void)setMCUFoftVsion:(int)vsion{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        unsigned short temp = vsion;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._MCU_soft_vsion_offset, _packetFlag._MCU_soft_vsion_len) withBytes:&temp length:_packetFlag._MCU_soft_vsion_len];
    }
}

-(void)setActivateStrLen:(int)len{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        unsigned short temp = len;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._activate_len_offset, _packetFlag._activate_len_len) withBytes:&temp length:_packetFlag._activate_len_len];
    }
}

-(void)setActivateStr:(NSData *)data{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        if (_data.length == _packetFlag._activate_str_len) {
            
            [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._activate_str_offset, _packetFlag._activate_str_len) withBytes:data.bytes length:_packetFlag._activate_str_len];
            
        }
    }
}

-(void)setReserved:(int)sender{
    if (_packetData.length == PACKETSIZE_ACTIVATE) {
        char temp = sender;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._reserved_offset, _packetFlag._reserved_len) withBytes:&temp length:_packetFlag._reserved_len];
    }
}

-(NSString *)description{
    if (_packetData.length ==_packetSize) {
        char temp[_packetSize];
        [_packetData getBytes:temp range:NSMakeRange(0, _packetSize)];
        NSMutableString *str = [[NSMutableString alloc]init];
        for (int i =0; i<_packetSize; i++) {
            [str appendFormat:@"#%d=%02x",i,temp[i]];
        }
        return str;
    }
    return nil;
}

@end
