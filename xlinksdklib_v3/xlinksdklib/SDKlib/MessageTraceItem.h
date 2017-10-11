//
//  MessageTraceItem.h
//  xlinksdklib
//
//  Created by Leon on 15/8/13.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity.h"

@interface MessageTraceItem : NSObject

@property (readonly, nonatomic) long MessageElapse;
@property (readonly, nonatomic) id object;

- (id)initWithObject:(id)object andMessageID:(int)msgID;

- (void)onMessageResponse;
- (void)onMessageTimeout;

@end
