//
//  AppDelegate.m
//  Warmer
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "XLinkExportObject.h"
#import "LaunchScreenViewController.h"
#import "NSBundle+Language.h"

#import "BaseNavigationController.h"
#import "LoginViewController.h"

@interface AppDelegate ()<XlinkExportObjectDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setLanguage];
    
    [self checkIsHaveExpDevice];
    
    [NSThread sleepForTimeInterval:0];
    
    [[XLinkExportObject sharedObject] setSDKProperty:@"cm2.xlink.cn" withKey:PROPERTY_CM_SERVER_ADDR];
    [XLinkExportObject sharedObject].delegate = self;
    [[XLinkExportObject sharedObject] start];
    
//    LaunchScreenViewController *vc = [[LaunchScreenViewController alloc]init];
//    self.window.rootViewController = vc;
    [self isAutoLogin];
    [self.window makeKeyAndVisible];
    
    return YES;

}

-(void)isAutoLogin{
    BOOL isAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoLogin"];
    UIStoryboard *storyboard;
    if (isAutoLogin) {
        
        LoginViewController *loginVc = [[LoginViewController alloc]init];
        [loginVc AutoLogin];
        
        storyboard = [UIStoryboard storyboardWithName:@"Index" bundle:nil];
    }else{
        storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
    }
    BaseNavigationController *vc =[storyboard instantiateViewControllerWithIdentifier:@"BaseNavigationController"];
    self.window.rootViewController = vc;
}

-(void)checkIsHaveExpDevice{
    
    if (![self hasLaunched]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAddExpDevice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (BOOL)hasLaunched {
    //第一次打开或者更新后第一次打开会返回no;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[userDefaults objectForKey:@"version"] isEqualToString:version]) {
        [userDefaults setObject:version forKey:@"version"];
        return NO;
    }else {
        return YES;
    }
}

-(void)setLanguage{
    
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppLanguage"];
    if (!language) {
        if ([[[NSLocale preferredLanguages] objectAtIndex:0] containsString:@"zh-Hans"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"AppLanguage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [NSBundle setLanguage:@"zh-Hans"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"AppLanguage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [NSBundle setLanguage:@"en"];
        }
    }else{

        [NSBundle setLanguage:language];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark
#pragma mark XlinkExportObject delegate
-(void)onStart{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnStart object:nil];
}

-(void)onGotDeviceByScan:(DeviceEntity *)device{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnGotDeviceByScan object:device];
}

//通知状态返回
-(void)onLogin:(int)result{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnLogin object:@(result)];
}

//订阅状态返回
-(void)onSubscription:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    if (result == 0) {
        NSLog(@"订阅成功,MessageID = %d", messageID);
    }else{
        NSLog(@"订阅失败,MessageID = %d; Result = %d", messageID, result);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSubscription object:@{@"result" : @(result), @"device" : device}];
}

// 连接设备结果回调
-(void)onConnectDevice:(DeviceEntity *)device andResult:(int)result andTaskID:(int)taskID{
    NSLog(@"设备 %@ 连接结果 %d", [device getMacAddressString], result);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectDevice object:device];
    
    if (result == 1) {
        [[XLinkExportObject sharedObject] probeDevice:device];
    }
}

// 设备上下线状态回调
-(void)onDeviceStatusChanged:(DeviceEntity *)device{
    NSLog(@"设备 %@ 状态改变, 设备类型 : %d", [device getMacAddressString], device.deviceType);
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnDeviceStateChange object:device];
}

// 与设备订阅状态回调
-(void)onNotifyWithFlag:(unsigned char)flag withMessageData:(NSData *)data fromID:(int)fromID messageID:(int)messageID{
    NSDictionary * shareDic = [NSJSONSerialization JSONObjectWithData:[data subdataWithRange:NSMakeRange(2, data.length - 2)] options:NSJSONReadingMutableLeaves error:nil];
    //    {"invite_code":"120fa2adf9c32001","device_id":"1144503248","type":"0"}
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnNotify object:shareDic];
}

-(void)onSetCloudDataPoint:(DeviceEntity *)device withResult:(int)result withMsgID:(unsigned short)msgID{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnSetCloudDataPoint object:@{@"msgID" : @(msgID), @"result" : @(result)}];
}

-(void)onCloudDataPoint2Update:(DeviceEntity *)device withDataPoints:(NSArray<DataPointEntity *> *)dataPoints{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnCloudDataPointUpdate object:@{@"device" : device, @"datapoints" : dataPoints}];
}

//接收到设备发送过来的透穿消息
-(void)onRecvLocalPipeData:(DeviceEntity *)device withPayload:(NSData *)data{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvLocalPipeData object:@{@"device" : device, @"data" : data}];
    
}

//接收到云端设备发送回来的透传数据
-(void)onRecvPipeData:(DeviceEntity *)device withPayload:(NSData *)payload{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvLocalPipeData object:@{@"device" : device, @"data" : payload}];
    
}

//接收到云端设备发送的广播透传数据
-(void)onRecvPipeSyncData:(DeviceEntity *)device withPayload:(NSData *)payload{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOnRecvLocalPipeData object:@{@"device" : device, @"data" : payload}];
    
}

-(void)onSendLocalPipeData:(DeviceEntity *)device withResult:(int)result withMessageID:(int)messageID{
    NSLog(@"发送本地透传结果");
}

@end
