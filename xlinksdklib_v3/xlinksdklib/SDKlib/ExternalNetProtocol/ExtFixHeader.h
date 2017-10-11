//
//  ExtFixHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExtFixHeader : NSObject

+(ExtFixHeader *)loginExtFixHeader;

+(ExtFixHeader *)pipeExtFixHeader;

+(ExtFixHeader *)activateExtFixHeader;

+(ExtFixHeader *)connectExtFixHeader;

+(ExtFixHeader *)setExtFixHeader;

+(ExtFixHeader *)syncExtFixHeader;

+(ExtFixHeader *)subscriptionExtFixHeaderWithVersion:(uint8_t)version;

+(ExtFixHeader *)pingExtFixHeader;

+(ExtFixHeader *)pipeResponseHeader;

+(ExtFixHeader *)probeHeader;

+(ExtFixHeader *)CloudSetAuthHeader;

+(ExtFixHeader *)disconnectHeader;

+(ExtFixHeader *)dataPointHeader;

-(NSMutableData *)getPacketData;

-(id)initWithFixHeader:(NSData *)data;

-(void)setFixInfo:(int)info;

-(int)getFixInfo;

-(void)setDataLength:(int)len;

-(int)getDataLength;

+(int)getPacketSize;

-(int)getPacketSize;

@end
