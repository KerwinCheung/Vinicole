//
//  XlinkMessage.h
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MSG_TYPE_SET_LOCAL_AUTH     0x01
#define MSG_TYPE_SEND_LOCAL_PIPE    0x02
#define MSG_TYPE_SEND_LOCAL_HANK    0x03
#define MSG_TYPE_SUBSCRIBE_CLOUD    0x04
#define MSG_TYPE_SET_CLOUD_AUTH     0x05
#define MSG_TYPE_SEND_CLOUD_PIPE    0x06
#define MSG_TYPE_SEND_CLOUD_PROBE   0x07
#define MSG_TYPE_SEND_SET_ACK       0x08
#define MSG_TYPE_GET_SUBKEY         0x09
#define MSG_TYPE_SET_DATAPOINT      0x0A

@interface XlinkMessage : NSObject
@property (nonatomic,assign)int messageID;
@property (nonatomic,assign)int messageType;
-(void)checkTimeOut;
@end
