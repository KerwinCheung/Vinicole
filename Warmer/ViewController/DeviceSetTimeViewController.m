//
//  DeviceSetTimeViewController.m
//  Warmer
//
//  Created by Apple on 2017/6/24.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DeviceSetTimeViewController.h"

#import "DeviceModel.h"
#import "SendPacketModel.h"

@interface DeviceSetTimeViewController ()
{
    NSMutableArray *hourArr;
    NSMutableArray *minuteArr;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *minutePicker;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

@property (nonatomic, assign) int hourNum;
@property (nonatomic, assign) int minuteNum;

@end

@implementation DeviceSetTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hourNum = 0;
    self.minuteNum = 0;

    [self setLabelText];
    [self setPickerDataArray];
}

-(void)setLabelText{
    /*
     self.doWhat -- 1=豆浆 2=鲜玉米糊 3=烧水 4=绿豆/迷糊
     */
    NSArray *titleArr = @[@"",@"豆浆",@"鲜玉米糊",@"烧水",@"绿豆/米糊"];
    NSArray *stepLabelArr = @[@"",
                              @"豆浆的制作步骤:\n1.准备适量黄豆清洗干净;\n2.豆浆机容杯中放入适量水,并放入黄豆;\n3.开启豆浆功能,稍后即将制作出美味的豆浆;",
                              @"玉米糊的制作步骤:\n1.准备适量玉米面加少量水搅拌均匀;\n2.豆浆机容杯中放入适量水,并放入玉米面;\n3.开启玉米糊功能,稍后即将制作出美味的玉米糊;",
                              @"",
                              @"米糊的制作步骤:\n1.准备适量大米清洗干净;\n2.豆浆机容杯中放入适量水,并放入大米;\n3.开启绿豆/米糊功能,稍后即将制作出美味的米糊"];
    self.titleLabel.text = titleArr[self.doWhat];
    self.stepLabel.text = stepLabelArr[self.doWhat];
}

#pragma mark workingBtnAction
- (IBAction)starWorking:(id)sender {
    NSLog(@"hour:%.2d minute:%.2d",self.hourNum,self.minuteNum);
    
    UIAlertController *alc = [UIAlertController alertControllerWithTitle:NSLocalStr(@"温馨提示") message:@"请确定已正确放置食材,开启后机器将开始工作" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        
        [self performSelectorOnMainThread:@selector(sendDataAndPushViewControlleer) withObject:nil waitUntilDone:NO];
        
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alc addAction:cancle];
    [alc addAction:ok];
    
    [self presentViewController:alc animated:YES completion:nil];
}

-(void)sendDataAndPushViewControlleer{
    
    UInt8 mode = (const UInt8)self.doWhat;
    [self.deviceModel.dataPoint[1] replaceBytesInRange:NSMakeRange(0,1) withBytes:&mode length:1];
    
    UInt8 hour = (const UInt8)self.hourNum;
    UInt8 minute = (const UInt8)self.minuteNum;
    [self.deviceModel.dataPoint[10] replaceBytesInRange:NSMakeRange(0,1) withBytes:&hour length:1];
    [self.deviceModel.dataPoint[11] replaceBytesInRange:NSMakeRange(0,1) withBytes:&minute length:1];
    
    [SendPacketModel controlDevice:self.deviceModel.device withSendDataArray:self.deviceModel.dataPoint];

}
#pragma mark  - pickview delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.hourPicker) {
        return [hourArr count]*10;
    }else{
        return [minuteArr count]*10;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.hourPicker) {
        NSNumber *hourNum = [hourArr objectAtIndex:(row%[hourArr count])];
        int hour = hourNum.intValue;
        NSString *title = [NSString stringWithFormat:@"%.2d",hour];
        return title;
    }else{
        NSNumber *minuteNum = [minuteArr objectAtIndex:(row%[minuteArr count])];
        int minute = minuteNum.intValue;
        NSString *title = [NSString stringWithFormat:@"%.2d",minute];
        return title;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSUInteger max = 0;
    NSUInteger base10 = 0;
    if (pickerView == self.hourPicker) {
        
        if(component == 0)
        {
            max = [hourArr count]*10;
            base10 = (max/2)-(max/2)%[hourArr count];
            [pickerView selectRow:[pickerView selectedRowInComponent:component]%[hourArr count]+base10 inComponent:component animated:false];
            
            NSNumber *hour = hourArr[row%hourArr.count];
            self.hourNum = hour.intValue;
            
        }
        
    }else{
        
        if(component == 0)
        {
            max = [minuteArr count]*10;
            base10 = (max/2)-(max/2)%[minuteArr count];
            [pickerView selectRow:[pickerView selectedRowInComponent:component]%[minuteArr count]+base10 inComponent:component animated:false];
            
            NSNumber *minute = minuteArr[row%minuteArr.count];
            self.minuteNum = minute.intValue;
        }
        
    }
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *title;
    if (pickerView == self.hourPicker) {
        NSNumber *hourNum = [hourArr objectAtIndex:(row%[hourArr count])];
        int hour = hourNum.intValue;
        title = [NSString stringWithFormat:@"%.2d",hour];
        
    }else{
        NSNumber *minuteNum = [minuteArr objectAtIndex:(row%[minuteArr count])];
        int minute = minuteNum.intValue;
        title = [NSString stringWithFormat:@"%.2d",minute];
        
    }
    label.text = title;
    
    return label;
}

-(void)setPickerDataArray{
    hourArr = [NSMutableArray array];
    for (int i = 0; i<24; i++) {
        [hourArr addObject:@(i)];
    }
        [self.hourPicker selectRow:hourArr.count inComponent:0 animated:YES];
    
    minuteArr = [NSMutableArray array];
    for (int i = 0; i< 60; i++) {
        [minuteArr addObject:@(i)];
    }
        [self.minutePicker selectRow:minuteArr.count inComponent:0 animated:YES];
}
#pragma mark NavigationBarAction
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
