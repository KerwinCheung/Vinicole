//
//  TicketReturnPacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/27.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "TicketReturnPacket.h"

#define PACKETSIZE 3

@implementation TicketReturnPacket{
    NSMutableData *_packetData;
    
    struct {
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _code_offset:8;
        unsigned short _code_len:8;
        
    }_packetFlag;
}

+(int)getPacketSize{
    return PACKETSIZE;
}

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        if (data.length != PACKETSIZE) {
            return nil;
        }
        _packetData = [[NSMutableData alloc]initWithData:data];
    }
    return self;
}


-(int)getCode{
    
    if (_packetData.length != PACKETSIZE) {
        return -1;
    }
    
    unsigned char code;
    
    [_packetData getBytes:&code range:NSMakeRange(2, 1)];
    return code;
}

-(int)getMessageID{
    
    if (_packetData.length != PACKETSIZE) {
        return -1;
    }
    
    unsigned short msgID;
    [_packetData getBytes:&msgID range:NSMakeRange(0, 2)];
    msgID = ntohs(msgID);
    return msgID;
    
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

-(NSString *)getTicket{
    return nil;
}

-(BOOL)isHasTicket{
    if ([self getCode]) {
        return NO;
    }else{
        return YES;
    }
}

@end
