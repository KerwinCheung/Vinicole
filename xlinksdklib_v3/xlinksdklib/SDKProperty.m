//
//  SDKProperty.m
//  xlinksdklib
//
//  Created by Leon on 15/8/17.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "SDKProperty.h"
#import "XLinkExportObject.h"

@implementation SDKProperty {
    NSMutableDictionary * _propertyDict;
}

static SDKProperty * _sharedProperty;


+(SDKProperty *)sharedProperty{
    
    @synchronized(self){
        if (_sharedProperty==nil) {
            _sharedProperty = [[SDKProperty alloc] init];
        }
    }
    
    return _sharedProperty;
}

+(BOOL)isEnableSendDataBuffer {
    if( [[SDKProperty sharedProperty] getProperty:PROPERTY_SEND_DATA_BUFFER] ) {
        return [[[SDKProperty sharedProperty] getProperty:PROPERTY_SEND_DATA_BUFFER] boolValue];
    }
    
    return NO;
}

+ (float)sendDataBufferInterval {
    if( [[SDKProperty sharedProperty] getProperty:PROPERTY_SEND_DATA_INTERVAL] ) {
        return [[[SDKProperty sharedProperty] getProperty:PROPERTY_SEND_DATA_INTERVAL] floatValue];
    }
    
    return 0.1;
}

- (id)init {
    self = [super init];
    if( self ) {
        _propertyDict = [[NSMutableDictionary alloc] init];
        
        // 初始化固定属性
        [_propertyDict setObject:@"cm.xlink.cn" forKey:PROPERTY_CM_SERVER_ADDR];
        
        return self;
    }
    
    return  nil;
}

- (void)setProperty:(NSObject *)value forKey:(NSString *)key {
    [_propertyDict setObject:value forKey:key];
}

- (NSObject *)getProperty:(NSString *)key {
    return [_propertyDict objectForKey:key];
}

@end
