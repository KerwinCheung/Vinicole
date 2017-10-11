//
//  AutoReloginTask.m
//  xlinksdklib
//
//  Created by Leon on 15/7/11.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "AutoReloginTask.h"
#import "SenderEngine.h"
#import "XLReachability.h"
#import "XLinkCoreObject.h"

@implementation AutoReloginTask {
    //    NSTimer *_ticksTimer;
    int _autoReloginCount;
    
    int _currentVersion;
    int _currerntAppID;
    NSString * _currentAuthStr;
    int _keepAliveInterval;
    int _loginedCount;
}

-(id)initWithLoginVersion:(int)version AppID:(int)appID AuthStr:(NSString *)authStr andKeepAliveInterval:(int)keepAlive  {
    self = [super init];
    if( self ) {
        _autoReloginCount = 0;
        _loginedCount = 0;
        _currentVersion = version;
        _currerntAppID = appID;
        _currentAuthStr = [[NSString alloc] initWithString:authStr];
        _keepAliveInterval = keepAlive;
    }
    return self;
}

-(void)autoRelogin {
    
    // 如果网络不可用，就不用自动重连了
    if( ![XLReachability IsEnable3G] && ![XLReachability IsEnableWIFI] ) {
        NSLog(@"网络不可用，进入等待模式...");
        return;
    }
    
    //    if( _ticksTimer != nil ) {
    // 说明已经有等待任务了，这次就放着
    //        NSLog(@"Auto relogin waiting...");
    //    } else {
    
    _autoReloginCount ++;
    NSTimeInterval ti = _autoReloginCount < 5 ? pow(2, _autoReloginCount - 1) : 16;
    [self performSelector:@selector(startTicksTimerWithTimeInterval:) onThread:[[XLinkCoreObject sharedCoreObject] getDelayThread] withObject:@(ti) waitUntilDone:YES];
    //    }
}

-(void)startTicksTimerWithTimeInterval:(NSNumber *)ti{
    NSLog(@"Auto relogin within %d sec.", (int)ti);
    [self performSelector:@selector(doLogin) withObject:nil afterDelay:ti.doubleValue];
}

-(void)autoReloginRightNow {
    // 直接登录
    [self doLogin];
}

//-(void)doTimer:(id)sender {
//    [self doLogin];
//}

-(void)doLogin {
    //    if( _ticksTimer != nil ) {
    //        [_ticksTimer invalidate];
    //        _ticksTimer = nil;
    //    }
    
    if( _currerntAppID != 0 && _currentAuthStr != nil && _currentAuthStr.length > 0 ) {
        NSLog(@"Start auto relogin ...");
        [[SenderEngine sharedEngine] loginWithVersion:_currentVersion andAppID:_currerntAppID andAuthLength:16 andAuthStr:_currentAuthStr andKeepLive:_keepAliveInterval];
    } else {
        NSLog(@"Auto relogin can not be access for invalid param.");
    }
}

-(void)onLoginResponsedWithCode:(int)code {
    //    if( _ticksTimer != nil ) {
    //        [_ticksTimer invalidate];
    //        _ticksTimer = nil;
    //    }
    _autoReloginCount = 0;
    if( code == 0 ) {
        _loginedCount ++;
    }
}

@end
