//
//  HttpRequest.m
//  HttpRequest
//
//  Created by xtmac on 29/10/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "HttpRequest.h"
#import <CommonCrypto/CommonDigest.h>

#define RequestTypeGet      @"GET"
#define RequestTypePUT      @"PUT"
#define RequestTypePOST     @"POST"
#define RequestTypeDelete   @"DELETE"



#define url_put_str                 @"http://app.xlink.cn/v1/bucket/put"
#define url_get_str                 @"http://app.xlink.cn/v1/bucket/get"
#define url_del_str                 @"http://app.xlink.cn/v1/bucket/delete"


//访问accessID，权限
#define dataAccesskeyId @"a45c1f1a861348738b0538d989657772"
#define dataSecretKey @"d77e9c6aae024cfcb585fd834f3addf3"

//typedef void (^MyDataBlock) (NSDictionary *dic);

@implementation shareDeviceObject

-(instancetype)initWithProductID:(NSString *)product_id withMac:(NSString *)mac withAccessKey:(NSNumber *)accessKey{
    if (self = [super init]) {
        _product_id = product_id;
        _mac = mac;
        _access_key = accessKey;
    }
    return self;
}

@end

@interface HttpRequest ()<NSURLConnectionDataDelegate>

@property (copy, nonatomic) MyBlock myBlock;
//@property (copy, nonatomic) MyDataBlock myDataBlock;

@end

@implementation HttpRequest{
    NSMutableData *_httpReceiveData;
}

-(id)init{
    if (self = [super init]) {
        _httpReceiveData = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)requestWithRequestType:(NSString *)requestType withUrl:(NSString *)urlStr withHeader:(NSDictionary *)header withContent:(id)content{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:requestType];
    
    for (NSString *key in header.allKeys) {
        [request addValue:[header objectForKey:key] forHTTPHeaderField:key];
    }
    
    NSLog(@"urlStr=%@", urlStr);
    NSLog(@"header=%@", header);
    
    NSMutableString *mutable = [NSMutableString stringWithFormat:@"%@?",urlStr];
    if ([content isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)content;
        for (int i = 0; i < param.allValues.count; i++) {
            NSString *key = param.allKeys[i];
            id value = [param objectForKey:key];
            if (i == param.allValues.count - 1) {
                mutable = (NSMutableString *)[mutable stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
            }else {
                mutable = (NSMutableString *)[mutable stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,value]];
            }
            
            
        }
        
        NSLog(@"mutable=%@", mutable);
     
    }
    
    if (content) {
        
        if ([content isKindOfClass:[NSData class]]) {
             [request setHTTPBody:content];
        }else{
            NSData *contentData = [NSJSONSerialization dataWithJSONObject:content options:0 error:nil];
            
            //
            NSString *str = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
            //
            
            [request setHTTPBody:contentData];
        }
        
    }
    
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            if (_myBlock) _myBlock(nil, error);
        }else{
            NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
            NSLog(@"%ld %@", (long)[r statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[r statusCode]]);
            NSInteger statusCode = [r statusCode];
            if (statusCode != 200) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSError *err;
                if (result) {
                    err = [NSError errorWithDomain:Domain code:[[[result objectForKey:@"error"] objectForKey:@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey : [[result objectForKey:@"error"] objectForKey:@"msg"]}];
                }else{
                    err = [NSError errorWithDomain:Domain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"unknow err"}];
                }
                _myBlock(nil, err);
            }else{
                NSError *err;
                NSDictionary *result = nil;
                if (data.length) {
                    result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                }else{
                    result = @{@"state":@(statusCode)};
                }
                
                NSLog(@"result=%@",result);
                if (err) {
                    if (_myBlock) _myBlock(nil, err);
                }else{
                    if (_myBlock) _myBlock(result, nil);
                }
            }
        }
        
    }];
    [task resume];
    
}

+ (NSDictionary *)getHeader:(NSString *)accessToken {
    if (accessToken != nil) {
        return @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
    }else {
        return @{@"Content-Type" : @"application/json", @"Access-Token" : @""};
    }
}




#pragma mark
#pragma mark 用户开发接口

#pragma mark 1、注册用户请求发送验证码
+(void)getVerifyCodeWithPhone:(NSString *)phone didLoadData:(MyBlock)block{
    HttpRequest *req = [[HttpRequest alloc] init];
    req.myBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/json"};
    NSDictionary *content = @{@"corp_id" : CorpId, @"phone" : phone};
    [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_register/verifycode"] withHeader:header withContent:content];
}

#pragma mark 2、注册帐号
+(void)registerWithAccount:(NSString *)account withNickname:(NSString *)nickname withVerifyCode:(NSString *)verifyCode withPassword:(NSString *)pwd didLoadData:(MyBlock)block{
    
    do {
        NSDictionary *content = nil;
        
        if ([self validatePhone:account]) {
            content = @{@"phone" : account, @"nickname" : nickname, @"corp_id": CorpId, @"verifycode" : verifyCode, @"password" : pwd, @"source" : @"3"};
        }else if ([self validateEmail:account]){
            content = @{@"email" : account, @"nickname" : nickname, @"corp_id": CorpId, @"password" : pwd, @"source" : @"3"};
        }
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_register"] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 4、用户认证
+(void)authWithAccount:(NSString *)account withPassword:(NSString *)pwd didLoadData:(MyBlock)block{
    
    do {
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        //验证帐号是否正确
        if ([self validatePhone:account]) {
            [content setObject:account forKey:@"phone"];
        }else if ([self validateEmail:account]){
            [content setObject:account forKey:@"email"];
        }
        
        [content setObject:pwd forKey:@"password"];
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user_auth"] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 5、修改帐号昵称
+(void)modifyAccountNickname:(NSString *)nickname withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *content = @{@"nickname" : nickname};
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@", Domain, userID] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 6、重置密码
+(void)resetPasswordWithOldPassword:(NSString *)oldPwd withNewPassword:(NSString *)newPwd withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *content = @{@"old_password" : oldPwd, @"new_password" : newPwd};
        [req requestWithRequestType:RequestTypePUT withUrl:[Domain stringByAppendingString:@"/v2/user/password/reset"] withHeader:header withContent:content];
        
    } while (0);
    
}

#pragma mark 7.1、忘记密码(获取重置密码的验证码)
+(void)forgotPasswordWithAccount:(NSString *)account didLoadData:(MyBlock)block{
    
    do {
        
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        //验证帐号是否正确
        if ([self validatePhone:account]) {
            [content setObject:account forKey:@"phone"];
        }else if ([self validateEmail:account]){
            [content setObject:account forKey:@"email"];
        }
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user/password/forgot"] withHeader:header withContent:content];
        
    } while (0);
    
}

#pragma mark 7.2、找回密码(根据验证码设置新密码)
+(void)foundBackPasswordWithAccount:(NSString *)account withVerifyCode:(NSString *)verifyCode withNewPassword:(NSString *)pwd didLoadData:(MyBlock)block{
    
    do {
        
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObject:CorpId forKey:@"corp_id"];
        
        //验证帐号是否正确
        if ([self validatePhone:account]) {
            [content setObject:account forKey:@"phone"];
        }else if ([self validateEmail:account]){
            [content setObject:account forKey:@"email"];
        }
        
        [content setObject:verifyCode forKey:@"verifycode"];
        [content setObject:pwd forKey:@"new_password"];
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json"};
        [req requestWithRequestType:RequestTypePOST withUrl:[Domain stringByAppendingString:@"/v2/user/password/foundback"] withHeader:header withContent:content];
        
    } while (0);
    
}

#pragma mark 9、取消订阅
+(void)unsubscribeDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDeviceID:(NSNumber *)deviceID didLoadData:(MyBlock)block{
    do {
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/unsubscribe", Domain, userID] withHeader:header withContent:@{@"device_id" : deviceID}];
        
    } while (0);
}

#pragma mark 10、用户列表查询
+(void)getUserListWithAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/users", Domain] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 11、获取用户详细信息
+(void)getUserInfoWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@", Domain, userID] withHeader:header withContent:nil];
    } while (0);
    
}

#pragma mark 12、获取设备列表
+(void)getDeviceListWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withVersion:(NSNumber *)version didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/subscribe/devices?version=%@", Domain, userID,version] withHeader:header withContent:nil];
        
    } while (0);
}

#pragma mark 13、获取设备的订阅用户列表
+(void)getDeviceUserListWithUserID:(NSNumber *)userID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/subscribe_users?device=%@", Domain, userID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 14、设置用户扩展属性
+(void)setUserPropertyDictionary:(NSDictionary *)dic withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain, userID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 15、获取用户扩展属性
+(void)getUserPropertyWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain, userID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 16、修改用户扩展属性
+(void)modifyUserPropertyDictionary:(NSDictionary *)dic withUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain, userID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 17、获取用户单个扩展属性
+(void)getUserSinglePropertyWithUserID:(NSNumber *)userID withPropertyKey:(NSString *)key withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property/%@", Domain, userID, key] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 18、删除用户扩展属性
+(void)delUserPropertyWithUserID:(NSNumber *)userID withPropertyKey:(NSString *)key withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property/%@", Domain, userID, key] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 19、停用用户
+(void)disableUserWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/status", Domain, userID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 20、更新用户所在区域
+(void)UpdateUserAreaWithUserID:(NSNumber *)userID withAreaID:(NSString *)areaID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/region", Domain, userID] withHeader:header withContent:@{@"region_id" : areaID}];
    } while (0);
}

#pragma mark 21、用户注册APN服务
+(void)registerAPNServiceWithUserID:(NSNumber *)userID withAppID:(NSString *)appID withDeviceToken:(NSString *)deviceToken withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *content = @{@"app_id" : appID, @"device_token" : deviceToken};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/apn_register", Domain, userID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 22、用户停用APN服务
+(void)disableAPNServiceWithUserID:(NSNumber *)userID withAppID:(NSString *)appID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *content = @{@"app_id" : appID};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/apn_unregister", Domain, userID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 23、获取用户注册的APN服务信息列表
+(void)getUserAPNServiceInfoWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/apns", Domain, userID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark
#pragma mark 数据存储服务开发接口

//#pragma mark 新增字段
//+(void)addData:(NSDictionary *)dic withTableName:(NSString *)tableName withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
//    do {
//        HttpRequest *req = [[HttpRequest alloc] init];
//        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
//        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/data/%@", Domain, tableName] withHeader:header withContent:dic];
//    } while (0);
//}
//
//#pragma mark 查询表
//+(void)queryDataWithTableName:(NSString *)tableName withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
//    do {
//        HttpRequest *req = [[HttpRequest alloc] init];
//        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
//        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/datas/%@", Domain, tableName] withHeader:header withContent:@{@"filter":@[@"selecthome",@"homelist",@"cameraconfig"]}];
//
//    } while (0);
//}
//
//#pragma mark 修改数据
//+(void)modifyData:(NSDictionary *)dic withTableName:(NSString *)tableName withObjectID:(NSString *)objectID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
//    do {
//        tableName = @"leedarson_user";
//        HttpRequest *req = [[HttpRequest alloc] init];
//        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
//        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/data/%@/%@", Domain, tableName, objectID] withHeader:header withContent:dic];
//
//    } while (0);
//
//}
//
//+(void)delDataWithTableName:(NSString *)tableName withObjectID:(NSString *)objectID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
//    do {
//
//        HttpRequest *req = [[HttpRequest alloc] init];
//        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
//        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/data/%@/%@", Domain, tableName, objectID] withHeader:header withContent:nil];
//
//    } while (0);
//}

#pragma mark 注册设备
+(void)registerDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDevice:(shareDeviceObject *)deviceObject didLoadData:(MyBlock)block{}

#pragma mark
#pragma mark 产品与设备管理接口

#pragma mark 1、添加设备
+(void)addDeviceWithMacAddress:(NSString *)mac withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device", Domain, productID] withHeader:header withContent:@{@"mac" : mac}];
    } while (0);
}

#pragma mark 2、导入设备
+(void)importDeviceWithMacAddressArr:(NSArray *)macArr withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device_batch", Domain, productID] withHeader:header withContent:macArr];
    } while (0);
}

#pragma mark 3、获取设备信息
+(void)getDeviceInfoWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
//    do {
//        HttpRequest *req = [[HttpRequest alloc] init];
//        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
//        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@", Domain, productID, deviceID] withHeader:header withContent:nil];
//    } while (0);
}

#pragma mark 4、修改设备信息
+(void)modifyDeviceInfoWithDeviceID:(NSNumber *)deviceID withInfoDic:(NSDictionary *)dic withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@", Domain, productID, deviceID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 5、查询设备列表
+(void)queryDeviceListWithProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/devices", Domain, productID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 6、删除设备
+(void)delDeviceWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 7、设置设备扩展属性
+(void)setDevicePropertyDictionary:(NSDictionary *)dic withDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/property", Domain, productID, deviceID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 8、获取设备扩展属性
+(void)getDevicePropertyWithDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/property", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 9、修改设备扩展属性
+(void)modifyDevicePropertyDictionary:(NSDictionary *)dic withDeviceID:(NSNumber *)deviceID withProductID:(NSString *)productID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/property", Domain, productID, deviceID] withHeader:header withContent:dic];
    } while (0);
}

#pragma mrak 获取设备地理信息
+(void)getDeviceGeographyInfoWithProductID:(NSString *)productID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/geography", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 获取设备地址
/**
 *  获取设备地址
 *  @param lat 经度
 *  @param lon 纬度
 */
+(void)getDeviceLocationWithLat:(NSNumber *)lat Lon:(NSNumber *)lon didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"https://maps.google.cn/maps/api/geocode/json?latlng=%@,%@&language=CN", lat, lon] withHeader:nil withContent:nil];
    } while (0);
}

#pragma mark
#pragma mark 分享部分

#pragma mark 1.1、email分享设备
+(void)shareDeviceInEmailWithDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken withShareAccount:(NSString *)account withExpire:(NSNumber *)expire withModel:(NSString *)model withAuthority:(NSString *)authority didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"device_id" : deviceID, @"expire" : expire, @"mode" : model, @"authority" : authority}];
        if (![model isEqualToString:@"qrcode"]) {
            [dic setObject:account forKey:@"user"];
        }
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device", Domain] withHeader:header withContent:dic];
    } while (0);
}

+(void)shareDeviceInEmailWithDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken withShareAccount:(NSString *)account withExpire:(NSNumber *)expire didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *dic = @{@"device_id" : deviceID, @"user" : account, @"expire" : expire, @"mode" : @"app"};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device", Domain] withHeader:header withContent:dic];
    } while (0);
}


#pragma mark 2、取消分享
+(void)cancelShareDeviceWithAccessToken:(NSString *)accessToken withInviteCode:(NSString *)inviteCode didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *dic = @{@"invite_code" : inviteCode};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device/cancel", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 3、接受分享
+(void)acceptShareWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *dic = @{@"invite_code" : inviteCode};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device/accept", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 4、拒绝分享
+(void)denyShareWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *header = [self getHeader:accessToken];
        NSDictionary *dic = @{@"invite_code" : inviteCode};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/share/device/deny", Domain] withHeader:header withContent:dic];
    } while (0);
}


#pragma mark 5、获取分享列表
+(void)getShareListWithAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = [self headerWithToken:accessToken];
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/share/device/list", Domain] withHeader:header withContent:nil];
    } while (0);
}


+ (NSDictionary *)headerWithToken:(NSString *)accessToken {
    NSDictionary *header = [NSDictionary dictionary];
    if (accessToken == nil) {
        header = @{@"Content-Type" : @"application/json", @"Access-Token" : @""};
    }else {
        header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
    }
    return header;
}

#pragma mark 6、删除分享记录
+(void)delShareRecordWithInviteCode:(NSString *)inviteCode withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeDelete withUrl:[NSString stringWithFormat:@"%@/v2/share/device/delete/%@", Domain, inviteCode] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 19、通过二维码订阅设备
+(void)subscribeDeviceByQRCodeWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withProductID:(NSString *)productID withEncryptMac:(NSString *)encryptMac didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *content = @{@"product_id" : productID, @"encrypt_mac" : encryptMac};
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/%@/qrcode_sub", Domain, userID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark
#pragma mark 错误信息
+(NSString *)getErrorInfoWithErrorCode:(NSInteger)errCode{
    NSString *errInfo;
    switch (errCode) {
        case 4001001:
            errInfo = @"请求数据字段验证不通过";
            break;
            //        case 4001001:
            //            errInfo = @"请求数据字段验证不通过";
            //            break;
            
        default:
            break;
    }
    return errInfo;
}


/*
 4001001
 请求数据字段验证不通过
 
 4001002
 请求数据必须字段不可为空
 
 4001003
 手机验证码不存在
 
 4001004
 手机验证码错误
 
 4001015
 未知的产品连接类型
 
 4001016
 已发布的产品不可删除
 
 4001017
 固件版本已存在
 
 4001018
 数据端点未知数据类型
 
 4001019
 数据端点索引已存在
 
 4001020
 已发布的数据端点不可删除
 
 4001021
 该产品下设备MAC地址已存在
 
 4001022
 不能删除已激活的设备
 
 4001023
 扩展属性Key为预留字段
 
 4001024
 设备扩展属性超过上限
 
 4001025
 新增已存在的扩展属性
 
 4001026
 更新不存在的扩展属性
 
 4001027
 属性字段名不合法
 
 4001028
 邮件验证码不存在
 
 4001029
 邮件验证码错误
 
 4001030
 用户状态不合法
 
 4001031
 用户手机尚未认证
 
 4001032
 用户邮箱尚未认证
 
 4001033
 用户已经订阅设备
 
 4001034
 用户没有订阅该设备
 
 4001035
 自动升级任务名称已存在
 
 4001036
 升级任务状态未知
 
 4001037
 已有相同的起始版本升级任务
 
 4001038
 设备激活失败
 
 4001039
 设备认证失败
 
 4001041
 订阅设备认证码错误
 
 4001042
 授权名称已存在
 
 4001043
 该告警规则名称已存在
 
 4001045
 数据变名称已存在
 
 4001046
 产品固件文件超过大小限制
 
 4001047
 APN密钥文件超过大小限制
 
 4001048
 APP的APN功能未启用
 
 4001049
 产品未允许用户注册设备
 
 4001050
 该类型的邮件模板已存在
 
 4001051
 邮件模板正文内容参数缺失
 
 4031001
 禁止访问
 
 4031002
 禁止访问，需要Access-Token
 
 4031003
 无效的Access-Token
 
 4031004
 需要企业的调用权限
 
 4031005
 需要企业管理员权限
 
 4031006
 需要数据操作权限
 
 4031007
 禁止访问私有数据
 
 4031008
 分享已经被取消
 
 4031009
 分享已经接受
 
 4031010
 用户没有订阅设备，不能执行操作
 
 
 4041001
 URL找不到
 
 4041002
 企业成员帐号不存在
 
 4041003
 企业成员不存在
 
 4041004
 激活的成员邮箱不存在
 
 4041005
 产品信息不存在
 
 4041006
 产品固件不存在
 
 4041007
 数据端点不存在
 
 4041008
 设备不存在
 
 4041009
 设备扩展属性不存在
 
 4041010
 企业不存在
 
 4041011
 用户不存在
 
 4041012
 用户扩展属性不存在
 
 4041013
 升级任务不存在
 
 4041014
 第三方身份授权不存在
 
 4041015
 告警规则不存在
 
 4041016
 数据表不存在
 
 4041017
 数据不存在
 
 4041018
 分享资源不存在
 
 4041019
 企业邮箱不存在
 
 4041020
 APP不存在
 
 4041021
 产品转发规则不存在
 
 4041022
 邮件模板不存在
 
 5031001
 服务端发生异常
 */


#pragma mark
#pragma mark 不公开接口

#pragma mark 注册设备
//+(void)registerDeviceWithUserID:(NSNumber *)userID withAccessToken:(NSString *)accessToken withDevice:(DeviceObject *)deviceObject didLoadData:(MyBlock)block{
//    do {
//        HttpRequest *req = [[HttpRequest alloc] init];
//        req.myBlock = block;
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
//
//        NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:deviceObject.product_id, @"product_id", deviceObject.mac, @"mac", nil];
//        if (deviceObject.name) [contentDic setObject:deviceObject.name forKey:@"name"];
//        if (deviceObject.access_key) [contentDic setObject:deviceObject.access_key forKey:@"access_key"];
//        if (deviceObject.mcu_mod) [contentDic setObject:deviceObject.mcu_mod forKey:@"mcu_mod"];
//        if (deviceObject.mcu_version) [contentDic setObject:deviceObject.mcu_version forKey:@"mcu_version"];
//        if (deviceObject.firmware_mod) [contentDic setObject:deviceObject.firmware_mod forKey:@"firmware_mod"];
//        if (deviceObject.firmware_version) [contentDic setObject:deviceObject.firmware_version forKey:@"firmware_version"];
//
//
//        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/register_device", Domain, userID] withHeader:header withContent:[NSDictionary dictionaryWithDictionary:contentDic]];
//
//    } while (0);
//}


#pragma mark
#pragma mark - 数据
-(void)httpRequestWithURL:(NSString *)urlStr withBodyStr:(NSString *)bodyStr{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    
    
    //访问的accessID
    NSString *accessID = [NSString stringWithFormat:@"%@",dataAccesskeyId];
    
    //X-ContentMD5
    NSString *md5Body= [[HttpRequest md5:bodyStr] uppercaseString];
    
    //X-Sign
    NSString *xsign=[NSString stringWithFormat:@"%@%@",dataSecretKey,md5Body];
    NSString *md5Xsin = [[HttpRequest md5:xsign] uppercaseString];
    
#pragma mark 注意要设置的属性
    //3.设置自定义字段
    [request addValue:md5Body forHTTPHeaderField:@"X-ContentMD5"];
    [request addValue:accessID forHTTPHeaderField:@"X-AccessId"];
    [request addValue:md5Xsin forHTTPHeaderField:@"X-Sign"];
    
    NSLog(@"field dict %@",[request allHTTPHeaderFields]);
    
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"text/plain;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}

+(void)putUserConfigWithAppID:(NSNumber *)appid withUserConfig:(NSDictionary *)userConfig didLoadData:(MyBlock)block{
    HttpRequest *req = [[HttpRequest alloc] init];
    req.myBlock = block;
    NSData *data = [NSJSONSerialization dataWithJSONObject:userConfig options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *bodyStr = [NSString stringWithFormat:@"{\"table\":\"leedarson_user\", \"id\":\"%@\",\"data\":%@}", appid, jsonStr];
    
    //访问的accessID
    NSString *accessID = [NSString stringWithFormat:@"%@",dataAccesskeyId];
    
    //X-ContentMD5
    NSString *md5Body= [[self md5:bodyStr] uppercaseString];
    
    //X-Sign
    NSString *xsign=[NSString stringWithFormat:@"%@%@",dataSecretKey,md5Body];
    NSString *md5Xsin = [[self md5:xsign] uppercaseString];
    
    
    //    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [req requestWithRequestType:RequestTypePOST withUrl:url_put_str withHeader:@{@"X-ContentMD5":md5Body,@"X-AccessId":accessID,@"X-Sign":md5Xsin,@"Content-Type":@"text/plain;charset=utf-8"} withContent:@{@"table":@"leedarson_user",@"id":appid,@"data":userConfig}];
    //    [req httpRequestWithURL:url_put_str withBodyStr:bodyStr];
}

+(void)getUserConfigWithAppID:(NSNumber *)appid didLoadData:(MyBlock)block{
    HttpRequest *req = [[HttpRequest alloc] init];
    req.myBlock = block;
    NSString *bodyStr = [NSString stringWithFormat:@"{\"table\":\"leedarson_user\",\"id\":\"%@\"}", appid];
    //访问的accessID
    NSString *accessID = [NSString stringWithFormat:@"%@",dataAccesskeyId];
    
    //X-ContentMD5
    NSString *md5Body= [[self md5:bodyStr] uppercaseString];
    
    //X-Sign
    NSString *xsign=[NSString stringWithFormat:@"%@%@",dataSecretKey,md5Body];
    NSString *md5Xsin = [[self md5:xsign] uppercaseString];
    //    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [req requestWithRequestType:RequestTypePOST withUrl:url_get_str withHeader:@{@"X-ContentMD5":md5Body,@"X-AccessId":accessID,@"X-Sign":md5Xsin,@"Content-Type":@"text/plain;charset=utf-8"} withContent:@{@"table":@"leedarson_user",@"id":appid}];
    //    [req httpRequestWithURL:url_get_str withBodyStr:bodyStr];
}

+(void)delUserConfigWithAppID:(NSNumber *)appid didLoadData:(MyBlock)block{
    HttpRequest *req = [[HttpRequest alloc] init];
    req.myBlock = block;
    NSString *bodyStr = [NSString stringWithFormat:@"{\"table\":\"leedarson_user\",\"id\":\"%@\"}", appid];
    [req httpRequestWithURL:url_del_str withBodyStr:bodyStr];
}

//#pragma mark
//#pragma mark NSURLConnectionDelegate
//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    _httpReceiveData.length = 0;;
//}
//
//-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    if (_httpReceiveData) {
//        [_httpReceiveData appendData:data];
//    }
//}
//
//-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    if (_httpReceiveData.length) {
//        //        [self printByteData:_httpReceiveData];
//        NSError *err = nil;
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_httpReceiveData options:NSJSONReadingMutableLeaves error:&err];
//
//        NSLog(@"length ==%lu",(unsigned long)_httpReceiveData.length);
//        if (!err) {
//            if (dic) {
//                if (_myDataBlock != nil) {
//                    _myDataBlock(dic);
//                }
//            }
//        }else{
//            NSLog(@"%@",[err localizedDescription]);
//        }
//
//    }
//
//}
//
//-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//
//    NSLog(@"error happened = %@",[error localizedDescription]);
//    if (_myDataBlock != nil) {
//        _myDataBlock(@{@"status" : @(error.code), @"msg" : error.localizedDescription});
//    }
//
//}

#pragma mark
#pragma mark 固件升级新接口

#pragma mark 获取固件版本
+(void)getVersionWithDeviceID:(NSString *)device_id withProduct_id:(NSString *)product_id withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"product_id" : product_id, @"device_id" : device_id};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/upgrade/device/newest_version", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark 升级固件
+(void)upgradeWithDeviceID:(NSString *)device_id withProduct_id:(NSString *)product_id withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *dic = @{@"product_id" : product_id, @"device_id" : device_id};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/upgrade/device", Domain] withHeader:header withContent:dic];
    } while (0);
}

#pragma mark - 修改用户信息
+(void)saveUserInfoWithUserId:(NSNumber *)userId nickName:(NSString *)nickname remark:(NSString *)remark tags:(NSString *)tags avatarUrl:(NSString *)avatarUrl withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:nickname forKey:@"nickname"];
        
        if (remark) {
            [dic setObject:remark forKey:@"remark"];
        }
        
        if (tags) {
            [dic setObject:tags forKey:@"tags"];
        }
        
        if (avatarUrl) {
            [dic setObject:avatarUrl forKey:@"avatar"];
        }
        
        
        [req requestWithRequestType:RequestTypePUT withUrl:[NSString stringWithFormat:@"%@/v2/user/%@", Domain,userId] withHeader:header withContent:dic];
    } while (0);
}


#pragma mark - 上传用户头像
+(void)saveUserInfoWithImageData:(NSData *)imageData withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};

        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/avatar/upload?avatarType=jpg", Domain] withHeader:header withContent:imageData];
    } while (0);
}

#pragma mark
#pragma mark 应用身份接口文档
#pragma mark 1. 申请应用接口调用凭证
+(void)requestCorpAccessTokenWithAccessToken:(NSString *)accessToken withAppID:(NSString *)appID didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *content = @{@"app_id" : appID};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/plugin/apply_token", Domain] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 
#pragma mark 用户反馈接口
#pragma mark 1、添加用户反馈
+(void)addFeedBackWithAppID:(NSString *)appID withAccessToken:(NSString *)accessToken withContent:(NSDictionary *)content didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/feedback/%@/api/feedback/save",plugInNnit,appID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark - 添加用户反馈成功后再次调用的接口
/**
 *  最后由这个接口判断用户反馈是否成功
 */
+(void)feedBackRecordWithAppID:(NSString *)appID withAccessToken:(NSString *)accessToken withContent:(NSDictionary *)content didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/feedback/%@/api/feedback_record/save",plugInNnit,appID] withHeader:header withContent:content];
    } while (0);
}


#pragma mark
#pragma mark 虚拟设备功能接口
+(void)getVirtualDeviceWithProductID:(NSString *)productID withDeviceID:(NSNumber *)deviceID withAccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/v_device/%@", Domain, productID, deviceID] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark
#pragma mark xfile 接口
+(void)uploadFileWithAccessToken:(NSString *)accessToken withFileType:(NSString *)type withFileData:(NSData *)data didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        
        NSDictionary *urlContentDic = @{@"type" : type, @"public_read" : @"true"};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:urlContentDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [jsonData base64EncodedStringWithOptions:0];
        
        NSDictionary *header = @{@"Access-Token" : accessToken};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/xfile/upload?content=%@", Domain, jsonString] withHeader:header withContent:data];
        
    } while (0);
}

#pragma mark
#pragma mark 获取设备快照
/*
 * param 获取设备快照
 */
+(void)getDevicesnapshotWithOffset:(NSNumber *)offset limit:(NSNumber *)limit DateDic:(NSDictionary *)dateDic ProductID:(NSString *)productID  DeviceID:(NSNumber *)deviceID AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *content = @{@"offset" : offset ,@"limit" : limit ,@"date" : dateDic};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/product/%@/device/%@/snapshot", Domain, productID, deviceID] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 获取室外pm2.5
/*
 * param 获取室外pm2.5
 */
+(void)getDeviceOutDoorPm25WithOffset:(NSNumber *)offset limit:(NSNumber *)limit address:(NSString *)address startDate:(NSString *)startDate currentDate:(NSString *)currentDate AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        
        
//        @{"filter":@[]};
        
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *content = @{@"limit":limit,@"offset":offset,@"query":@{@"location.name":@{@"$regex":address},@"update_time":@{@"$gte":@{@"@date":startDate},@"$lte":@{@"@date":currentDate}}}};
        
//  @{@"filter":@[],@"limit":limit,@"offset":offset,@"order":@{},@"query":@{@"location.name":@{@"$regex":@"广州"},@"update_time":@{@"$gte":@{@"@date":@"2016-09-07T23:59:59"},@"$lte":@{@"@date":@"2016-09-08T23:59:59"}}}};
        
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/airQuality/%@/api/airQuality/list", plugInNnit,kAppId] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 获取推送告警
/**
 *  获取推送消息
 *  @param type 消息类型  1通知与预警  2广播消息
 *  @param notify_type 通知类型 1通知 2告警
 */
+(void)getWarnningListWithOffset:(NSNumber *)offset limit:(NSNumber *)limit type:(NSNumber *)type notify_type:(NSNumber *)notify_type userId:(NSNumber *)userId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
   
//        NSDictionary *content = @{@"offset" : offset ,@"limit" : limit ,@"query":@{@"notify_type":@{@"$in":@[notify_type]},@"type":@{@"$in":@[type]}} };
        NSDictionary *content = @{@"offset" : offset ,@"limit" : limit};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/messages", Domain, userId] withHeader:header withContent:content];
    } while (0);
}

#pragma mark 获取推送消息
+(void)getMessageListWithOffset:(NSNumber *)offset limit:(NSNumber *)limit type:(NSNumber *)type notify_type:(NSNumber *)notify_type userId:(NSNumber *)userId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
    HttpRequest *req = [[HttpRequest alloc] init];
    req.myBlock = block;
    NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
    
    
    NSDictionary *content = @{@"offset" : offset ,@"limit" : limit ,@"query":@{},@"order":@{}};
    
    [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/messages/broadcast", Domain, userId] withHeader:header withContent:content];
} while (0);
}

#pragma mark 删除推送消息
+ (void)deleteMessageWithUserId:(NSNumber *)userId AccessToken:(NSString *)accessToken messageID:(NSString *)messageId didLoadData:(MyBlock)block {
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSMutableArray *content = [NSMutableArray arrayWithObject:messageId];
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/message_delete", Domain, userId] withHeader:header withContent:content];
    } while (0);
}


#pragma mark 获取使用须知
+ (void)getExplainWithOffset:(NSNumber *)offset limit:(NSNumber *)limit appId:(NSString *)appId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block {
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};

        
//        NSDictionary *content = @{@"offset":offset, @"limit":limit, @"query":@{@"field.filed1":@{@"$in":@[@"1"]},@"field2":@{@"$lt":@"2"}}, @"order":@{@"field.filed1":@(1), @"filed2":@(-1)}, @"filter":@[@"list"]};
        
        NSDictionary *content = @{@"offset":offset, @"limit":limit, @"query":@{}, @"order":@{}, @"filter":@[]};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/contents/%@/api/article/list", plugInNnit, appId] withHeader:header withContent:content];
    } while (0);
    
}

#pragma mark 获取所有设备信息
+(void)getDeviceInfoWithUserID:(NSNumber *)userId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        [req requestWithRequestType:RequestTypeGet withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/subscribe/devices", Domain,userId] withHeader:header withContent:nil];
    } while (0);
}

#pragma mark 获取设备维保信息
+(void)getDeviceRepairHistoryWithDeviceSn:(NSString *)deviceSn AppID:(NSString *)appId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *content = @{@"offset" : @(0) ,@"limit" : @(10000) ,@"query":@{@"product_sn":@{@"$in":@[deviceSn]}} };
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/warranty/%@/api/warranty/list", plugInNnit,appId] withHeader:header withContent:content];
        
    } while (0);
}

#pragma mark - 删除体验设备
/**
 *  state = 0,代表删除体验设备  1保留
 */
+(void)deleteExperienceDeviceWithUserId:(NSNumber *)userId state:(NSNumber *)state AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block {
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        NSDictionary *temp = @{@"isExperience" : state};
        NSDictionary *content = @{@"eawadaProperty" : temp};
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/v2/user/%@/property", Domain,userId] withHeader:header withContent:content];
        
    } while (0);
}


#pragma mark - 把分享报告的链接转短
+(void)longUrlTransformationShortUrlWith:(NSString *)longUrl AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block {
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        
//        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
//        NSDictionary *content = @{@"url" : longUrl};
        
        [req httpRequestWithLongUrl:longUrl];
        
    } while (0);
}

- (void)httpRequestWithLongUrl:(NSString *)longUrl {

    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:longUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (error) {
            if (_myBlock) _myBlock(nil, error);
        }else{
            
            
            
            NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
            NSLog(@"%ld %@", (long)[r statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[r statusCode]]);
            NSInteger statusCode = [r statusCode];
            if (statusCode != 200) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSError *err;
                if (result) {
                    err = [NSError errorWithDomain:Domain code:[[[result objectForKey:@"error"] objectForKey:@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey : [[result objectForKey:@"error"] objectForKey:@"msg"]}];
                }else{
                    err = [NSError errorWithDomain:Domain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"unknow err"}];
                }
                _myBlock(nil, err);
            }else{
                NSError *err;
                NSString *result = [NSString string];
                if (data.length) {
                    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }else{
                    result = @"";
                }
                
                NSLog(@"result=%@",result);
                if (err) {
                    if (_myBlock) _myBlock(nil, err);
                }else{
                    if (_myBlock) _myBlock(result, nil);
                }
            }
        }
        
    }];
    [task resume];

}


#pragma mark 获取设备维保详情
+(void)getDeviceRepairDetailWithRepairId:(NSString *)repairId AppID:(NSString *)appId AccessToken:(NSString *)accessToken didLoadData:(MyBlock)block{
    do {
        HttpRequest *req = [[HttpRequest alloc] init];
        req.myBlock = block;
        
        NSDictionary *header = @{@"Content-Type" : @"application/json", @"Access-Token" : accessToken};
        
        NSDictionary *content = @{@"offset" : @(0) ,@"limit" : @(1) ,@"query":@{@"_id":@{@"$in":@[repairId]}} };
        
        [req requestWithRequestType:RequestTypePOST withUrl:[NSString stringWithFormat:@"%@/module/warranty/%@/api/repair_details/list", plugInNnit,appId] withHeader:header withContent:content];
        
    } while (0);
}


#pragma mark
#pragma mark 辅助工具
+(BOOL)validateEmail:(NSString *)email{
    
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:email];
    
}

+(BOOL)validatePhone:(NSString *)phone{
    
    NSString *regex = @"^((1[0-9][0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:phone];
    
}

-(void)printByteData:(NSData *)data{
    
    char temp[data.length];
    [data getBytes:temp range:NSMakeRange(0, data.length)];
    
    for (int i=0; i<data.length; i++) {
        NSLog(@"%d ->%02x",i,temp[i]);
    }
    
}

//md5运算
+ (NSString*)md5:(NSString*)input{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

-(void)dealloc{
    NSLog(@"%s", __func__);
}

@end