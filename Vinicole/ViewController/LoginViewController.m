//
//  LoginViewController.m
//  Warmer
//
//  Created by apple on 2016/11/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LoginViewController.h"

#import "BaseNavigationController.h"
#import "RegisterViewController.h"
#import "ForgetPwdViewController.h"

#import "XLinkExportObject.h"
#import "NSTools.h"
#import "MBProgressHUD.h"
#import "UserModel.h"
#import "DataManage.h"
#import "HttpRequest.h"
#import "DeviceModel.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    NSThread    *_loginThread;
    BOOL        _isLoginThreadRun;
    MBProgressHUD *hud;
    
    UIView *chooseView;
}

@property (weak, nonatomic) IBOutlet UITextField *accountFeild;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    [self addNotification];
}

-(void)setUI{
//    self.accountFeild.placeholder = NSLocalStr(@"请输入手机号码");
    self.accountFeild.rightViewMode = UITextFieldViewModeAlways;
    
//    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    cleanBtn.frame = CGRectMake(0, 0, 24, 24);
//    [cleanBtn setImage:[UIImage imageNamed:@"edit_no_reset"] forState:UIControlStateNormal];
//    [cleanBtn addTarget:self action:@selector(cleanAccount:) forControlEvents:UIControlEventTouchUpInside];
//    self.accountFeild.rightView = cleanBtn;
    self.accountFeild.keyboardType = UIKeyboardTypeDefault;
    self.accountFeild.returnKeyType = UIReturnKeyNext;
    self.accountFeild.clearButtonMode = UITextFieldViewModeAlways;
    self.accountFeild.delegate = self;
    
    self.passwordField.rightViewMode = UITextFieldViewModeAlways;
    UIButton *showPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showPasswordBtn.frame = CGRectMake(0, 0, 24, 24);
    [showPasswordBtn setImage:[UIImage imageNamed:@"edit_no_visibility"] forState:UIControlStateNormal];
    [showPasswordBtn setImage:[UIImage imageNamed:@"edit_visibility"] forState:UIControlStateSelected];
    [showPasswordBtn addTarget:self action:@selector(showPwd:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordField.rightView = showPasswordBtn;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    self.passwordField.secureTextEntry = YES;
    
    NSString *lastLoginPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoginAccount"];
    self.accountFeild.text = lastLoginPhone;
    
    NSString *lastLoginPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoginPwd"];
    self.passwordField.text = lastLoginPwd;
    
}

#pragma mark - AutoLogin
-(void)AutoLogin{
    
    [self addNotification];
    
    [self startAutoLoginThread];
    
    if (!DATASOURCE.user.email) {
        
        NSString *lastLoginAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoginAccount"];
        if (lastLoginAccount.length) {
            
            UserModel *userModel;
            
            NSArray *userList = [[NSUserDefaults standardUserDefaults] objectForKey:@"userList"];
            
            //email == 账号 邮箱或者手机号码
            for (NSDictionary *userDic in userList) {
                if ([lastLoginAccount isEqualToString:[userDic objectForKey:@"email"]]) {
                    userModel = [[UserModel alloc] initWithDictionary:userDic];
                    break;
                }
            }
            DATASOURCE.user = userModel;
            [[DataManage share] start];
            
            [self performSelector:@selector(loginWithDic:) onThread:_loginThread withObject:@{
                                                                                              @"phone" : DATASOURCE.user.email,
                                                                                              @"password" : DATASOURCE.user.password,
                                                                                              @"isBackgroundLogin" : @(1)} waitUntilDone:NO];
        }
        
    }else{
        
        [self performSelector:@selector(loginWithDic:) onThread:_loginThread withObject:@{
                                                                                          @"phone" : DATASOURCE.user.email,
                                                                                          @"password" : DATASOURCE.user.password,
                                                                                          @"isBackgroundLogin" : @(1)} waitUntilDone:NO];
    }
}

#pragma mark - Notification

-(void)addNotification{
    
    //获取分享设备 添加别人分享的设备后post此通知 更新deviceList
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceListIsBackground:) name:kGetShareDevice object:nil];
    
    //平台登陆通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin:) name:kOnLogin object:nil];
    
    //退出登陆或者被踢下线 此通知执行logout
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:kLogout object:nil];

}

-(void)onLogin:(NSNotification *)noti{
    int result = [noti.object intValue];
    
    NSLog(@"onlogin---%d",result);
    if (result == 0) {
        [[DataManage share] tryConnect];
    }else if (result == CODE_SERVER_KICK_DISCONNECT  || result == CODE_STATE_KICK_OFFLINE) {
        //|| result == CODE_STATE_OFFLINE
//        [self kickOut];
        
    }
}

-(void)kickOut{
    [[XLinkExportObject sharedObject] logout];
    [[DataManage share] stop];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        BaseNavigationController  *vc = [storyboard instantiateViewControllerWithIdentifier:@"BaseNavigationController"];
        
        [UIApplication sharedApplication].keyWindow.rootViewController =  vc;
        
        UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalStr(@"该帐号已在另一个设备上登录") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalStr(@"确定") style:UIAlertActionStyleDefault handler:nil];
        
        [alc addAction:okAction];
        
        [vc presentViewController:alc animated:YES completion:nil];
    });
    
    [self stopAutoLoginThread];
    DATASOURCE.user = nil;
    
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"CODE_SERVER_KICK_DISCONNECT" object:nil];
    
    return;
}

-(void)logOut{
    
//    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    // 关闭推送服务
    // 正式平台
//    [HttpRequest disableAPNServiceWithUserID:DATASOURCE.user.userId withAppID:@"2e0fa2af4b46ac00" withAccessToken:deviceToken didLoadData:^(id result, NSError *err) {
//        
//    }];

    
    [[XLinkExportObject sharedObject] logout];
    [[DataManage share]stop];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        BaseNavigationController  *vc = [storyboard instantiateViewControllerWithIdentifier:@"BaseNavigationController"];
        [UIApplication sharedApplication].keyWindow.rootViewController =  vc;
    });
    
    [self stopAutoLoginThread];
    
    DATASOURCE.user = nil;
    
    return;
}

#pragma mark - 登录
- (IBAction)LoginBtnAction:(id)sender {
    NSLog(@"登录");
    [self checkTextfield];
}

-(void)checkTextfield{
    
    if (self.accountFeild.text.length == 0) {
        [self showWarningAlert:@"请输入手机号码"];
        return;
    }
    
    if (self.passwordField.text.length == 0) {
        
        [self showWarningAlert:@"请输入密码"];
        return;
    }
    
    if (![NSTools validatePhone:self.accountFeild.text] && ![NSTools validateEmail:self.accountFeild.text]) {
        
        [self showWarningAlert:@"请输入正确的手机号码或邮箱"];
        return;
    }
    
    if (self.passwordField.text.length >= 17 || self.passwordField.text.length<6) {
        [self showWarningAlert:@"请输入6-16位的密码"];
        return;
    }
    
    [self checkUserData];
}

-(void)checkUserData{
    
    NSArray *userList = [[NSUserDefaults standardUserDefaults] objectForKey:@"userList"];
    
    UserModel *userModel;
    
    [self startAutoLoginThread];
    
    for (NSDictionary *userDic in userList) {
        if ([self.accountFeild.text isEqualToString:[userDic objectForKey:@"email"]]) {
            userModel  = [[UserModel alloc] initWithDictionary:userDic];
            break;
        }
    }
    
    if (userModel) {
        DATASOURCE.user = userModel;
        if ([userModel.password isEqualToString:self.passwordField.text]) {
            [self loginInBackGround];
        }else{
            [self loginWithPhone:self.accountFeild.text Pwd:self.passwordField.text isBackground:NO];
        }
    }else{
        [self loginWithPhone:self.accountFeild.text Pwd:self.passwordField.text isBackground:NO];
    }
    
}

-(void)loginInBackGround{
    [self goIndexController];
    
    [self loginWithPhone:DATASOURCE.user.email Pwd:DATASOURCE.user.password isBackground:YES];
}

-(void)goIndexController{

    UIStoryboard *storyboard= [UIStoryboard storyboardWithName:@"Index" bundle:nil];;

    BaseNavigationController *vc =[storyboard instantiateViewControllerWithIdentifier:@"BaseNavigationController"];
    [self presentViewController:vc animated:NO completion:nil];
}

-(void)delayCallLoginWithDic:(NSDictionary *)dic{
    NSNumber *delay = dic[@"delay"];
    [self performSelector:@selector(loginWithDic:) withObject:dic afterDelay:delay.doubleValue];
}

-(void)loginWithDic:(NSDictionary *)dic{
    NSString *phone = dic[@"phone"];
    NSString *password = dic[@"password"];
    NSNumber *isBackground = dic[@"isBackgroundLogin"];
    [self loginWithPhone:phone Pwd:password isBackground:isBackground.boolValue];
}

-(void)loginWithPhone:(NSString *)phone Pwd:(NSString *)pwd isBackground:(BOOL)isBackground{
    
    if (!isBackground) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    }
    
    [HttpRequest authWithAccount:phone withPassword:pwd didLoadData:^(id result, NSError *err) {
        if (!err) {
            
            NSDictionary *dic = result;
            
            if (!DATASOURCE.user.email) {
                [[XLinkExportObject sharedObject] loginWithAppID:[[dic objectForKey:@"user_id"] intValue] andAuthStr:[dic objectForKey:@"authorize"]];
                
                DATASOURCE.user = [[UserModel alloc]initWithEmail:phone andPassword:pwd];
            }else{
                [[XLinkExportObject sharedObject]loginWithAppID:DATASOURCE.user.userId.intValue andAuthStr:DATASOURCE.user.authorize];
            }
            
            DATASOURCE.user.password = pwd;
            DATASOURCE.user.accessToken = dic[@"access_token"];
            DATASOURCE.user.userId = dic[@"user_id"];
            DATASOURCE.user.authorize = dic[@"authorize"];
            
            [[NSUserDefaults standardUserDefaults] setObject:dic[@"user_id"] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAutoLogin"];
            [[NSUserDefaults standardUserDefaults] setObject:DATASOURCE.user.email forKey:@"lastLoginAccount"];
            [[NSUserDefaults standardUserDefaults] setObject:DATASOURCE.user.password forKey:@"lastLoginPwd"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSArray *willDelDeviceModels = DATASOURCE.user.deviceList;
            for (DeviceModel *deviceModel in willDelDeviceModels) {
                [HttpRequest unsubscribeDeviceWithUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken withDeviceID:@(deviceModel.device.deviceID) didLoadData:^(id result, NSError *err) {
                    if (!err) {
                        [DATASOURCE.user.willDelDeviceList removeObject:deviceModel];
                        [DATASOURCE saveUserWithIsUpload:NO];
                    }else if (err.code == 4001034){
                        //用户没有订阅此设备(已删除)
                        [DATASOURCE.user.willDelDeviceList removeObject:deviceModel];
                        [DATASOURCE saveUserWithIsUpload:NO];
                    }
                }];
            }
            
            [[DataManage share] start];
            
            NSMutableArray *tempArray = DATASOURCE.user.deviceList;
            
            [DATASOURCE saveUserWithIsUpload:NO];
            
            if (isBackground) {
                [self performSelector:@selector(getUserInfoWithDic:) onThread:_loginThread withObject:@{
                                                                                                        @"isBackground" : @(1)
                                                                                                        } waitUntilDone:NO];
                [self performSelector:@selector(getUserPropertyWithDic:) onThread:_loginThread withObject:@{
                                                                                                            @"isBackground" : @(1)
                                                                                                            } waitUntilDone:NO];
                [self performSelector:@selector(getDeviceListWithDic:) onThread:_loginThread withObject:@{
                                                                                                          @"isBackground" : @(1)
                                                                                                          } waitUntilDone:NO];
            }else{
                [self performSelector:@selector(getUserInfoWithDic:) onThread:_loginThread withObject:@{
                                                                                                        @"isBackground" : @(0)
                                                                                                        } waitUntilDone:NO];
            }
            
            [self performSelector:@selector(delayCallLoginWithDic:) onThread:_loginThread withObject:@{
                                                                                                       @"delay" : @(30 * 60),
                                                                                                       @"phone" : phone,
                                                                                                       @"password" : pwd,
                                                                                                       @"isBackgroundLogin" : @(1)
                                                                                                       
                                                                                                       }
                    waitUntilDone:NO];
            
        }else{
            if (!isBackground) {
                
                
                [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(showLoginFailErr:) withObject:err waitUntilDone:NO];
                
            }else{
                
                if (err.code == 4001007) {
                    
                    DATASOURCE.user.password = nil;
                    [DATASOURCE saveUserWithIsUpload:NO];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAutoLogin"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                        LoginViewController  *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                        
                        [UIApplication sharedApplication].keyWindow.rootViewController =  vc;
                        
                        UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalStr(@"密码错误!") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalStr(@"确定") style:UIAlertActionStyleDefault handler:nil];
                        
                        [alc addAction:okAction];
                        [vc presentViewController:alc animated:YES completion:nil];
                    });
                    
                    [self stopAutoLoginThread];
                    
                    DATASOURCE.user = nil;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CODE_SERVER_KICK_DISCONNECT" object:nil];
                    
                    return ;
                }else if (err.code == -1009) {
                    
                    NSLog(@"88888=%@",[NSThread currentThread]);
                    
                    [self performSelectorOnMainThread:@selector(CheckNetwork) withObject:nil waitUntilDone:NO];
                    return;
                    
                }
                
                [self performSelector:@selector(delayCallLoginWithDic:) onThread:_loginThread withObject:@{
                                                                                                           @"delay" : @(20),
                                                                                                           @"phone" : phone,
                                                                                                           @"password" :pwd,
                                                                                                           @"isBackgroundLogin" : @(1)
                                                                                                           } waitUntilDone:NO];
            }
        }
    }];
}

#pragma mark getUserInfo
-(void)delayCallGetUserInfoWithDic:(NSDictionary *)dic{
    NSNumber *delay = dic[@"delay"];
    [self performSelector:@selector(getUserInfoWithDic:) withObject:dic afterDelay:delay.doubleValue];
}

-(void)getUserInfoWithDic:(NSDictionary *)dic{
    NSNumber *isBackground = dic[@"isBackground"];
    [self getUserInfoIsBackground:isBackground.boolValue];
}


- (void)getUserInfoIsBackground:(BOOL)isBackground{
    
    [HttpRequest getUserInfoWithUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSDictionary *dic = result;
            DATASOURCE.user.nickName = dic[@"nickname"];
//            DATASOURCE.user.avatarUrl = dic[@"avatar"];
            [DATASOURCE saveUserWithIsUpload:NO];
            
            if (!isBackground) {
                [self performSelector:@selector(getUserPropertyWithDic:) onThread:_loginThread withObject:@{
                                                                                                            @"isBackground" : @(0)
                                                                                                            } waitUntilDone:NO];
            }
        }else{
            if (!isBackground) {
                [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(showLoginFailErr:) withObject:err waitUntilDone:NO];
            }else{
                [self performSelector:@selector(delayCallGetUserInfoWithDic:) onThread:_loginThread withObject:@{
                                                                                                                 @"delay" : @(20),
                                                                                                                 @"isBackground" : @(1)
                                                                                                                 } waitUntilDone:NO];
            }
        }
    }];
}

#pragma mark getUserProperty
-(void)delayCallGetUserPropertyWithDic:(NSDictionary *)dic{
    NSNumber *delay = dic[@"delay"];
    [self performSelector:@selector(getUserPropertyWithDic:) withObject:dic afterDelay:delay.doubleValue];
}

-(void)getUserPropertyWithDic:(NSDictionary *)dic{
    NSNumber *isBackground = dic[@"isBackground"];
    [self getUserPropertyIsBackground:isBackground.boolValue];
}

-(void)getUserPropertyIsBackground:(BOOL)isBackground{
    [HttpRequest getUserPropertyWithUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken didLoadData:^(id result, NSError *err) {
        if (!err) {
            NSLog(@"%@", result);
            
            [DATASOURCE.user setProperty:[result objectForKey:@"Property"]];

//            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
//            if (deviceToken) {
//                if (DATASOURCE.userModel.pushEnable.boolValue) {
//                    // 开启推送服务
//                    // 正式平台
//                    [HttpRequest registerAPNServiceWithUserID:DATASOURCE.userModel.userId withAppID:@"2e0fa2af4b46ac00" withDeviceToken:deviceToken withAccessToken:DATASOURCE.userModel.accessToken didLoadData:^(id result, NSError *err) {
//                        
//                    }];
//                    
//                    // 调试
//                    [HttpRequest registerAPNServiceWithUserID:DATASOURCE.userModel.userId withAppID:@"2e0fa6af9d4c0200" withDeviceToken:deviceToken withAccessToken:DATASOURCE.userModel.accessToken didLoadData:^(id result, NSError *err) {
//                        
//                    }];
//                    
//                    
//                }else{
//                    // 关闭推送服务
//                    [HttpRequest disableAPNServiceWithUserID:DATASOURCE.userModel.userId withAppID:@"2e0fa2af4b46ac00" withAccessToken:deviceToken didLoadData:^(id result, NSError *err) {
//                        
//                    }];
//                    
//                    [HttpRequest disableAPNServiceWithUserID:DATASOURCE.userModel.userId withAppID:@"2e0fa6af9d4c0200" withAccessToken:deviceToken didLoadData:^(id result, NSError *err) {
//                        
//                    }];
//                    
//                }
//            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDateUserProperty" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDeviceList object:nil];
            
            if (!isBackground) {
                [self performSelector:@selector(getDeviceListWithDic:) onThread:_loginThread withObject:@{
                                                                                                          @"isBackground" : @(0)
                                                                                                          } waitUntilDone:NO];
            }
            
        }else{
            if (err.code == 4041011) {
                //新用户，没有设置过property
                [self setUserProperty];
            }else if (!isBackground) {
                [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(showLoginFailErr:) withObject:err waitUntilDone:NO];
            }else{
                [self performSelector:@selector(delayCallGetUserPropertyWithDic:) onThread:_loginThread withObject:@{
                                                                                                                     @"delay" : @(20),
                                                                                                                     @"isBackground" : @(1)
                                                                                                                     } waitUntilDone:NO];
            }
        }
    }];
}

-(void)setUserProperty{
    
    DATASOURCE.user.uploadTime = @([[NSDate date] timeIntervalSince1970]).stringValue;
    
    NSDictionary *userDictionary = [DATASOURCE.user getDictionary];
    
    NSDictionary *PropertyDic = @{@"Property" : [userDictionary objectForKey:@"Property"]};
    //上传
    [HttpRequest setUserPropertyDictionary:PropertyDic withUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken didLoadData:^(id result, NSError *err) {
        if (!err) {
            [self performSelector:@selector(getDeviceListWithDic:) onThread:_loginThread withObject:@{
                                                                                                      @"isBackground" : @(0)
                                                                                                      } waitUntilDone:NO];
        }else{
            [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(showLoginFailErr:) withObject:err waitUntilDone:NO];
        }
    }];
}

#pragma mark getDeviceList
-(void)delayCallGetDeviceListWithDic:(NSDictionary *)dic{
    NSNumber *delay = dic[@"delay"];
    [self performSelector:@selector(getDeviceListWithDic:) withObject:dic afterDelay:delay.doubleValue];
}

-(void)getDeviceListWithDic:(NSDictionary *)dic{
    NSNumber *isBackground = dic[@"isBackground"];
    [self getDeviceListIsBackground:isBackground.boolValue];
}

-(void)getDeviceListIsBackground:(BOOL)isBackground{
    
    [HttpRequest getDeviceListWithUserID:DATASOURCE.user.userId withAccessToken:DATASOURCE.user.accessToken withVersion:@(0) didLoadData:^(id result, NSError *err) {
        if (!err) {
           // 暂时不同步云端设备
//            NSArray *deviceList = [result objectForKey:@"list"];
//            
//            NSLog(@"count == %zd",deviceList.count);
//            NSLog(@"%@", deviceList);
//            //订阅本地未订阅的设备
//            NSArray *deviceModels = DATASOURCE.user.deviceList;
//            
//            for (NSInteger i = deviceModels.count - 1; i >= 0; i--) {
//                DeviceModel *deviceModel = deviceModels[i];
//  
//                BOOL isAllHas = NO;
//                NSString *mac = [deviceModel.device getMacAddressSimple];
//                for (NSDictionary *dic in deviceList) {     //如果云端也没有这个设备的话，去订阅设备
//                    if ([mac isEqualToString:[dic objectForKey:@"mac"]]) {
//
//                        isAllHas = YES;
//                        
//                        deviceModel.role = [dic[@"role"] intValue];
//                        deviceModel.source = [dic[@"source"] intValue];
//                        
////                        if ([dic.allKeys containsObject:@"role"]) {
////                            if ([dic[@"role"] intValue] == 0) {
////                                deviceModel.authority = @"RW";
////                                
////                            }
////                        }
//                        
////                        if ([dic.allKeys containsObject:@"authority"]) {
////                            deviceModel.authority = [dic objectForKey:@"authority"]; //R RW
////                        }
////                        
////                        if ([dic.allKeys containsObject:@"sn"]) {
////                            deviceModel.device_Sn = [dic objectForKey:@"sn"];
////                        }
//                        
//                        break;
//                    }
//                }
//                
//                if (!isAllHas) {
//                    if (deviceModel.isSubscription.boolValue) {
//
////                        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteDevice object:deviceModel];
//                    }else{
//                        [[XLinkExportObject sharedObject] subscribeDevice:deviceModel.device andAuthKey:deviceModel.device.accessKey andFlag:YES];
//                    }
//                    
//                }else{
//                    deviceModel.isSubscription = @(1);      //云端有此设备，标识为已订阅
//                }
//            }
//            
//            //            往本地添加云端存在本地没有的设备
//            for (NSDictionary *deviceDic in deviceList) {   //遍历云端设备
//                NSString *mac = [deviceDic objectForKey:@"mac"];
//                DeviceModel *deviceModel = [DATASOURCE getDeviceModelWithMac:mac];
//                if (!deviceModel) {
//                    DeviceModel *willDelDeviceModel = [DATASOURCE getWillDelDeviceModelWithMac:mac];
//                    if (!willDelDeviceModel) {
//                        DeviceEntity *device = [[DeviceEntity alloc] initWithMac:mac andProductID:[deviceDic objectForKey:@"product_id"]];
//                        device.accessKey = [deviceDic objectForKey:@"access_key"];
//                        device.version = [[deviceDic objectForKey:@"firmware_version"] intValue];
//                        device.deviceID = [[deviceDic objectForKey:@"id"] intValue];
//                        
//                        
////                        if ([deviceDic[@"product_id"] isEqualToString:CarCleanerPid]) {
////                            deviceModel = [[ProtableAirCleanerDeviceModel alloc] init];
////                        }else {
////                            deviceModel = [[AirCleanerDeviceModel alloc] init];
////                        }
//                        
//                        deviceModel = [[DeviceModel alloc] init];
//                        
//                        deviceModel.device = device;
//                        deviceModel.isSubscription = @(1);
//                        
//                        if ([deviceDic.allKeys containsObject:@"role"]) {
//                            deviceModel.role = [deviceDic[@"role"] intValue];
////                            if ([deviceDic[@"role"] intValue] == 0) {
////                                deviceModel.authority = @"RW";
////                            }
//                        }
//                        
//                        deviceModel.source = [deviceDic[@"source"] intValue];
//                        
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kAddDevice object:deviceModel];
//                    }
//                }else{
//                    deviceModel.device.version = 3;//[[deviceDic objectForKey:@"firmware_version"] intValue];
//                }
//            }
//            
//            [DATASOURCE saveDeviceModelWithMac:nil withIsUpload:NO];
            
            
            if (!isBackground) {
                [self performSelectorOnMainThread:@selector(goIndexController) withObject:nil waitUntilDone:YES];
            }
            
            [self performSelector:@selector(getDeviceInfoWithDic:) onThread:_loginThread withObject:@{
                                                                                                      @"isBackground" : @(0)
                                                                                                      } waitUntilDone:NO];
            
        }else{
            if (!isBackground) {
                [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(showLoginFailErr:) withObject:err waitUntilDone:NO];
            }else{
                [self performSelector:@selector(delayCallGetDeviceListWithDic:) onThread:_loginThread withObject:@{
                                                                                                                   @"delay" : @(20),
                                                                                                                   @"isBackground" : @(1)
                                                                                                                   } waitUntilDone:NO];
            }
        }
    }];
}

#pragma mark getDeviceProperty
-(void)delayCallGetDeviceInfoWithDic:(NSDictionary *)dic{
    NSNumber *delay = dic[@"delay"];
    [self performSelector:@selector(getDeviceInfoWithDic:) withObject:dic afterDelay:delay.doubleValue];
}

-(void)getDeviceInfoWithDic:(NSDictionary *)dic{
    NSNumber *isBackground = dic[@"isBackground"];
    [self getDeviceInfoIsBackground:isBackground.boolValue];
}

-(void)getDeviceInfoIsBackground:(BOOL)isBackground{
    NSArray *deviceModels = DATASOURCE.user.deviceList;
    for (DeviceModel *deviceModel in deviceModels) {
        if (deviceModel.device) {
            
            [HttpRequest getDevicePropertyWithDeviceID:@(deviceModel.device.deviceID) withProductID:deviceModel.device.productID withAccessToken:DATASOURCE.user.accessToken didLoadData:^(id result, NSError *err) {
                if (!err) {
                    NSLog(@"%@", result);
                    NSDictionary *Property = [result objectForKey:@"Property"];
                    NSString *uploadTime = [Property objectForKey:@"uploadTime"];
                    if (uploadTime.doubleValue >= deviceModel.uploadTime.doubleValue) {
                        deviceModel.uploadTime = uploadTime;
                        deviceModel.name = [Property objectForKey:@"name"];
                        
                        [DATASOURCE saveDeviceModelWithMac:[deviceModel.device getMacAddressSimple] withIsUpload:NO];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceChange object:deviceModel.device];
                    }else{
                        [DATASOURCE saveDeviceModelWithMac:[deviceModel.device getMacAddressSimple] withIsUpload:YES];
                    }
                }else{
                    NSLog(@"%@", err);
                    if (err.code == 4041009) {
                        [DATASOURCE saveDeviceModelWithMac:[deviceModel.device getMacAddressSimple] withIsUpload:YES];
                    }else{
                        [self performSelector:@selector(delayCallGetDeviceInfoWithDic:) onThread:_loginThread withObject:@{
                                                                                                                           @"delay" : @(20),
                                                                                                                           @"isBackground" : @(1)
                                                                                                                           } waitUntilDone:NO];
                    }
                }
            }];
        }
    }
}

#pragma mark loginThread
-(void)startAutoLoginThread{
    if (!_loginThread) {
        _isLoginThreadRun = YES;
        _loginThread = [[NSThread alloc] initWithTarget:self selector:@selector(autoLoginThreadRun) object:nil];
        [_loginThread start];
    }
    
}

-(void)stopAutoLoginThread{
    [self performSelector:@selector(callStopAutoLoginThread) onThread:_loginThread withObject:nil waitUntilDone:NO];
}

-(void)callStopAutoLoginThread{
    _isLoginThreadRun = NO;
}

-(void)autoLoginThreadRun{
    [[NSThread currentThread] setName:@"Auto Auth Thread"];
    [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:self selector:@selector(__run) userInfo:nil repeats:YES];
    while (_isLoginThreadRun) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    _loginThread = nil;
}

-(void)__run{
    
}

#pragma mark - ShowPwdtext&&CleanAccount

-(void)cleanAccount:(UIButton *)Btn{
    self.accountFeild.text = @"";
}

-(void)showPwd:(UIButton *)Btn{

    Btn.selected = !Btn.selected;
    if (Btn.selected) {
        self.passwordField.secureTextEntry = NO;
    }else{
        self.passwordField.secureTextEntry = YES;
    }
}

#pragma mark - 忘记密码&&注册
- (IBAction)forGotPwd:(id)sender {
    
    ForgetPwdViewController *vc = [self loadViewControllerWithStoryboardName:@"Login" withViewControllerName:@"ForgetPwdViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)Register:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    RegisterViewController  *vc = [storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 屏幕旋转
-(BOOL)shouldAutorotate{
    return false;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - LoginErr
- (void)CheckNetwork {
    NSLog(@"77=%@",[NSThread currentThread]);
    [self showWarningAlert:@"网络连接失败，请检查网络是否正常"];
    return;
}

-(void)showLoginFailErr:(NSError *)err{
    NSString *errStr;
    if (err.code == -1009) {
        errStr = @"网络错误，请重试";
        
    }else if (err.code==4041011) {
        errStr = @"手机号码未注册";
        
    }else if (err.code == 4001007) {
        errStr =@"手机号码或密码错误，请重新输入";
        
    }else{
        errStr = @"登录失败";
    }

    [self showWarningAlert:errStr];

    [self stopAutoLoginThread];
    DATASOURCE.user = nil;
}

#pragma mark - 
-(void)setAccount:(NSString *)account password:(NSString *)password{
    self.accountFeild.text = account;
    self.passwordField.text = password;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.accountFeild isFirstResponder]) {
        [self.passwordField becomeFirstResponder];
        
    }else if ([self.passwordField isFirstResponder]) {
        [textField endEditing:YES];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
