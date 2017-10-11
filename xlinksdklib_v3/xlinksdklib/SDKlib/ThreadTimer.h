//
//  ThreadTimer.h
//  NSRunloop
//
//  Created by xtmac on 23/10/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadTimer : NSObject


+(ThreadTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo;
-(id)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo;

-(void)fire;
-(void)stop;

-(void)invalidate;

@end
