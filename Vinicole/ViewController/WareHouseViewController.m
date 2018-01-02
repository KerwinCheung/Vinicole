//
//  WareHouseViewController.m
//  Vinicole
//
//  Created by XMYY-21 on 2017/10/23.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "WareHouseViewController.h"
#import "DeviceModel.h"

@interface WareHouseViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@end

@implementation WareHouseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceNameLabel.text = self.deviceModel.name;
}

- (IBAction)validityBtnAction:(id)sender {
    //有效期按钮 navagationRightBarBtn
}

- (IBAction)winLineBtn:(UIButton *)sender {
    NSLog(@"%zd",sender.tag);
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
