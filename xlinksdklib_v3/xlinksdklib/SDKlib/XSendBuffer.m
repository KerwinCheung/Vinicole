//
//  XSendBuffer.m
//  xlinksdklib
//
//  Created by Leon on 15/9/24.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import "XSendBuffer.h"

@implementation XSendBuffer {
    int _msgId;
    NSData * _payload;
    enum XSendBufferType _type;
}

- (id)initWithType:(enum XSendBufferType)type andMsgId:(int)msgId andPayload:(NSData *)payload toDevice:(DeviceEntity *)deviceEntity {
    self = [super init];
    if( self ) {
        _msgId = msgId;
        _type = type;
        _payload = payload;
        _deviceEntity = deviceEntity;
    }
    return self;
}

@end
