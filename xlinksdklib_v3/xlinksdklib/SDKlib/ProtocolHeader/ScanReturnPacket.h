//
//  ScanReturnPacket.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/19.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanReturnPacket : NSObject

@property (assign, nonatomic, readonly) int8_t  version;
@property (strong, nonatomic, readonly) NSData  *macData;
@property (strong, nonatomic, readonly) NSData  *productIDData;
@property (assign, nonatomic, readonly) int8_t  mcuHardVersion;
@property (assign, nonatomic, readonly) int16_t mcuSoftVersion;
@property (assign, nonatomic, readonly) int16_t port;
@property (assign, nonatomic, readonly) int16_t deviceType;
@property (assign, nonatomic, readonly) int8_t  mode;
@property (assign, nonatomic, readonly) int8_t  flag;

@property (strong, nonatomic, readonly) NSString    *name;
@property (assign, nonatomic, readonly) int32_t     accessKey;

-(instancetype)initWithData:(NSData *)data;

@end
