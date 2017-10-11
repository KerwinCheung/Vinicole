//
//  DeviceWorkingViewController.m
//  Warmer
//
//  Created by Apple on 2017/6/25.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DeviceWorkingViewController.h"
#import "DeviceControlViewController.h"

#import "DeviceModel.h"
#import "UAProgressView.h"
#import "SendPacketModel.h"

@interface DeviceWorkingViewController ()

@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (nonatomic, assign) CGFloat localProgress;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *workLabel;
@property (weak, nonatomic) IBOutlet UILabel *workStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *deviceFaultLabel;
@end

@implementation DeviceWorkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   // [self setUpProgressView];
    
    NSArray *titleArr = @[@"",@"豆浆",@"鲜玉米糊",@"煲水",@"绿豆/米糊",@"保温",@"清洗"];
    self.titleLabel.text = titleArr[self.doingWhat];
    
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceChange:) name:kDeviceChange object:nil];
}

-(void)setUpProgressView{
    self.localProgress = 0;
    self.progressView.borderWidth = 0;
    self.progressView.lineWidth = self.progressView.width*0.5f;
    self.progressView.fillOnTouch = NO;
    self.progressView.strokeColor = [UIColor brownColor];
}

- (IBAction)goBackToDeviceVC:(id)sender {

    UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalStr(@"温馨提示") message:@"您的豆浆机正在工作中,请确定是否关闭?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UInt8 state = 0x00;
        [self.deviceModel.dataPoint[1] replaceBytesInRange:NSMakeRange(0,1) withBytes:&state length:1];
        [SendPacketModel controlDevice:self.deviceModel.device withSendDataArray:self.deviceModel.dataPoint];
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[DeviceControlViewController class]]) {
                
                DeviceControlViewController *dcVc = (DeviceControlViewController *)vc;
                [dcVc setDeviceModel:self.deviceModel];
                [self.navigationController popToViewController:dcVc animated:YES];
            }
        }
        
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alc addAction:cancle];
    [alc addAction:ok];
    
    [self presentViewController:alc animated:YES completion:nil];
    
    
}


#pragma mark - DeviceChange
-(void)onDeviceChange:(NSNotification *)noti{
    DeviceEntity *tempDevice = noti.object;
    if (tempDevice == self.deviceModel.device && tempDevice != nil) {
        
        [self performSelectorOnMainThread:@selector(setUI) withObject:nil waitUntilDone:NO];
    }
}

-(void)setUI{
    if (self.deviceModel == nil) {
        return;
    }
    
    //1开关机（1byte）1=开机 0=关机
    //2功能（1byte）0x00 无模式 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY0x07
    UInt8 deviceState = ((const UInt8 *)self.deviceModel.dataPoint[1].bytes)[0];
    
    if (deviceState == 0x00) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[DeviceControlViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
    /*
     10工作状态显示（1byte）
     state Bit4~bit7:0=无工作状态显示 1=完成 2=加热 3=搅拌 4=暂停
     mode Bit0~bit3: 0=无工作状态显示 豆浆0x01 鲜玉米糊0x02 煲水0x03 绿豆米糊0x04 保温0x05 清洗0x06 DIY 0x07 其他：预留
     */
    NSData *stateData = [NSMutableData dataWithData:[self.deviceModel.dataPoint[9] subdataWithRange:NSMakeRange(0, 1)]];
    unsigned char state;
    unsigned char mode;
    [stateData getBytes:&mode length:1];
    state = mode;
    mode = mode & 0b00001111;//0~3 mode
    state = (state &0b11110000) >> 4;//4~7 state
    
    if (mode != 0) {
        NSArray *titleTextArr = @[@"",@"豆浆",@"鲜玉米糊",@"煲水",@"绿豆/米糊",@
                                  "保温",@"清洗"];
        self.workLabel.text = titleTextArr[deviceState];
    }

    
    //11预约剩余小时（1byte）
    UInt8 orderHour = ((const UInt8 *)self.deviceModel.dataPoint[10].bytes)[0];
    //12预约剩余分钟（1byte）
    UInt8 orderMinute = ((const UInt8 *)self.deviceModel.dataPoint[11].bytes)[0];
    if (orderHour != 0 || orderMinute != 0) {
        self.orderTime.hidden = NO;
        self.orderTime.text = [NSString stringWithFormat:@"剩余时间 %02d:%02d",orderHour,orderMinute];
        
        self.workStateLabel.text = @"预约中";
    }else{
        NSArray *workStateArr = @[@"工作中",@"完成",@"加热",@"搅拌",@"暂停"];
        self.workStateLabel.text = workStateArr[state];
        
        self.orderTime.hidden = YES;
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
   // UInt8 workHour = ((const UInt8 *)self.deviceModel.dataPoint[2].bytes)[0];
    //4运行的分钟（1byte）
   // UInt8 workMinute = ((const UInt8 *)self.deviceModel.dataPoint[3].bytes)[0];
    //5运行的秒（1byte）
    //UInt8 workSecond = ((const UInt8 *)self.deviceModel.dataPoint[4].bytes)[0];
    
    
    //self.localProgress = (workHour*360.0f+workMinute*60.0f+workSecond)/(orderHour*360.0f+orderMinute*60.0f);
    //[self.progressView setProgress:self.localProgress animated:YES];
    
    
    //6速度（1byte）
    //7当前的温度（1byte）
    //8备用（1byte）
    //9故障（1byte）
    
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
