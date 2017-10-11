//
//  AboutUsViewController.m
//  Warmer
//
//  Created by apple on 2017/1/21.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"V %@",version];
}

- (IBAction)phoneCall:(id)sender {
    NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",@"+86-760-8877"];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phoneStr]]];
    [self.view addSubview:callWebview];
}

- (IBAction)goSafari:(id)sender {
    NSURL *url = [[NSURL alloc]initWithString:@"www.vinicolecellar.com"];
    [[UIApplication sharedApplication] openURL:url];
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
