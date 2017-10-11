//
//  DeviceControlViewController.m
//  Warmer
//
//  Created by apple on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "DeviceControlViewController.h"
#import "DeviceSetTimeViewController.h"
#import "DeviceWorkingViewController.h"
#import "AddDeviceViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import "SendPacketModel.h"

#import "XLinkExportObject.h"

@interface DeviceControlViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

//menuBtn
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
//menuView
@property (weak, nonatomic) IBOutlet UIView *menuView;

//开关按钮
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;

//底部功能按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doujiangBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doujiangBtnHeight;

@property (weak, nonatomic) IBOutlet UIButton *djBtn;
@property (weak, nonatomic) IBOutlet UIButton *ssBtn;
@property (weak, nonatomic) IBOutlet UIButton *xymhBtn;
@property (weak, nonatomic) IBOutlet UIButton *ldmhBtn;
@property (weak, nonatomic) IBOutlet UIButton *qxBtn;
@property (weak, nonatomic) IBOutlet UIButton *bwBtn;

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (nonatomic, assign) BOOL isOpen;

@property (weak, nonatomic) IBOutlet UILabel *deviceOnlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceFaultLabel;

@property (nonatomic,assign) BOOL isAtWorkView;

@property (nonatomic,strong) UIAlertController *linkAlc;
@end

@implementation DeviceControlViewController

-(void)viewDidLayoutSubviews{
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.deviceModel.device.isConnected) {
        [[XLinkExportObject sharedObject] connectDevice:self.deviceModel.device andAuthKey:self.deviceModel.device.accessKey];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isOpen = YES;
    self.isAtWorkView = NO;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //设备数据改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceChange:) name:kDeviceChange object:nil];
    //设备连接状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceStateChange:) name:kOnConnectDevice object:nil];
    
    [self setUpConstant];
    [self setUI];

}

-(void)setUpConstant{
    self.doujiangBtnWidth.constant = MainWidth*0.5f;
    if (MainWidth == 375) {
        //6
        self.doujiangBtnHeight.constant = 98;
    }else if (MainWidth > 375){
        //6+
        self.doujiangBtnHeight.constant = 116;
    }else if (MainWidth < 375){
        //5
        self.doujiangBtnHeight.constant = 80;
    }
}

#pragma mark - switchBtnAction
- (IBAction)switchAction:(UIButton *)sender {
    
    if (self.deviceModel.device.isConnected || self.deviceModel.isExpDevice.intValue == 1) {
        sender.selected = !sender.selected;
        
        self.isOpen = !sender.selected;
        self.shadowView.hidden = !sender.selected;
        
        self.djBtn.userInteractionEnabled =
        self.xymhBtn.userInteractionEnabled =
        self.ssBtn.userInteractionEnabled =
        self.ldmhBtn.userInteractionEnabled =
        self.bwBtn.userInteractionEnabled =
        self.qxBtn.userInteractionEnabled = !sender.selected;
        
        UInt8 state;
        if (self.isOpen) {
            state = 0x55;
        }else{
            state = 0xff;
        }
        [self.deviceModel.dataPoint[0] replaceBytesInRange:NSMakeRange(0,1) withBytes:&state length:1];
        [SendPacketModel clocsDevice:self.deviceModel.device withSendDataArray:self.deviceModel.dataPoint];
    }else{
        
        [[XLinkExportObject sharedObject] connectDevice:self.deviceModel.device andAuthKey:self.deviceModel.device.accessKey];
        
        
        self.linkAlc = [UIAlertController alertControllerWithTitle:nil message:@"正在连接设备" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];

        [self.linkAlc addAction:ok];
        
        [self presentViewController:self.linkAlc animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.linkAlc != nil) {
                [self.linkAlc dismissViewControllerAnimated:YES completion:^{
                    UIAlertController *faultAC = [UIAlertController alertControllerWithTitle:nil message:@"设备连接失败" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [faultAC addAction:ok];
                    
                    [self presentViewController:faultAC animated:YES completion:nil];
                }];
                self.linkAlc = nil;
            }
        });
    }
    
    
}

#pragma mark - functionBtnAction
- (IBAction)functionAction:(UIButton *)sender {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    /*
     1=豆浆 2=鲜玉米糊 3=烧水 4=绿豆/迷糊 5=保温 6=清洗
     */
    [self goSetTimeVC:sender.tag];
}

-(void)goSetTimeVC:(NSInteger)btnTag{
    if (btnTag == 5 || btnTag ==6) {
        
        [self sendDataAndPushVCWithDoingWhat:btnTag];
        
    }else{
        DeviceSetTimeViewController *vc = [self loadViewControllerWithStoryboardName:@"DeviceControl" withViewControllerName:@"DeviceSetTimeViewController"];
        vc.doWhat = btnTag;
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)sendDataAndPushVCWithDoingWhat:(NSInteger)btnTag{
    //功能（1byte）0x00 无模式 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY0x07
    UInt8 mode = (const UInt8)btnTag;
    [self.deviceModel.dataPoint[1] replaceBytesInRange:NSMakeRange(0,1) withBytes:&mode length:1];
    
    UInt8 hour = 0;
    UInt8 minute = 0;
    [self.deviceModel.dataPoint[10] replaceBytesInRange:NSMakeRange(0,1) withBytes:&hour length:1];
    [self.deviceModel.dataPoint[11] replaceBytesInRange:NSMakeRange(0,1) withBytes:&minute length:1];
    
    [SendPacketModel controlDevice:self.deviceModel.device withSendDataArray:self.deviceModel.dataPoint];
    
    DeviceWorkingViewController *vc = [self loadViewControllerWithStoryboardName:@"DeviceControl" withViewControllerName:@"DeviceWorkingViewController"];
    vc.doingWhat = btnTag;
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - menuBtnAction
- (IBAction)menuBtnAction:(UIButton *)sender {
    NSLog(@"菜单%zd",sender.tag);
    switch (sender.tag) {
        case 1:
        {
            //修改名称
            __weak typeof(self) weakself = self;
            
            UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalStr(@"设备名称") message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [alc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull nameField) {
                nameField.placeholder = @"请输入用户名";
                [[NSNotificationCenter defaultCenter]addObserver:weakself selector:@selector(handleTextFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
            }];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                UITextField *deviceName = alc.textFields.firstObject;
                
                [[NSNotificationCenter defaultCenter] removeObserver:weakself name:UITextFieldTextDidChangeNotification object:nil];
                
                self.deviceModel.name = deviceName.text;
                
                [DATASOURCE saveUserWithIsUpload:NO];
                
                self.titleLabel.text = self.deviceModel.name;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateDeviceList object:nil];

                
                
                
            }];
            ok.enabled = NO;
            
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter]removeObserver:weakself name:UITextFieldTextDidChangeNotification object:nil];
            }];
            
            [alc addAction:cancle];
            [alc addAction:ok];
            
            [self presentViewController:alc animated:YES completion:nil];
        }
            break;
        case 2:
        {
            //重新配网
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AddDevice" bundle:nil];
            
            AddDeviceViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"AddDeviceViewController"];
            vc.justLink = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            //删除设备
            UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalStr(@"删除设备") message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteDevice object:_deviceModel];
                
                [self performSelectorOnMainThread:@selector(goBack:) withObject:nil waitUntilDone:NO];
            }];
            
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alc addAction:cancle];
            [alc addAction:ok];
            
            [self presentViewController:alc animated:YES completion:nil];
        }
            break;
        case 4:
        {
            [self menuBtn:_menuBtn];
        }
            break;
            
        default:
            break;
    }
}

- (void)handleTextFieldDidChanged:(NSNotification *)notification{
    
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    
    if (alertController) {
        
        UITextField *login = alertController.textFields.firstObject;
        
        UIAlertAction *okAction = alertController.actions.lastObject;
        
        okAction.enabled = login.text.length > 0;
        
    }
    
}

#pragma mark - NavigationBarAction
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.menuView.hidden =
    self.djBtn.userInteractionEnabled =
    self.xymhBtn.userInteractionEnabled =
    self.ssBtn.userInteractionEnabled =
    self.ldmhBtn.userInteractionEnabled =
    self.bwBtn.userInteractionEnabled =
    self.qxBtn.userInteractionEnabled = !sender.selected;
    
    if (self.menuView.hidden) {
        
        
        if (self.isOpen) {
            self.shadowView.hidden = self.menuView.hidden;
        }
        
    }else{
        self.shadowView.hidden = self.menuView.hidden;
    }

}

#pragma mark - other
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.menuBtn.isSelected) {
        [self menuBtn:self.menuBtn];
    }
    
}

#pragma mark - DeviceChange
-(void)onDeviceChange:(NSNotification *)noti{
    DeviceEntity *tempDevice = noti.object;
    if (tempDevice == _deviceModel.device && tempDevice != nil) {
        [self performSelectorOnMainThread:@selector(deviceOnlineLabelSet:) withObject:tempDevice waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setUI) withObject:nil waitUntilDone:NO];
    }
}

-(void)onDeviceStateChange:(NSNotification *)noti{
    DeviceEntity *tempDevice = noti.object;
    if (tempDevice == self.deviceModel.device && tempDevice != nil) {
        [self performSelectorOnMainThread:@selector(deviceOnlineLabelSet:) withObject:tempDevice waitUntilDone:NO];
    }
}

-(void)deviceOnlineLabelSet:(DeviceEntity *)device{
    
    
    
    if (device.isConnected) {
        [self.deviceOnlineLabel setText:@"设备在线"];
        [self.deviceOnlineLabel setTextColor:[UIColor whiteColor]];
        
        if (self.linkAlc != nil) {
            [self.linkAlc dismissViewControllerAnimated:YES completion:nil];
            self.linkAlc = nil;
        }
        
    }else if (device.isConnecting){
        [self.deviceOnlineLabel setText:@"设备连接中"];
        [self.deviceOnlineLabel setTextColor:[UIColor whiteColor]];
    }else{
        self.deviceOnlineLabel.text = @"设备离线";
        self.deviceOnlineLabel.textColor = [UIColor redColor];
        if (self.linkAlc != nil) {
            [self.linkAlc dismissViewControllerAnimated:YES completion:^{
                UIAlertController *faultAC = [UIAlertController alertControllerWithTitle:nil message:@"设备连接失败" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [faultAC addAction:ok];
                
                [self presentViewController:faultAC animated:YES completion:nil];
            }];
            
            self.linkAlc = nil;

        }
        
    }
}
#pragma mark - setUI
-(void)setUI{
    self.titleLabel.text = self.deviceModel.name;
    
    if (self.deviceModel == nil) {
        return;
    }
    
    //1开关机（1byte）1=开机 0=关机
    UInt8 deviceSwitch = ((const UInt8 *)_deviceModel.dataPoint[0].bytes)[0];
    switch (deviceSwitch) {
        case 0:
        {
            self.isOpen = NO;
        }
            break;
        case 1:
        {
            self.isOpen = YES;
        }
            break;
        default:
            break;
    }
    self.switchBtn.selected =!self.isOpen;
    
    self.shadowView.hidden =
    self.djBtn.userInteractionEnabled =
    self.xymhBtn.userInteractionEnabled =
    self.ssBtn.userInteractionEnabled =
    self.ldmhBtn.userInteractionEnabled =
    self.bwBtn.userInteractionEnabled =
    self.qxBtn.userInteractionEnabled = self.isOpen;
    
    //2功能（1byte）0x00 无模式 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY0x07
    UInt8 deviceState = ((const UInt8 *)_deviceModel.dataPoint[1].bytes)[0];
    if (deviceState != 0x00 && !self.isAtWorkView) {
        self.isAtWorkView = YES;
        DeviceWorkingViewController *vc = [self loadViewControllerWithStoryboardName:@"DeviceControl" withViewControllerName:@"DeviceWorkingViewController"];
        vc.doingWhat = deviceState;
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    UInt8 deviceFault = ((const UInt8 *)_deviceModel.dataPoint[8].bytes)[0];
    if (deviceFault == 0) {
        self.deviceFaultLabel.hidden = YES;
    }else{
        self.deviceFaultLabel.hidden = NO;
        
        NSArray *textArr = @[@"",@"电源网络故障",@"满水故障",@"缺水故障",@"探头开路故障",@"探头高温故障",@"探头短路故障"];
        self.deviceFaultLabel.text = textArr[deviceFault];
    }
    
    //3运行的时钟（1byte）
    //4运行的分钟（1byte）
    //5运行的秒（1byte）
    //6速度（1byte）
    //7当前的温度（1byte）
    //8备用（1byte）
    //9故障（1byte）
    /*10工作状态显示（1byte）
     Bit4~bit7:0=无工作状态显示 1=完成 2=加热 3=搅拌 4=暂停
     Bit0~bit3: 0=无工作状态显示 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY 0x07 其他：预留*/
    //11预约剩余小时（1byte）
    //12预约剩余分钟（1byte）

    
}

-(void)setUseDevice:(DeviceModel *)deviceModel{
    self.isAtWorkView = NO;
    self.deviceModel = deviceModel;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceChange object:nil];
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
