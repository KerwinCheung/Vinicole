//
//  DeviceControlViewController.m
//  Warmer
//
//  Created by apple on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "DeviceControlViewController.h"
#import "DeviceSetTimeViewController.h"
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

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic,assign) BOOL isAtWorkView;

@property (nonatomic,strong) UIAlertController *linkAlc;

//CurrentStateView
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentHumidityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentTempImg;
//SettingView
@property (weak, nonatomic) IBOutlet UILabel *settingTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingHumidityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *settingTempImg;
//OperationImage
@property (weak, nonatomic) IBOutlet UIImageView *coolingImg;
@property (weak, nonatomic) IBOutlet UIImageView *heatImg;
@property (weak, nonatomic) IBOutlet UIImageView *heatingImg;
//ControlBtn
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *lightBtn;
@property (weak, nonatomic) IBOutlet UIButton *defoggingBtn;
@property (weak, nonatomic) IBOutlet UIButton *TempSwtichBtn;

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
//    [self setUI];

}

-(void)setUpConstant{

}

-(void)goSetTimeVC:(NSInteger)btnTag{
    if (btnTag == 5 || btnTag ==6) {
        
        
    }else{
        DeviceSetTimeViewController *vc = [self loadViewControllerWithStoryboardName:@"DeviceControl" withViewControllerName:@"DeviceSetTimeViewController"];
        vc.doWhat = btnTag;
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
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

- (IBAction)storageBtn:(id)sender {
    //存储页面
}

- (IBAction)menuBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.menuView.hidden = !sender.selected;
    
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
        
        if (self.linkAlc != nil) {
            [self.linkAlc dismissViewControllerAnimated:YES completion:nil];
            self.linkAlc = nil;
        }
        
    }else if (device.isConnecting){
     
    }else{
       
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
    //1  开关 1byte 0=关，1=开
    [self setPowerValue];
    //2  灯开关 1byte 0=关，1=开
    [self setLightValue];
    //3  玻璃门除雾开关状态 1byte 0=关，1=开
    [self setDefoggingValue];
    
    //4  温度单位 1byte 0=关，1=开
    UInt8 tempSwitch = ((const UInt8 *)_deviceModel.dataPoint[3].bytes)[0];
    switch (tempSwitch) {
        case 0:
        {
            _TempSwtichBtn.selected = NO;
        }
            break;
        case 1:
        {
            _TempSwtichBtn.selected = YES;
        }
            break;
        default:
            break;
    }
    if (self.TempSwtichBtn.selected) {
        [_currentTempImg setImage:[UIImage imageNamed:@"℃1_bg"]];
        [_settingTempImg setImage:[UIImage imageNamed:@"℃1_bg"]];
    }else{
        [_currentTempImg setImage:[UIImage imageNamed:@"ㄈ1_bg"]];
        [_settingTempImg setImage:[UIImage imageNamed:@"ㄈ1_bg"]];
    }
    //5  温度设定值 1byte 5~20 步长为1
    UInt8 settingTempValue = ((const UInt8 *)_deviceModel.dataPoint[4].bytes)[0];
    _settingTempLabel.text = [NSString stringWithFormat:@"%d",settingTempValue];
    //6  湿度设定值 1byte 20~99 步长为1
    UInt8 settingHumidityValue = ((const UInt8 *)_deviceModel.dataPoint[5].bytes)[0];
    _settingHumidityLabel.text = [NSString stringWithFormat:@"%d",settingHumidityValue];
    //7  实际温度值 1byte 0~129 步长为1(实际温度为值-30)
    UInt8 tempValue = ((const UInt8 *)_deviceModel.dataPoint[6].bytes)[0];
    _currentTempLabel.text = [NSString stringWithFormat:@"%d",tempValue-30];
    //8  实际湿度 1byte 0~99 步长为1
    UInt8 humidityValue = ((const UInt8 *)_deviceModel.dataPoint[7].bytes)[0];
    _currentHumidityLabel.text = [NSString stringWithFormat:@"%d",humidityValue];
    //9  工作状态 1byte 0=制冷 1=恒温 2=制热
    UInt8 workingState = ((const UInt8 *)_deviceModel.dataPoint[8].bytes)[0];
    switch (workingState) {
        case 0:
        {
            [_coolingImg setImage:[UIImage imageNamed:@"cool_bg"]];
            [_heatImg setImage:[UIImage imageNamed:@"heat-1_bg"]];
            [_heatingImg setImage:[UIImage imageNamed:@"heating-1_bg"]];
        }
            break;
        case 1:
        {
            [_coolingImg setImage:[UIImage imageNamed:@"cool-1_bg"]];
            [_heatImg setImage:[UIImage imageNamed:@"heat_bg"]];
            [_heatingImg setImage:[UIImage imageNamed:@"heating-1_bg"]];
        }
            break;
        case 2:
        {
            [_coolingImg setImage:[UIImage imageNamed:@"cool-1_bg"]];
            [_heatImg setImage:[UIImage imageNamed:@"heat-1_bg"]];
            [_heatingImg setImage:[UIImage imageNamed:@"heating_bg"]];
        }
            break;
        default:
            break;
    }
    
    //10 故障 1byte 0=正常 1=E1 2=E2 。。。。 10=E10
    UInt8 deviceFault = ((const UInt8 *)_deviceModel.dataPoint[9].bytes)[0];
    if (deviceFault == 0) {
        
    }else{
    }

    
}

-(void)setUseDevice:(DeviceModel *)deviceModel{
    self.isAtWorkView = NO;
    self.deviceModel = deviceModel;
}

-(void)setPowerValue{
    UInt8 deviceSwitch = ((const UInt8 *)_deviceModel.dataPoint[0].bytes)[0];
    switch (deviceSwitch) {
        case 0:
        {
            self.isOpen = NO;
            _powerBtn.selected = NO;
        }
            break;
        case 1:
        {
            self.isOpen = YES;
            _powerBtn.selected = YES;
        }
            break;
        default:
            break;
    }
    self.shadowView.hidden = self.isOpen;
}

-(void)setLightValue{
    UInt8 lightSwitvh = ((const UInt8 *)_deviceModel.dataPoint[1].bytes)[0];
    switch (lightSwitvh) {
        case 0:
        {
            _lightBtn.selected = NO;
        }
            break;
        case 1:
        {
            _lightBtn.selected = YES;
        }
            break;
        default:
            break;
    }
}

-(void)setDefoggingValue{
    UInt8 defoggingSwitch = ((const UInt8 *)_deviceModel.dataPoint[2].bytes)[0];
    switch (defoggingSwitch) {
        case 0:
        {
            _defoggingBtn.selected = NO;
        }
            break;
        case 1:
        {
            _defoggingBtn.selected = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - BtnAction

- (IBAction)ControlBtnAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
            {
                UInt8 power = !((const UInt8 *)_deviceModel.dataPoint[0].bytes)[0];
                [self.deviceModel.dataPoint[0] replaceBytesInRange:NSMakeRange(0,1) withBytes:&power length:1];
                
                [SendPacketModel controlDevice:_deviceModel.device withSendData:self.deviceModel.dataPoint[0].bytes];
                [self setPowerValue];
            }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    [self performSelectorOnMainThread:@selector(setUI) withObject:nil waitUntilDone:NO];
}

#pragma mark - SettingBtnAction
- (IBAction)settingBtnAction:(UIButton *)sender {
    NSLog(@"%zd",sender.tag);
    switch (sender.tag) {
        case 0:
            {
                
            }
            break;
        case 1:
        {
            
        }
            break;
        default:
            break;
    }
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
