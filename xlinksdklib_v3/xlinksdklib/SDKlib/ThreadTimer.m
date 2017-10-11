//
//  ThreadTimer.m
//  NSRunloop
//
//  Created by xtmac on 23/10/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "ThreadTimer.h"

#import <UIKit/UIKit.h>

@implementation ThreadTimer{
    NSThread    *_thread;
    NSTimer *_timer;
    NSTimeInterval  _ti;
    id      _target;
    SEL     _selector;
    id      _userInfo;
}

+(ThreadTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo{
    ThreadTimer *threadTimer = [[ThreadTimer alloc] initWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo];
    [threadTimer startThread];
    return threadTimer;
}

-(id)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo{
    if (self = [super init]) {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(startTime) object:nil];
        _ti = ti;
        _target = aTarget;
        _selector = aSelector;
        _userInfo = userInfo;
    }
    return self;
}

-(void)startThread{
    [_thread start];
}

-(void)startTime{
    _timer = [NSTimer scheduledTimerWithTimeInterval:_ti target:_target selector:_selector userInfo:_userInfo repeats:YES];
    while ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && _timer) {
        
    }
    //    _thread = nil;
}

-(void)fire{
    if (_timer) {
        [_timer setFireDate:[NSDate date]];
    }else{
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(startTime) object:nil];
        [_thread start];
    }
}

-(void)stop{
    [_timer setFireDate:[NSDate distantFuture]];
}

-(void)invalidate{
    if (_timer) {
        [_timer invalidate];
        //        _timer = nil;
        [_thread release];
        [self performSelector:@selector(setTimerNil) onThread:_thread withObject:nil waitUntilDone:NO];
    }
}

-(void)setTimerNil{
    _timer = nil;
}

-(void)dealloc{
    [super dealloc];
    NSLog(@"%s", __func__);
}

@end
