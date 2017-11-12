//
//  AddDeviceViewController.m
//  Warmer
//
//  Created by apple on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AddDeviceViewController.h"

#import "XLinkExportObject.h"
#import "HFSmartLink.h"
#import "UserModel.h"
#import "DeviceModel.h"
#import "NSTools.h"

#import <SystemConfiguration/CaptiveNetwork.h>



@interface AddDeviceViewController ()<UITextFieldDelegate>
{
    HFSmartLink * smtlk;
    
    NSNumber *accessKey;
    NSTimer *_scanTimer;
    NSInteger   _count;
    
    NSString *macAddress;
    
    __weak IBOutlet UILabel *WifiName;
    
    __weak IBOutlet UIView *loadingView;
    __weak IBOutlet UIImageView *loadingImg;
    
    __weak IBOutlet UILabel *configLable;
    
}

@property (nonatomic,strong) NSString *SSID,*Pwd;

@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation AddDeviceViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnSubscription object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
        
    }];
    smtlk = nil;
    [_scanTimer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setSSID];
    
    self.pwdField.leftViewMode = UITextFieldViewModeAlways;
    self.pwdField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.pwdField.delegate = self;
    self.pwdField.returnKeyType = UIReturnKeyDone;
    self.pwdField.placeholder = NSLocalStr(@"WIFI密码");
    
    self.pwdField.rightViewMode = UITextFieldViewModeAlways;
    UIButton *showPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showPasswordBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    showPasswordBtn.frame = CGRectMake(0, 0, 34, 24);
    [showPasswordBtn setImage:[UIImage imageNamed:@"edit_no_visibility"] forState:UIControlStateNormal];
    [showPasswordBtn setImage:[UIImage imageNamed:@"edit_visibility"] forState:UIControlStateSelected];
    [showPasswordBtn addTarget:self action:@selector(showPwd:) forControlEvents:UIControlEventTouchUpInside];
    self.pwdField.rightView = showPasswordBtn;
    self.pwdField.secureTextEntry = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSubscription:) name:kOnSubscription object:nil];
}

-(void)showPwd:(UIButton *)Btn{
    Btn.selected = !Btn.selected;
    if (Btn.selected) {
        self.pwdField.secureTextEntry = NO;
    }else{
        self.pwdField.secureTextEntry = YES;
    }
}

-(void)setSSID{
    self.SSID = [[self fetchSSIDInfo] objectForKey:@"SSID"];
    WifiName.text = [[self fetchSSIDInfo] objectForKey:@"SSID"];
    if (WifiName.text.length) {
        self.pwdField.enabled = YES;
        NSDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"WiFiPassword"]];
        if ([dic.allKeys containsObject:WifiName.text]) {
            self.pwdField.text = [dic objectForKey:WifiName.text];
            if (self.pwdField.text.length >= 6) {
 
            }
        }else{
            self.pwdField.text = @"";

        }
    }else{
        WifiName.text = @"您的设备没有连接到WiFi";
        self.pwdField.enabled = YES;
    }
}

- (IBAction)configBtnAction:(id)sender {
    
    [self.view endEditing:YES];
    
    [self savePassword];
    
    if (!self.SSID) {
        [self showWarningAlert:@"手机没有连接Wifi"];
        return;
    }
    
    [self starLink];
}

-(void)savePassword{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"WiFiPassword"]];
    [dic setObject:self.pwdField.text forKey:self.SSID];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"WiFiPassword"];
}

#pragma mark 配置设备
-(void)starLink{
    
    configLable.text = NSLocalStr(@"正在配置WiFi...");
    
    loadingView.hidden = NO;
//    [self addImageAnimation];
    
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = YES;
    smtlk.waitTimers = 30;
    
    self.Pwd = self.pwdField.text;
    
    NSLog(@"%zd",self.pwdField.text.length);
    [smtlk startWithSSID:self.SSID Key:self.Pwd withV3x:NO processblock:^(NSInteger process) {
        
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
        
        configLable.text = NSLocalStr(@"正在连接WiFi...");
        
        accessKey = @((arc4random() % 10000));
        
        macAddress = dev.mac;
        
        if (self.justLink) {
            [self showWarningAlert:@"配置网络成功" didFinish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [self startScan];
        }
        
        
    } failBlock:^(NSString *failmsg) {
        
        loadingView.hidden = YES;
        
        [self showWarningAlert:@"设备配置网络失败"];
        
    } endBlock:^(NSDictionary *deviceDic) {
        
    }];
}

-(void)addImageAnimation{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.toValue = @(120*M_PI);
    anim.duration = 60.0f;
    [loadingImg.layer addAnimation:anim forKey:@"rota"];
}

#pragma mark 开始扫描
-(void)startScan{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSetDeviceAccessKey:) name:kOnSetDeviceAccessKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotDeviceByScan:) name:kOnGotDeviceByScan object:nil];
    
    _count = 30;
    
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scan) userInfo:nil repeats:YES];
    [_scanTimer fire];
    
    
}

-(void)scan{
    _count--;
    if (_count > 0) {
        
        NSLog(@"scna");
        [[XLinkExportObject sharedObject] scanByDeviceProductID:FanPID];
        
    }else{
        [_scanTimer invalidate];
        
        [DATASOURCE getDeviceModelWithMac:macAddress];
        
        for (int i = 0; i<DATASOURCE.user.deviceList.count; i++) {
            DeviceModel *deviceModel = DATASOURCE.user.deviceList[i];
            if ([[deviceModel.device getMacAddressSimple] isEqualToString:macAddress]) {
                [DATASOURCE.user.deviceList removeObjectAtIndex:i];
            }
        }
        
        [self showWarningAlert:@"没有搜索到设备"];
        
    }
}

#pragma mark 添加设备
-(void)addDevice:(NSNotification *)noti{
    
    DeviceEntity *device = noti.object;
    macAddress = [device getMacAddressSimple];
    for (DeviceModel *deviceModel in DATASOURCE.user.deviceList) {
        if ([device.macAddress isEqualToData:deviceModel.device.macAddress]) {
            [_scanTimer invalidate];
            [self showWarningAlert:@"已添加过此设备"];
            loadingView.hidden = YES;
            return;
        }
    }
    
    DeviceModel *deviceModel = [[DeviceModel alloc] init];
    deviceModel.device = device;
    [deviceModel initDataPoint];
    deviceModel.isSubscription = @(0);
    
    NSString *macStr = [device getMacAddressSimple];
    NSString *nameStr = [macStr substringWithRange:NSMakeRange(macStr.length-4, 4)];
    deviceModel.name =[NSString stringWithFormat:@"红酒柜-%@",nameStr];
    
    DeviceModel *willDelDeviceModel = [DATASOURCE getWillDelDeviceModelWithMac:[deviceModel.device getMacAddressSimple]];
    if (willDelDeviceModel) {
        [DATASOURCE.user.willDelDeviceList removeObject:willDelDeviceModel];
    }
    
    [[XLinkExportObject sharedObject] subscribeDevice:deviceModel.device andAuthKey:deviceModel.accessKey andFlag:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddDevice object:deviceModel];
    
    [[XLinkExportObject sharedObject] connectDevice:deviceModel.device andAuthKey:deviceModel.device.accessKey];
    
    [self performSelectorOnMainThread:@selector(addDeviceDone) withObject:nil waitUntilDone:NO];
}

-(void)addDeviceDone{
    [_scanTimer invalidate];
    loadingView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDeviceList object:nil];
    
    [self showWarningAlert:[NSString stringWithFormat:@"add device %@ success!",[macAddress substringFromIndex:macAddress.length - 4 ]] didFinish:^{
        [self goBack:nil];
    }];
}

#pragma mark - 扫描回调
-(void)onGotDeviceByScan:(NSNotification *)noti{
    
    DeviceEntity *device = noti.object;
    
    if ([device.macAddress isEqualToData:[NSTools hexToData:macAddress]]) {
        
        if (device.isDeviceInitted) {
            
            [self addDevice:noti];
            return;
            
        }else{
            [self setDeviceAccessKeyWhith:device];
            [_scanTimer invalidate];
            return;
        }
        
    }
    
}

-(void)setDeviceAccessKeyWhith:(DeviceEntity *)device{
    
    [[XLinkExportObject sharedObject] setAccessKey:accessKey withDevice:device];
}

#pragma mark setAccessKey回调
-(void)onSetDeviceAccessKey:(NSNotification *)noti{
    
    int result = [noti.object[@"result"] intValue];
    if (result == 0) {
        DeviceEntity *device = [noti.object objectForKey:@"device"];
        
        for (DeviceModel *deviceModel in DATASOURCE.user.deviceList) {
            if ([device.macAddress isEqualToData:deviceModel.device.macAddress]) {
                [_scanTimer invalidate];
                [self performSelectorOnMainThread:@selector(addDeviceDone) withObject:nil waitUntilDone:NO];
                
                return;
            }
        }
        
        DeviceModel *deviceModel = [[DeviceModel alloc] init];
        deviceModel.device = device;
        deviceModel.accessKey = device.accessKey;
        deviceModel.isSubscription = @(0);
        
        
        DeviceModel *willDelDeviceModel = [DATASOURCE getWillDelDeviceModelWithMac:[deviceModel.device getMacAddressSimple]];
        
        if (willDelDeviceModel) {
            [DATASOURCE.user.willDelDeviceList removeObject:willDelDeviceModel];
        }
        
        [[XLinkExportObject sharedObject] subscribeDevice:deviceModel.device andAuthKey:deviceModel.accessKey andFlag:YES];
        
        //在登录页面监听订阅广播
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddDevice object:deviceModel];
        
        [[XLinkExportObject sharedObject] connectDevice:deviceModel.device andAuthKey:deviceModel.device.accessKey];
        
        [self performSelectorOnMainThread:@selector(addDeviceDone) withObject:nil waitUntilDone:NO];
        
    }else{
        [_scanTimer invalidate];
        
        UIView *errView = [[UIView alloc]initWithFrame:CGRectMake(0, -66, MainWidth, 66)];
        [self.view.window addSubview:errView];
        
        [self showWarningAlert:@"添加失败"];
        
    }
    
}

#pragma mark XLinkExportObject Notification 订阅回调
-(void)onSubscription:(NSNotification *)noti{
    
    
    NSDictionary *dic = noti.object;
    
    int result = [dic[@"result"] intValue];
    
    NSLog(@"订阅返回---%zd",result);
    
//    DeviceEntity *device = dic[@"device"];
    
    
//    if (result == 0) {
//        
//        NSLog(@"订阅成功！！！！！！！！");
//        
//        [scanTimer setFireDate:[NSDate distantFuture]];
//        scanTimer = nil;
//        
//        [DATASOURCE saveUserWithIsUpload:YES];
//        
//        if (addDeviceModel) {
//            // 上传设备SN
//            [self performSelectorOnMainThread:@selector(uploadDeviecSN:) withObject:device waitUntilDone:NO];
//            //            [self uploadDeviecSN:device];
//        }
//        
//        
//    }else {
//        // 如果订阅失败  继续扫描设备
//        [scanTimer setFireDate:[NSDate date]];
//        //        [self showErrString:@"继续扫描"];
//        subscribeFali = YES;
//    }
    
}
#pragma mark - otherAction
#pragma mark textFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark navigationBarAction
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark GetSSID
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}

- (IBAction)cancelLink:(id)sender {
    
    loadingView.hidden = YES;
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
        NSLog(@"取消配置");
        smtlk = nil;
    }];
    [_scanTimer invalidate];
    
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
