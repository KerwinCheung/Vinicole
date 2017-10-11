//
//  CorporateCultureViewController.m
//  Warmer
//
//  Created by apple on 2017/1/20.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "CorporateCultureViewController.h"

@interface CorporateCultureViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cultureImage;

@end

@implementation CorporateCultureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
