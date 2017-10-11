//
//  LaunchScreenViewController.m
//  Warmer
//
//  Created by apple on 2016/11/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LaunchScreenViewController.h"
#import "BaseNavigationController.h"
#import "LoginViewController.h"

@interface LaunchScreenViewController ()
{
    int gifTime;
    NSTimer *countDownTimer;
}
@property (strong,nonatomic) UIWebView *webView;

@end

@implementation LaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    gifTime = 40 ;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"herpusi_start_bg@2x" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:path];
    
    _webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.scrollEnabled = NO;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = 0;
    [_webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    
    [self.view addSubview:_webView];
    
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [countDownTimer fire];
    [NSRunLoop currentRunLoop];
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
    [self presentViewController:vc animated:NO completion:nil];
}

-(void)countDown{
    if (gifTime == 0) {
        [countDownTimer invalidate];
        
        [self isAutoLogin];
        
    }else{
        gifTime--;
    }
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
