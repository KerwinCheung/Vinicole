//
//  NotifyRetPacket.m
//  xlinksdklib
//
//  Created by xtmac on 6/1/16.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "NotifyRetPacket.h"

#define PACKETSIZE 10

@implementation NotifyRetPacket{
    
    NSMutableData *_packetData;
    int _packetSize;
    
    struct {
        unsigned short type_offset:8;
        unsigned short type_len:8;
        
        unsigned short flag_offset:8;
        unsigned short flag_len:8;
        
        unsigned short fromid_offset:8;
        unsigned short fromid_len:8;
        
        unsigned short messageID_offset:8;
        unsigned short messageID_len:8;
        
        unsigned short messagetype_offset:8;
        unsigned short messagetype_len:8;
        
    }_packetFlag;
    
}


-(void)initProtocolLayout{
    
    _packetFlag.type_offset = 0;
    _packetFlag.type_len = 1;
    
    _packetFlag.flag_offset = 1;
    _packetFlag.flag_len = 1;
    
    _packetFlag.fromid_offset = 2;
    _packetFlag.fromid_len = 4;
    
    _packetFlag.messageID_offset = 6;
    _packetFlag.messageID_len = 2;
    
    _packetFlag.messagetype_offset = 8;
    _packetFlag.messagetype_len = 2;
    
}

-(id)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        _packetData = [NSMutableData dataWithData:data];
        
    }
    return self;
}

+(NSInteger)getPacketSize{
    return PACKETSIZE;
}

-(unsigned char)getFlag{
    unsigned char temp;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.flag_offset, _packetFlag.flag_len)];
    return temp;
}

-(int)getMsgID{
    int temp;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.messageID_offset, _packetFlag.messageID_len)];
    return ntohs(temp);
}

-(int)getFromID{
    int temp;
    [_packetData getBytes:&temp range:NSMakeRange(_packetFlag.fromid_offset, _packetFlag.fromid_len)];
    return ntohl(temp);
}

@end
