//
//  SubKeyReturnHeader.h
//  xlinksdklib
//
//  Created by 黄 庆超 on 16/5/18.
//  Copyright © 2016年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubKeyReturnHeader : NSObject

@property (assign, nonatomic) uint16_t  messageID;
@property (assign, nonatomic) int8_t    code;
@property (assign, nonatomic) int32_t   subKey;

-(id)initWithData:(NSData *)data;

@end
