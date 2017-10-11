//
//  AppPipeDevicePacket.m
//  XLinkSdk
//
//  Created by xtmac02 on 15/2/28.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "AppPipeDevicePacket.h"

#define PACKETSIZE 5

@implementation AppPipeDevicePacket{
    NSMutableData *_packetData;
    
    struct {
        unsigned short _sessionID_offset:8;
        unsigned short _sessionID_len:8;
        
        unsigned short _messageID_offset:8;
        unsigned short _messageID_len:8;
        
        unsigned short _flag_offset:8;
        unsigned short _flag_len:8;
        
    }_packetFlag;

}

-(void)initProtocolLayout{
    
    _packetFlag._sessionID_offset = 0;
    _packetFlag._sessionID_len = 2;
    
    _packetFlag._messageID_offset =2;
    _packetFlag._messageID_len = 2;
    
    _packetFlag._flag_offset = 4;
    _packetFlag._flag_len = 1;
    
}

-(id)initWithSessionID:(int)aSessionId andMessageID:(int)aMessageId andFlag:(int)flag{
    self = [super init];
    if (self) {
        [self initProtocolLayout];
        
        _packetData = [NSMutableData dataWithLength:PACKETSIZE];
        
        unsigned short sessionID = aSessionId;
        sessionID = htons(sessionID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._sessionID_offset, _packetFlag._sessionID_len) withBytes:&sessionID];
        
        
        unsigned short msgID = aMessageId;
        msgID = htons(msgID);
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._messageID_offset, _packetFlag._messageID_len) withBytes:&msgID];
        
        unsigned char fg = flag;
        [_packetData replaceBytesInRange:NSMakeRange(_packetFlag._flag_offset, _packetFlag._flag_len) withBytes:&fg];
        
    }
    
    return self;
}

-(int)getPacketSize{
    return PACKETSIZE;
}

-(NSMutableData *)getPacketData{
    return _packetData;
}
@end
