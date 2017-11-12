//
//  DataSource.h
//  lightify
//
//  Created by xtmac on 20/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel, ActionModel, DeviceModel;

#define DATASOURCE [DataSource shareDataSource]

@interface DataSource : NSObject

@property (strong, nonatomic) UserModel *user;

+(DataSource *)shareDataSource;

-(void)saveUserWithIsUpload:(BOOL)isUpload;
-(void)saveDeviceModelWithMac:(NSString *)mac withIsUpload:(BOOL)isUpload;

-(DeviceModel *)getDeviceModelWithMac:(NSString *)mac;
-(DeviceModel *)getWillDelDeviceModelWithMac:(NSString *)mac;

@end
