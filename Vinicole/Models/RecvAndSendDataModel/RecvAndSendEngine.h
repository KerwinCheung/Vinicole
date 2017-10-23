//
//  RecvDataEngine.h
//  lightify
//
//  Created by xtmac on 19/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceEntity, PacketModel;


@interface RecvAndSendEngine : NSObject

+(RecvAndSendEngine *)shareEngine;

-(void)sendPacket:(PacketModel *)packetModel withDevice:(DeviceEntity *)deviceEntity;
-(void)sendPacketInUDP:(PacketModel *)packetModel withDevice:(DeviceEntity *)deviceEntity;
-(void)recvData:(NSData *)data withDevice:(DeviceEntity *)device;

@end
