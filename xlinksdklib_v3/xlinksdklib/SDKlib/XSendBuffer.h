//
//  XSendBuffer.h
//  xlinksdklib
//
//  Created by Leon on 15/9/24.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceEntity;

enum XSendBufferType {
    typeLocalPipe = 0,
    typeRemotePipe = 1,
};

@interface XSendBuffer : NSObject

@property(assign, nonatomic) DeviceEntity * deviceEntity;
@property(assign, nonatomic) enum XSendBufferType type;
@property(assign, nonatomic) int msgId;
@property(strong, nonatomic) NSData * payload;

-(id)initWithType:(enum XSendBufferType)type andMsgId:(int)msgId andPayload:(NSData *)payload toDevice:(DeviceEntity *)deviceEntity;

@end
