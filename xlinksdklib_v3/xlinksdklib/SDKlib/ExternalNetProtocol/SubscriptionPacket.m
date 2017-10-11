//
//  SubscriptionPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/8.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SubscriptionPacket.h"


#define PACKETSIZE_SUBSPTION 41

@implementation SubscriptionPacket{
    NSMutableData *_packetData;
    int _packetSize;
    struct {
        unsigned short deviceID_offset:8;
        unsigned short deviceID_len:8;
        
        unsigned short ticket_offset:8;
        unsigned short ticket_len:8;
        
        unsigned short ticketStr_offset:8;
        unsigned short ticketStr_len:8;
        
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short flag_offset:8;
        unsigned short flag_len:8;
        
        
    }_packetFlag;
}


-(void)initProtocolLayout{
    _packetFlag.deviceID_offset = 0;
    _packetFlag.deviceID_len = 4;
    
    _packetFlag.ticket_offset =4;
    _packetFlag.ticket_len =2;
    
    _packetFlag.ticketStr_offset = 6;
    _packetFlag.ticketStr_len = 32;
    
    _packetFlag.messageID_offset =38;
    _packetFlag.messageID_len =2;
    
    _packetFlag.flag_offset = 40;
    _packetFlag.flag_len =1;
    
}


-(id)initWithDeviceID:(int)deviceID andTicketStrLen:(int)aLen andTicketStr:(NSData *)aTicketStr andMessageID:(int)aMsgID andFlag:(int)aFlag{
    if (self =[super init]) {
        
        [self initProtocolLayout];
        
        _packetSize = PACKETSIZE_SUBSPTION;
        
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        
        
        unsigned int dvceId = deviceID;
        dvceId = htonl(dvceId);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&dvceId];
        
        unsigned short tickeLen = aLen;
        tickeLen = htons(tickeLen);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.ticket_offset, _packetFlag.ticket_len) withBytes:&tickeLen];
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.ticketStr_offset, _packetFlag.ticketStr_len) withBytes:aTicketStr.bytes];
        
        unsigned short msgId = aMsgID;
        msgId = htons(msgId);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&msgId];
        
        
        unsigned char fg = aFlag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&fg];
            
        
    }
    return self;

}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetSize = PACKETSIZE_SUBSPTION;
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, _packetSize)];
        if (_packetData.length != _packetSize) {
            return nil;
        }
    }
    return self;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSInteger)getPacketSize{
    return _packetSize;
}

+(NSInteger)getPacketSize{
    return (PACKETSIZE_SUBSPTION);
}

-(void)setDeviceID:(int)deiceID{
    if (_packetData.length ==_packetSize) {
        int temp = htonl(deiceID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.deviceID_offset, _packetFlag.deviceID_len) withBytes:&temp length:_packetFlag.deviceID_len];
    }
}

-(void)setMessageID:(int)msgID{
    if (_packetData.length ==_packetSize) {
        unsigned short temp = msgID;
        temp = htons(temp);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len) withBytes:&temp length:_packetFlag.messageID_len];
    }
}
-(void)setFlag:(int)flag{
    if (_packetData.length ==_packetSize) {
        char temp = flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len) withBytes:&temp length:_packetFlag.flag_len];
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
