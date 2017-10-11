//
//  SubscriptionReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SubscriptionReturnPacket.h"

#define PACKET_SUBSPTION_SIZE_RETURN 3

@implementation SubscriptionReturnPacket{
    NSMutableData *_packetData;
    int _packetSize;
    struct {
        unsigned short appID_offset:8;
        unsigned short appID_len:4;
        
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short code_offset:8;
        unsigned short code_len:8;
    
    }_packetFlag;
}
-(void)initProtocolLayout{
    _packetFlag.appID_offset =0;
    _packetFlag.appID_len = 4;
    
    _packetFlag.messageID_offset = 4;
    _packetFlag.messageID_len =2;
    
    _packetFlag.code_offset =6;
    _packetFlag.code_len =1;
    
    _packetSize = 7;
}
-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKET_SUBSPTION_SIZE_RETURN);
}

-(id)initWithData:(NSData *)data{
    self =[super init];
    if (self) {
        
        [self initProtocolLayout];
        
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        if (data.length!=_packetSize) {
            return nil;
        }
        
        _packetData = [[NSMutableData alloc]initWithData:data];
    }
    return self;
}

-(int)getAppid{
    if (_packetData.length == _packetSize) {
        unsigned int temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.appID_offset, _packetFlag.appID_len)];
        return ntohl(temp);
    }
    return -1;

}


-(int)getMessageID{
    if (_packetData.length == _packetSize) {
        unsigned short temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len)];
        return ntohs(temp);
    }
    return -1;
}
-(int)getCode{
    if (_packetData.length == _packetSize) {
        char temp;
        [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.code_offset, _packetFlag.code_len)];
        return temp;
    }
    return -1;
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
