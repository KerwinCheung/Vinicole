//
//  ScanHeader.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/26.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "ScanHeader.h"
#import "SDKHeader.h"

/*
 *扫描协议头
 */

@implementation ScanHeader{
    
    int8_t  _version;
    int16_t _port;
    int8_t  _mode;
    
    NSData  *_entityData;  // productid/mac

}

/*
 *@discussion
 *   协议的初始化函数
 */
-(id)initWithVersion:(int)aVersion andPort:(int)aPort andMacAddress:(NSData *)mac{
    self = [self init];
    if (self) {
        
        _version = aVersion;
        
        _port = aPort;
        
        _mode = ScanModeByMacAddress;
        
        _entityData = mac;
        
    }
    return self;
}

-(id)initWithVersion:(int)aVersion andPort:(int)aPort andProductID:(NSString *)productID{
    self = [self init];
    if (self) {
        
        _version = aVersion;
        
        _port = aPort;
        
        _mode = ScanModeByProductiD;
        
        _entityData = [productID dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    return self;
}

/*
 *@discussion
 *  得到协议的bytes
 */
-(NSData *)getPacketData{
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&_version length:1];
    
    int16_t port = htons(_port);
    [data appendBytes:&port length:2];
    [data appendBytes:&_mode length:1];
    
    if (_mode == ScanModeByMacAddress && _version >= 3) {
        int16_t len = _entityData.length;
        len = htons(len);
        [data appendBytes:&len length:2];
    }
    
    [data appendData:_entityData];
    
    return [NSData dataWithData:data];
}
/*
 *@discussion
 *  得到协议的包大小
 */
-(NSUInteger)getPacketSize{
    NSData *data = [self getPacketData];
    return data.length;
}

@end
