//
//  AutoReloginTask.h
//  xlinksdklib
//
//  Created by Leon on 15/7/11.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoReloginTask : NSObject

-(id)initWithLoginVersion:(int)version AppID:(int)appID AuthStr:(NSString *)authStr andKeepAliveInterval:(int)keepAlive;
-(void)autoRelogin;
-(void)autoReloginRightNow;
-(void)onLoginResponsedWithCode:(int)code;

@end
