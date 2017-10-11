//
//  XSendBufferQueue.h
//  xlinksdklib
//
//  Created by Leon on 15/9/24.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>


@class XSendBuffer;
@class DeviceEntity;

@interface XSendBufferQueue : NSObject

- (void)startBufferQueue;
- (void)stopBufferQueue;

- (int)addBuffer:(XSendBuffer *)buffer;
- (int)addLocalPipeBufferWithDevice:(DeviceEntity *)deviceEntity msgId:(int)msgId andPayload:(NSData *)payload;

@end
