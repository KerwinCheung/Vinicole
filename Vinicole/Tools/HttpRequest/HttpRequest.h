//
//  HttpRequest.h
//  HttpRequest
//
//  Created by xtmac on 29/10/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

//凝卓 企业id
#define CorpId @"1007d2ada2c3e200"

//正式
//#define Domain @"https://api2.xlink.cn"
//灰度
#define Domain @"https://api-grey.xlink.cn"

// 插件服务器
#define plugInNnit @"http://plugin-api.xlink.cn"


//正式服务器
#define kAppId @"2e0fa2af4b46ac00"

#define CustomErrorDomain @"cn.xlink.httpRequest"

#define ErrInfo(ErrCode) [HttpRequest getErrorInfoWithErrorCode:(ErrCode)]

typedef void (^MyBlock) (id result, NSError *err);


@interface shareDeviceObject : NSObject

//@interface DeviceObject : NSObject

@property (strong, nonatomic) NSString *product_id;
@property (strong, nonatomic) NSString *mac;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *access_key;
@property (strong, nonatomic) NSString *mcu_mod;
@property (strong, nonatomic) NSString *mcu_version;
@property (strong, nonatomic) NSString *firmware_mod;
@property (strong, nonatomic) NSString *firmware_version;

-(instancetype)initWithProductID:(NSString *)product_id withMac:(NSString *)mac withAccessKey:(NSNumber *)accessKey;

@end


@interface HttpRequest : NSObject

/**
 *  根据错误码获取错误信息
 *
 *  @param errCode 错误码
 *
 *  @return 错误信息
 */
+(NSString *)getErrorInfoWithErrorCode:(NSInteger)errCode;

#pragma mark
#pragma mark 用户开发接口

/**
 *  1、用户请求发送验证码（邮箱方式不需要获取验证码）
 *
 *  @param phone 手机号码
 *  @param block 完成后的回调
 */
+(void)getVerifyCodeWithPhone:(NSString *)phone didLoadData:(MyBlock)block;

/**
 *  2、注册帐号
 *
 *  @param account    帐号：手机号码/邮箱地址
 *  @param nickname   昵称
 *  @param verifyCode 验证码（邮箱注册不需要验证码）
 *  @param pwd        密码
 *  @param block      完成后的回调
 */
+(void)registerWithAccount:(NSString *)account withNickname:(NSString *)nickname withVerifyCode:(NSString *)verifyCode withPassword:(NSString *)pwd didLoadData:(MyBlock)block;

/**
 *  4、用户认证(登录)
 *
 *  @param account 帐号 : 手机号码/邮箱地址
 *  @param pwd     密码
 *  @param block   完成后的回调
 */
+(void)authWithAccount:(NSString *)account withPassword:(NSString *)pwd didLoadData:(MyBlock)block;

/**
 *  5、修改帐号昵称
 *
 *  @param nickname    要修改的昵称
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 */
+(void)modifyAccountNickname:(NSString *)nickname withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  6、重置密码
 *
 *  @param oldPwd      旧密码
 *  @param newPwd      新密码
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)resetPasswordWithOldPassword:(NSString *)oldPwd withNewPassword:(NSString *)newPwd withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  7.1、忘记密码(获取重置密码的验证码)
 *
 *  @param account     忘记密码的帐号
 *  @param block       完成后的回调
 */
+(void)forgotPasswordWithAccount:(NSString *)account didLoadData:(MyBlock)block;

/**
 *  7.2、找回密码(根据获取到的验证码设置新密码)
 *
 *  @param account     要找回密码的帐号
 *  @param verifyCode  验证码
 *  @param pwd         要设置的新密码
 *  @param block       完成后的回调
 */
+(void)foundBackPasswordWithAccount:(NSString *)account withVerifyCode:(NSString *)verifyCode withNewPassword:(NSString *)pwd didLoadData:(MyBlock)block;

/**
 *  9、取消订阅
 *
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param deviceID    设备ID
 *  @param block       完成后的回调
 */
+(void)unsubscribeDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDeviceID:(NSNumber *)deviceID didLoadData:(MyBlock)block;

/**
 *  10、获取该企业下注册的用户列表
 *
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getUserListWithAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  11、获取用户详细信息
 *
 *  @param userID      用户id
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getUserInfoWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  12、获取设备列表
 *
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param version     当前列表的版本号，根据当前版本号判定列表有无更改。
 *  @param block       完成后的回调
 */
+(void)getDeviceListWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withVersion:(NSNumber *)version didLoadData:(MyBlock)block;

/**
 *  13、获取设备的订阅用户列表
 *
 *  @param userID      用户ID
 *  @param deviceID    设备ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getDeviceUserListWithUserID:(NSNumber *)userID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  14、设置用户扩展属性
 *
 *  @param dic         扩展属性字典
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)setUserPropertyDictionary:(NSDictionary *)dic withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  15、获取用户扩展属性
 *
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getUserPropertyWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  16、修改用户扩展属性
 *
 *  @param dic         扩展属性字典
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)modifyUserPropertyDictionary:(NSDictionary *)dic withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  17、获取用户单个扩展属性
 *
 *  @param userID      用户ID
 *  @param key         属性Key值
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getUserSinglePropertyWithUserID:(NSNumber *)userID withPropertyKey:(NSString *)key withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  18、删除用户扩展属性
 *
 *  @param userID      用户ID
 *  @param key         属性Key值
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)delUserPropertyWithUserID:(NSNumber *)userID withPropertyKey:(NSString *)key withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  19、停用用户
 *
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)disableUserWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  20、更新用户所在区域
 *
 *  @param userID      用户ID
 *  @param areaID      区域ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)UpdateUserAreaWithUserID:(NSNumber *)userID withAreaID:(NSString *)areaID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  21、用户注册APN服务
 *
 *  @param userID      用户ID
 *  @param appID       用户在XLINK平台创建APP开发时，获取到的ID
 *  @param deviceToken iOS APP 运行时获取到的device_token
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)registerAPNServiceWithUserID:(NSNumber *)userID withAppID:(NSString *)appID withDeviceToken:(NSString *)deviceToken withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  22、用户停用APN服务
 *
 *  @param userID      用户ID
 *  @param appID       用户在XLINK平台创建APP开发时，获取到的ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)disableAPNServiceWithUserID:(NSNumber *)userID withAppID:(NSString *)appID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  23、获取用户注册的APN服务信息列表
 *
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getUserAPNServiceInfoWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;


#pragma mark
#pragma mark 数据存储服务开发接口


/**
 *  6、新增数据
 *
 *  @param dic          数据字典{字段A：字段A的值}
 *  @param table_name   表名
 *  @param access_token 调用凭证
 *  @param block        完成后的回调
 */
//+(void)addData:(NSDictionary *)dic withTableName:(NSString *)tableName withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;



/**
 *  8、查询数据
 *
 *  @param table_name   表名
 *  @param access_token 调用凭证
 *  @param block        完成后的回调
 */
//+(void)queryDataWithTableName:(NSString *)tableName withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  9、修改数据
 *
 *  @param dic          数据字典
 *  @param table_name   表名
 *  @param object_id    字段ID
 *  @param access_token 调用凭证
 *  @param block        完成后的回调
 */
//+(void)modifyData:(NSDictionary *)dic withTableName:(NSString *)tableName withObjectID:(NSString *)objectID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  10、删除数据
 *
 *  @param table_name   表名
 *  @param object_id    字段ID
 *  @param access_token 调用凭证
 *  @param block        完成后的回调
 */
//+(void)delDataWithTableName:(NSString *)tableName withObjectID:(NSString *)objectID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

+(void)registerDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDevice:(shareDeviceObject *)deviceObject didLoadData:(MyBlock)block;

#pragma mark
#pragma mark 产品与设备管理接口


/**
 *  1、添加设备
 *
 *  @param mac          设备的mac地址
 *  @param productID    设备的产品ID
 *  @param access_token 调用凭证
 *  @param block        完成后的回调
 */
+(void)addDeviceWithMacAddress:(NSString *)mac withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  2、导入设备
 *
 *  @param macArr      设备的mac地址的数组
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)importDeviceWithMacAddressArr:(NSArray *)macArr withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  3、获取设备信息
 *
 *  @param deviceID    设备ID
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getDeviceInfoWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  4、修改设备信息
 *
 *  @param deviceID    设备ID
 *  @param dic         要修改的设备信息字典
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)modifyDeviceInfoWithDeviceID:(NSNumber *)deviceID withInfoDic:(NSDictionary *)dic withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  5、查询设备列表
 *
 *  @param productID   要查询的设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)queryDeviceListWithProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  6、删除设备
 *
 *  @param deviceID    设备ID
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)delDeviceWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  7、设置设备扩展属性
 *
 *  @param dic         属性字典
 *  @param deviceID    设备ID
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)setDevicePropertyDictionary:(NSDictionary *)dic withDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  8、获取设备扩展属性
 *
 *  @param deviceID    设备ID
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getDevicePropertyWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  9、修改设备扩展属性
 *
 *  @param dic         属性字典
 *  @param deviceID    设备ID
 *  @param productID   设备的产品ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)modifyDevicePropertyDictionary:(NSDictionary *)dic withDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  获取设备地理信息
 *
 *  @param productID   产品ID
 *  @param deviceID    设备ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getDeviceGeographyInfoWithProductID:(NSString *)productID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;


+(void)getDeviceLocationWithLat:(NSNumber *)lat Lon:(NSNumber *)lon didLoadData:(MyBlock)block;

#pragma mark
#pragma mark 设备功能接口

/**
 *  email分享设备
 *
 *  @param deviceID    被分享的设备的ID
 *  @param accessToken 调用凭证
 *  @param email       被分享的用户的email地址
 *  @param expire      分享消息的有效时间
 *  @param model       分享方式 |"app"|"qrcode"|"email"| (qrcode方式不用传email地址)
 *  @param block       完成后的回调
 *  @param authority   分享权限
 */
+(void)shareDeviceInEmailWithDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken withShareAccount:(NSString *)account withExpire:(NSNumber *)expire withModel:(NSString *)model withAuthority:(NSString *)authority didLoadData:(MyBlock)block;

/**
 *  取消分享
 *
 *  @param accessToken 调用凭证
 *  @param inviteCode  邀请码
 *  @param block       完成后的回调
 */
+(void)cancelShareDeviceWithAccessToken:(NSString *)accessToken withInviteCode:(NSString *)inviteCode didLoadData:(MyBlock)block;

/**
 *  接受分享
 *
 *  @param inviteCode  邀请码
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)acceptShareWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  拒绝分享
 *
 *  @param inviteCode  邀请码
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)denyShareWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  获取分享列表
 *
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getShareListWithAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  管理员或用户删除这条分享请求记录
 *
 *  @param inviteCode  邀请码
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)delShareRecordWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  通过二维码订阅设备
 *
 *  @param userID      用户ID
 *  @param accessToken 调用凭证
 *  @param productID   产品ID
 *  @param encryptMac  加密后的MAC地址
 *  @param block       完成后的回调
 */
+(void)subscribeDeviceByQRCodeWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withProductID:(NSString *)productID withEncryptMac:(NSString *)encryptMac didLoadData:(MyBlock)block;







+(void)putUserConfigWithAppID:(NSNumber *)appid withUserConfig:(NSDictionary *)userConfig didLoadData:(MyBlock)block;
+(void)getUserConfigWithAppID:(NSNumber *)appid didLoadData:(MyBlock)block;

+(void)delUserConfigWithAppID:(NSNumber *)appid didLoadData:(MyBlock)block;


/**
 *  获取设备的固件版本
 *
 *  @param device_id   设备ID
 *  @param product_id  PID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getVersionWithDeviceID:(NSString *)device_id withProduct_id:(NSString *)product_id withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;


/**
 *  升级设备的固件版本
 *
 *  @param device_id   设备ID
 *  @param product_id  PID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)upgradeWithDeviceID:(NSString *)device_id withProduct_id:(NSString *)product_id withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  修改用户基本信息
 *
 *  @param nickname   "用户昵称"
 *  @param remark     "备注"
 *  @param tags       ["标签1","标签2"]
 *  @param avatar     "用户头像url"
 *  @param block       完成后的回调
 * 备注：remark和nickname,tags,avatar都可以不是必须项
 */
+(void)saveUserInfoWithUserId:(NSNumber *)userId nickName:(NSString *)nickname remark:(NSString *)remark tags:(NSString *)tags avatarUrl:(NSString *)avatarUrl withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

/**
 *  上传头像
 *
 *  @param imageData  头像图片data
 *  @param accessToken     accessToken
 *  @param block       完成后的回调
 */
+(void)saveUserInfoWithImageData:(NSData *)imageData withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark
#pragma mark 应用身份接口文档
/**
 *  申请应用接口调用凭证
 *
 *  @param accessToken 调用凭证
 *  @param appID       appID
 *  @param block       完成后的回调
 */
+(void)requestCorpAccessTokenWithAccessToken:(NSString *)accessToken withAppID:(NSString *)appID didLoadData:(MyBlock)block;

#pragma mark
#pragma mark 用户反馈接口
/*
 user_id : 1,
 user_name: "小明",
 phone:"1689624223",
 email:"xiaoming@qq.com",
 content:"电饭煲无法启用",
 image:["1.jpg"],
 product_id : 2,
 product_name:"电饭煲",
 label:["故障报修"],
 firmware_version:'1.0',
 system_info : "iPhone , OS8.2",
 software_version": "1.6",
 system_language : "中文",
 creator : "小明",
 create_time : "2016-05-17T01:03:27.453Z"，
 status: 0
 */
/**
 *  用户反馈
 *
 *  @param appID       用户反馈插件的appID
 *  @param accessToken 用用户AccessToken换取的企业AccessToken
 *  @param content     内容如上注释内容，key可选
 *  @param block       完成后的回调
 */
+(void)addFeedBackWithAppID:(NSString *)appID withAccessToken:(NSString *)accessToken withContent:(NSDictionary *)content didLoadData:(MyBlock)block;

#pragma mark - 添加用户反馈成功后再次调用的接口
/**
 *  最后由这个接口判断用户反馈是否成功
 */
+(void)feedBackRecordWithAppID:(NSString *)appID withAccessToken:(NSString *)accessToken withContent:(NSDictionary *)content didLoadData:(MyBlock)block;


#pragma mark
#pragma mark 虚拟设备功能接口
/**
 *  获取虚拟设备
 *
 *  @param productID   产品ID
 *  @param deviceID    设备ID
 *  @param accessToken 调用凭证
 *  @param block       完成后的回调
 */
+(void)getVirtualDeviceWithProductID:(NSString *)productID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark
#pragma mark xfile接口
+(void)uploadFileWithAccessToken:(NSString *)accessToken withFileType:(NSString *)type withFileData:(NSData *)data didLoadData:(MyBlock)block;

#pragma mark
#pragma mark 获取设备快照
+(void)getDevicesnapshotWithOffset:(NSNumber *)offset limit:(NSNumber *)limit DateDic:(NSDictionary *)dateDic ProductID:(NSString *)productID  DeviceID:(NSNumber *)deviceID AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark 获取室外pm2.5
/**
 *  startDate和endDate 传这种格式 @"2016-09-08 23:30:59"
 */
+(void)getDeviceOutDoorPm25WithOffset:(NSNumber *)offset limit:(NSNumber *)limit address:(NSString *)address startDate:(NSString *)startDate currentDate:(NSString *)currentDate AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark
#pragma mark 获取推送告警
+(void)getWarnningListWithOffset:(NSNumber *)offset limit:(NSNumber *)limit type:(NSNumber *)type notify_type:(NSNumber *)notify_type userId:(NSNumber *)userId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark 获取推送消息
+(void)getMessageListWithOffset:(NSNumber *)offset limit:(NSNumber *)limit type:(NSNumber *)type notify_type:(NSNumber *)notify_type userId:(NSNumber *)userId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark 删除推送消息
+ (void)deleteMessageWithUserId:(NSNumber *)userId AccessToken:(NSString *)accessToken messageID:(NSString *)messageId didLoadData:(MyBlock)block;

#pragma mark 获取使用须知
/**
 * appId 是使用须知的 APPid
 */
+ (void)getExplainWithOffset:(NSNumber *)offset limit:(NSNumber *)limit appId:(NSString *)appId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;


#pragma mark 获取所有设备信息
+(void)getDeviceInfoWithUserID:(NSNumber *)userId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark 获取设备维保信息
+(void)getDeviceRepairHistoryWithDeviceSn:(NSString *)deviceSn AppID:(NSString *)appId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

#pragma mark 获取设备维保详情
+(void)getDeviceRepairDetailWithRepairId:(NSString *)repairId AppID:(NSString *)appId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;


#pragma mark - 删除体验设备
+(void)deleteExperienceDeviceWithUserId:(NSNumber *)userId state:(NSNumber *)state AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;


#pragma mark - 把分享报告的链接转短
+(void)longUrlTransformationShortUrlWith:(NSString *)longUrl AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block;

@end
