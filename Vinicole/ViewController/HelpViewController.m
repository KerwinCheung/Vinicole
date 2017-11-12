//
//  HelpViewController.m
//  Warmer
//
//  Created by apple on 2017/1/20.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
{
    int chooseViewTag;
}
@property (weak, nonatomic) IBOutlet UIView *chooseView;

@property (weak, nonatomic) IBOutlet UIButton *productBtn;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIButton *problemBtn;

@property (weak, nonatomic) IBOutlet UIView *productView;
@property (weak, nonatomic) IBOutlet UIView *userVIew;
@property (weak, nonatomic) IBOutlet UIView *problemView;

@property (weak, nonatomic) IBOutlet UILabel *productLabel;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

-(void)setUI{
    _chooseView.layer.masksToBounds = YES;
    _chooseView.layer.cornerRadius = 12;
    _chooseView.layer.borderWidth = 1;
    _chooseView.layer.borderColor = [UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00].CGColor;
    
    _productLabel.text = @"智能wifi家电是通过WiFi无线网络连接到互联网，实现手机本地或远程控制电器功能的智能产品。采用SmartLink闪连技术，2秒极速入网，操作简单。同时客户端还有支持多个产品控制，支持设备分享，多用户控制，支持实时状态反馈等功能。";
    
    
    
    [self chooseBtn:_productBtn];
    
}

-(IBAction)chooseBtn:(UIButton *)sender{
    
    if (chooseViewTag == sender.tag) {
        return;
    }
    
    _productView.hidden = YES;
    _userVIew.hidden = YES;
    _problemView.hidden = YES;
    
    switch (sender.tag) {
        case 1:
        {
            chooseViewTag = 1;
            
            [_productBtn setBackgroundColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00]];
            [_userBtn setBackgroundColor:[UIColor whiteColor]];;
            [_problemBtn setBackgroundColor:[UIColor whiteColor]];
            
            [_productBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_userBtn setTitleColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00] forState:UIControlStateNormal];
            [_problemBtn setTitleColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00] forState:UIControlStateNormal];
            
            _productView.hidden = NO;
        }
            break;
        case 2:
        {
            chooseViewTag = 2;
            
            [_productBtn setBackgroundColor:[UIColor whiteColor]];
            [_userBtn setBackgroundColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00]];;
            [_problemBtn setBackgroundColor:[UIColor whiteColor]];
            
            [_productBtn setTitleColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00] forState:UIControlStateNormal];
            [_userBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_problemBtn setTitleColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00] forState:UIControlStateNormal];
            
            _userVIew.hidden = NO;
        }
            break;
        case 3:
        {
            chooseViewTag = 3;
            
            [_productBtn setBackgroundColor:[UIColor whiteColor]];
            [_userBtn setBackgroundColor:[UIColor whiteColor]];;
            [_problemBtn setBackgroundColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00]];
            
            [_productBtn setTitleColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00] forState:UIControlStateNormal];
            [_userBtn setTitleColor:[UIColor colorWithRed:0.36 green:0.69 blue:0.67 alpha:1.00] forState:UIControlStateNormal];
            [_problemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            _problemView.hidden = NO;
        }
            break;
            
        default:
            break;
    }
    
}


- (IBAction)goBack:(id)sender{
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
