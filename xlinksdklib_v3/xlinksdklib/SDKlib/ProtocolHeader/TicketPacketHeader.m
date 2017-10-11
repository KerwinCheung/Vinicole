//
//  TicketPacketHeader.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/27.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "TicketPacketHeader.h"

#define PACKETSIZE 9

@implementation TicketPacketHeader{
    NSMutableData *_packetData;
    
    struct {
        unsigned short _session_id_offset:8;
        unsigned short _session_id_len:8;
        
        unsigned short _appID_offset:8;
        unsigned short _appID_len:8;
        
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _flag_offset:8;
        unsigned short _flag_len:8;
        
    }_packetFlag;
    
}

-(void)initProtocolLayout{
    _packetFlag._session_id_offset =0;
    _packetFlag._session_id_len = 2;
    
    _packetFlag._appID_offset =2;
    _packetFlag._appID_len = 4;
    
    _packetFlag._messageID_offset =6;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._flag_offset = 8;
    _packetFlag._flag_len =1;
}

-(id)initWithSessionID:(int)asessionID andAppID:(int)appID andMessageID:(int)msgID andFlag:(int)flag{

    self = [super init];
    if (self) {
        [self initProtocolLayout];
        
        _packetData = [[NSMutableData alloc]init];
        [_packetData resetBytesInRange:NSMakeRange(0, PACKETSIZE)];
        
        unsigned short sionID = asessionID;
        sionID = htons(sionID);
        
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._session_id_offset, _packetFlag._session_id_len) withBytes:&sionID];
        
        int apID = htonl(appID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._appID_offset, _packetFlag._appID_len) withBytes:&apID];
        
        unsigned short msg = msgID;
        msg  = htons(msg);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len) withBytes:&msg];
        
        unsigned char fg = flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&fg];
        
        
//        [self printByteData:_packetData];
        
    }
    
    return self;
}

-(void)printByteData:(NSData *)data{
    
    unsigned char temp[data.length];
    [data getBytes:temp range:NSMakeRange(0, data.length)];
    for (int i=0; i<data.length; i++) {
        NSLog(@"%d ->%02x",i,temp[i]);
    }
    
}

+(int)getPacketSize{
    return PACKETSIZE;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}

@end
