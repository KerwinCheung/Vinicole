//
//  ScanHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int8_t{
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
-(NSData *)getPacketData;

/*
 *@discussion
 * 获得包的大小
 */
-(NSUInteger)getPacketSize;

@end
