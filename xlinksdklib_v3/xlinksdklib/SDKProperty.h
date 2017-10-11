//
//  SDKProperty.h
//  xlinksdklib
//
//  Created by Leon on 15/8/17.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKProperty : NSObject

/**
 *  获取属性实体
 *
 *  @return 属性实体对象
 */
+ (SDKProperty *)sharedProperty;

/**
 *  是否开启发送缓冲
 *
 *  @return 是／否
 */
+ (BOOL)isEnableSendDataBuffer;

/**
 *  发送缓冲每包发送间隔
 *
 *  @return 秒，0.0~1.0
 */
+ (float)sendDataBufferInterval;

/**
 *  设置属性
 *
 *  @param value 属性值
 *  @param key   属性名称
 */
- (void)setProperty:(NSObject *)value forKey:(NSString *)key;

/**
 *  获取设置的属性值
 *
 *  @param key 属性名称
 *
 *  @return 属性
 */
- (NSString *)getProperty:(NSString *)key;




@end
