//
//  SubscribeByAuthPacket.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/7.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SubscribeByAuthPacket.h"

@implementation SubscribeByAuthPacket

-(id)initWithVersion:(int8_t)version withProductID:(NSString *)productID withMacAddrwss:(NSData *)macAddress withAuthKey:(NSData *)authKey withMessageID:(int16_t)messageID withFlag:(int8_t)flag{
    if (self = [super init]) {
        _version = version;
        
        _productIDData = [NSData dataWithBytes:[productID dataUsingEncoding:NSUTF8StringEncoding].bytes length:productID.length];
        _macAddressData = macAddress;
        _authKeyData = authKey;
        
        _msgID = messageID;
        _flag = flag;
    }
    return self;
}

//-(NSUInteger)getPacketSize{
//    if (_version < 3) {
//        return 49;
//    }else{
//        return  2 + _productIDData.length + 2 + _macAddressData.length + _authKeyData.length + _messageIDData.length + _flagData.length;
//    }
//}

-(NSData *)getPacketData{
    int16_t len = htons(32);
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&len length:2];
    [data appendData:_productIDData];
    
    if (_version >= 3) {
        len = htons(_macAddressData.length);
        [data appendBytes:&len length:2];
    }
    
    [data appendData:_macAddressData];
    [data appendData:_authKeyData];
    
    [data appendBytes:&_msgID length:2];
    [data appendBytes:&_flag length:1];
    
    return [NSData dataWithData:data];
}

@end
