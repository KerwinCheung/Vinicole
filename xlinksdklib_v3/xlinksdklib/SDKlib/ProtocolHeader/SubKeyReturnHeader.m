//
//  SubKeyReturnHeader.m
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/18.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import "SubKeyReturnHeader.h"

@implementation SubKeyReturnHeader

-(id)initWithData:(NSData *)data{
    if (self = [super init]) {
        [data getBytes:&_messageID range:NSMakeRange(0, 2)];
        [data getBytes:&_code range:NSMakeRange(2, 1)];
        _messageID = htons(_messageID);
        if (!_code) {
            [data getBytes:&_subKey range:NSMakeRange(3, 4)];
            _subKey = htonl(_subKey);
        }
    }
    return self;
}

@end
