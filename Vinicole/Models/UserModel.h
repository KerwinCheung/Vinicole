//
//  UserModel.h
//  lightify
//
//  Created by xtmac on 20/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceModel;


@interface UserModel : NSObject

@property (strong, nonatomic) NSString  *email;//用户名
@property (strong, nonatomic) NSString  *password;
@property (strong, nonatomic) NSString  *nickName;
@property (strong, nonatomic) NSString  *accessToken;
@property (strong, nonatomic) NSNumber  *userId;
@property (strong, nonatomic) NSString  *authorize;
@property (strong, nonatomic) NSNumber  *isVaild;

@property (strong, nonatomic) NSString  *uploadTime;

@property (strong, nonatomic) NSMutableArray    <DeviceModel *>*deviceList;
@property (strong, nonatomic) NSMutableArray    <DeviceModel *>*willDelDeviceList;

-(instancetype)initWithEmail:(NSString *)emailStr andPassword:(NSString *)password;

-(instancetype)initWithDictionary:(NSDictionary *)dic;

-(void)setProperty:(NSDictionary *)propertyDic;

-(NSDictionary *)getDictionary;

@end
