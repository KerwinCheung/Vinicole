//
//  Utils.m
//  xlinksdklib
//
//  Created by Leon on 15/8/13.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSData*)hexToData:(NSString *)hexString {
    
    NSUInteger len = hexString.length / 2;
    const char *hexCode = [hexString UTF8String];
    char * bytes = (char *)malloc(len);
    
    char *pos = (char *)hexCode;
    for (NSUInteger i = 0; i < hexString.length / 2; i++) {
        sscanf(pos, "%2hhx", &bytes[i]);
        pos += 2 * sizeof(char);
    }
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}



@end
