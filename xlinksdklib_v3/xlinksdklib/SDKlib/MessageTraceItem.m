//
//  MessageTraceItem.m
//  xlinksdklib
//
//  Created by Leon on 15/8/13.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "MessageTraceItem.h"
#include <sys/time.h>

long GetTickCount()
{
    struct timeval tv;
    
    if(gettimeofday(&tv, 0))
        return 0;
    
    return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
}

@implementation MessageTraceItem {
    int _msgID;
    long _messageRequestTime;
    long _messageResponseTime;
}



- (id)initWithObject:(id)object andMessageID:(int)msgID {
    self = [super init];
    
    if( self ) {
        _object = object;
        _msgID = msgID;
        _messageRequestTime = GetTickCount();
        return self;
    }
    
    return nil;
}

- (void)onMessageResponse {
    _messageResponseTime = GetTickCount();
    
    NSLog(@"Message %d response in %ld ms", _msgID, [self MessageElapse]);
}

- (void)onMessageTimeout {
    _messageResponseTime = _messageRequestTime + 999999;
}

- (long)MessageElapse {
    return (_messageResponseTime - _messageRequestTime);
}

@end
