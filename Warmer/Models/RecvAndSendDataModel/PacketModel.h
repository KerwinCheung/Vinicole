//
//  PacketModel.h
//  lightify
//
//  Created by xtmac on 19/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PacketModel : NSObject

/**
 *  包头
 */
@property (assign, nonatomic) UInt16 head;

/**
 *  包长度
 */
@property (assign, nonatomic) unsigned short length;

/**
 *  指令
 */
@property (assign, nonatomic) unsigned char command;

/**
 *  流水号
 */
@property (assign, nonatomic) unsigned char serial;

/**
 *  实体数据
 */
@property (strong, nonatomic) NSData *data;

/**
 *  校验码
 */
@property (assign, nonatomic) unsigned short checkCode;

/**
 *  包尾
 */
@property (assign, nonatomic) UInt16 tail;

@property (strong, nonatomic) id userInfo;

-(instancetype)initWithPacketData:(NSData *)packetData;

-(NSData *)getData;

-(BOOL)veriflcation;

@end
