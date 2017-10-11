//
//  XSendBufferQueue.m
//  xlinksdklib
//
//  Created by Leon on 15/9/24.
//  Copyright © 2015年 xtmac02. All rights reserved.
//

#import "XSendBufferQueue.h"
#import "XSendBuffer.h"
#import "SDKProperty.h"
#import "SenderEngine.h"
#import "DeviceEntity.h"
#import "XLinkCoreObject.h"

@implementation XSendBufferQueue {
    NSMutableArray * _sendBufferQueue;
    BOOL _run;
    NSThread * _sendBufferThread;
    
    // 线程锁
    NSLock * _lock;
}

- (id)init {
    self = [super init];
    if( self ) {
        _lock = [[NSLock alloc] init];
        _sendBufferQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)startBufferQueue {
    
    _run = YES;
    _sendBufferThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(threadRun:)
                                                     object:nil];
    [_sendBufferThread start];
}

- (void)stopBufferQueue {
    _run = NO;
}

- (void)threadRun:(id)param {
    while( _run ) {
        [self processBuffers];
        
        NSTimeInterval ti = [SDKProperty sendDataBufferInterval];
        if( ti <= 0 ) {
            ti = 0.1;
        }
        
        [NSThread sleepForTimeInterval:ti];
    }
    
    _sendBufferThread = nil;
}

- (int)addBuffer:(XSendBuffer *)buffer {
    [_lock lock];
    
    [_sendBufferQueue addObject:buffer];
    
    [_lock unlock];
    return 0;
}

- (int)addLocalPipeBufferWithDevice:(DeviceEntity *)deviceEntity msgId:(int)msgId andPayload:(NSData *)payload {
    XSendBuffer * buf = [[XSendBuffer alloc] initWithType:typeLocalPipe andMsgId:msgId andPayload:payload toDevice:deviceEntity];
    return [self addBuffer:buf];
}

- (void)processBuffers {
    [_lock lock];
    
    if( [_sendBufferQueue count] > 0 ) {
        XSendBuffer * buf = [_sendBufferQueue firstObject];
        [_sendBufferQueue removeObjectAtIndex:0];
        [self processBuffer:buf];
    }
    
    [_lock unlock];
}

- (void)processBuffer:(XSendBuffer *)buf {
    switch (buf.type) {
        case typeLocalPipe:
            [[XLinkCoreObject sharedCoreObject] sendLocalPipeWithDevice:buf.deviceEntity andPayload:buf.payload andFlag:0 withMsgID:buf.msgId];
            break;
            
        default:
            break;
    }
}

@end
