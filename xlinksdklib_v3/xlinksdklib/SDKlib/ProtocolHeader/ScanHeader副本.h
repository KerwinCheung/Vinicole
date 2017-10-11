//
//  ScanHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKHeader.h"

typedef enum : unsigned char{
    ScanModeByMacAddress    =   0b01,
    ScanModeByProductiD     =   0b10
}ScanMode;

@interface ScanHeader : NSObject
/*
 *@discussion 
 *  初始化函数
 */
-(id)initWithVersion:(int)aVersion andPort:(int)aPort andMacAddress:(NSData *)mac;
-(id)initWithVersion:(int)aVersion andPort:(int)aPort andProductID:(NSString *)productID;
/*
 *@discussion
 *  获得包的bytes
 */
-(NSMutableData *)getPacketData;

-(ScanMode)getScanMode;

/*
 *@discussion
 * 获得包的大小
 */
-(int)getPacketSize;

/*
 *@discussion
 * 设置协议的版本
 */
-(void)setVersion:(int)aVersion;
/*
 *@discussion
 *   设置监听的端口号
 */
-(void)setPort:(int)aPort;
/*
 *@discussion
 *  设置保留标示
 */
-(void)setReserved:(ScanMode)aReserved;

@end
