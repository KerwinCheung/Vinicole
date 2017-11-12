//
//  ForgetPwdViewController.m
//  Warmer
//
//  Created by apple on 2017/1/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "LoginViewController.h"

#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "NSTools.h"

@interface ForgetPwdViewController ()
{
    NSTimer *codeTimer;
    int countDownValue;
}

@property (nonatomic, assign) int chooseWhat;//1=phone 2=email
@property (weak, nonatomic) IBOutlet UIView *chooseView;
@property (weak, nonatomic) IBOutlet UIButton *choosePhoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *choosEmailBtn;

@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passworFieldConstant;

@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

-(void)setUp{
    self.chooseWhat = 1;
    self.chooseView.layer.masksToBounds = YES;
    self.chooseView.layer.borderWidth = 1;
    self.chooseView.layer.borderColor = [UIColor colorWithRed:0.18 green:0.77 blue:0.64 alpha:1.00].CGColor;
    self.chooseView.layer.cornerRadius = 5;
}

#pragma mark chooseBtnAction
- (IBAction)chooseBtnACtion:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            //phone state
            //btn
            self.accountField.placeholder = @"请输入手机号码";
            self.choosePhoneBtn.backgroundColor = [UIColor colorWithRed:0.18 green:0.77 blue:0.64 alpha:1.00];
            [self.choosePhoneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            self.choosEmailBtn.backgroundColor = [UIColor whiteColor];
            [self.choosEmailBtn setTitleColor:[UIColor colorWithRed:0.18 green:0.77 blue:0.64 alpha:1.00] forState:UIControlStateNormal];
            //action
            self.chooseWhat = 1;
            
            self.codeField.hidden = NO;
            self.codeBtn.hidden = NO;
            self.passwordField.hidden = NO;
            self.passworFieldConstant.constant = 80;
            
        }
            break;
        case 2:
        {
            //email
            //btn
            self.accountField.placeholder = @"请输入邮箱";
            self.choosEmailBtn.backgroundColor = [UIColor colorWithRed:0.18 green:0.77 blue:0.64 alpha:1.00];
            [self.choosEmailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            self.choosePhoneBtn.backgroundColor = [UIColor whiteColor];
            [self.choosePhoneBtn setTitleColor:[UIColor colorWithRed:0.18 green:0.77 blue:0.64 alpha:1.00] forState:UIControlStateNormal];
            //action
            self.chooseWhat = 2;
            
            self.codeField.hidden = YES;
            self.codeBtn.hidden = YES;
            self.passwordField.hidden = YES;
            self.passworFieldConstant.constant = -40;
        }
            break;
        default:
            break;
    }
}

#pragma mark - getPhoneCode
- (IBAction)getCodeAction:(id)sender {
    if (![NSTools validatePhone:self.accountField.text]) {
        [self showWarningAlert:@"请输入正确的手机号码"];
        return;
    }
    
    [HttpRequest forgotPasswordWithAccount:self.accountField.text didLoadData:^(id result, NSError *err) {
        if (!err) {
            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"验证码已发送" waitUntilDone:NO];
        }else{
            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"网络异常,请稍后再试." waitUntilDone:NO];
        }
        
    }];
    
    self.codeBtn.userInteractionEnabled = NO;
    [self.codeBtn setBackgroundColor:[UIColor grayColor]];
    countDownValue = 59;
    codeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [codeTimer fire];
    [[NSRunLoop currentRunLoop] run];
}

-(void)countDown{
    
    if (countDownValue == 0) {
        self.codeBtn.userInteractionEnabled = YES;
        [self.codeBtn setBackgroundColor:[UIColor colorWithRed:0.18 green:0.77 blue:0.64 alpha:1.00]];
        [self.codeBtn setTitle:NSLocalStr(@"获取验证码") forState:UIControlStateNormal];
        [codeTimer invalidate];
        return;
    }
    
    NSString *titleStr = [NSString stringWithFormat:@"%d%@",countDownValue,@"秒后重发"];
    [self.codeBtn setTitle:titleStr forState:UIControlStateNormal];
    countDownValue--;
}



#pragma mark - forgetBtnAction
- (IBAction)nextAction:(id)sender {
    
    switch (self.chooseWhat) {
        case 1:
        {
            [self checkFeild];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [HttpRequest foundBackPasswordWithAccount:self.accountField.text withVerifyCode:self.codeField.text withNewPassword:self.passwordField.text didLoadData:^(id result, NSError *err) {
                
                [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                
                if (!err) {
                    [self performSelectorOnMainThread:@selector(successAction) withObject:nil waitUntilDone:NO];
                }else{
                    switch (err.code) {
                        case -1009:
                            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"网络错误，请重试" waitUntilDone:NO];
                            break;
                            
                        case -1001:
                            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"网络错误，请重试" waitUntilDone:NO];
                            break;
                            
                        case 4001004:
                            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"验证码错误，请重新输入" waitUntilDone:NO];
                            break;
                            
                        case 4001003:
                            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"验证码过期，请重新获取验证码" waitUntilDone:NO];
                            break;
                            
                        default:
                            [self performSelectorOnMainThread:@selector(showWarningAlert:) withObject:@"修改失败" waitUntilDone:NO];
                            break;
                    }
                    
                }
            }];
        }
            break;
        
        case 2:
        {
            NSString *emailStr = [self.accountField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (![NSTools validateEmail:emailStr]) {
                
                [self showWarningAlert:NSLocalizedString(@"请输入正确的邮箱！",nil)];
                return;
            }
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
            
            [HttpRequest forgotPasswordWithAccount:emailStr didLoadData:^(id result, NSError *err) {
                
                [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
                
                if (err) {
                    [self performSelectorOnMainThread:@selector(getPasswordFailWithErr:) withObject:err waitUntilDone:NO];
                }else{
                    [self performSelectorOnMainThread:@selector(successAction) withObject:nil waitUntilDone:NO];
                }
            }];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)checkFeild{
    if (self.accountField.text.length == 0) {
        [self showWarningAlert:@"请输入手机号"];
    }
    
    if (self.codeField.text.length == 0) {
        [self showWarningAlert:@"请输入验证码"];
    }
    
    if (self.passwordField.text.length == 0) {
        [self showWarningAlert:@"请输入密码"];
    }
    
    if (![NSTools validatePhone:self.accountField.text]) {
        [self showWarningAlert:@"请输入正确的手机号码"];
        return;
    }
    
    if (self.passwordField.text.length < 6 || self.passwordField.text.length > 16) {
        [self showWarningAlert:@"请输入一个6-16位字符密码"];
    }
}

- (void)getPasswordFailWithErr:(NSError *)err{
    NSString *errStr;
    
    if (err.code == -1009) {
        errStr = NSLocalizedString(@"网络连接失败，请检查网络是否正常！",nil);
    }
    else if (err.code == 4041011) {
        errStr = [NSString stringWithFormat:@"%@%@",self.accountField.text,NSLocalizedString(@"邮箱不存在!", nil)];
    }else if (err.code == 4001032){
        errStr = [NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"邮箱",nil),self.accountField.text,NSLocalizedString(@"暂未激活，请激活再登录！", nil)];
    }else{
        errStr = NSLocalizedString(@"找回密码邮件发送失败，请重试",nil);
    }
    
    [self showWarningAlert:errStr];
}

- (void)successAction{

    switch (self.chooseWhat) {
        case 1:
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.accountField.text forKey:@"lastLoginAccount"];
            [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"lastLoginPwd"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self showWarningAlert:@"密码修改成功!" didFinish:^{
                
                LoginViewController *loginView = self.navigationController.viewControllers[0];
                [loginView setAccount:self.accountField.text password:self.passwordField.text];
                [self.navigationController popToViewController:loginView animated:YES];
            }];
        }
            break;
        case 2:
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.accountField.text forKey:@"lastLoginAccount"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self showWarningAlert:@"一封找回密码的邮件已经发送到您的邮箱,请根据邮件提示进行密码重置." didFinish:^{
                
                LoginViewController *loginView = self.navigationController.viewControllers[0];
                [loginView setAccount:self.accountField.text password:nil];
                [self.navigationController popToViewController:loginView animated:YES];
                
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.accountField isFirstResponder]) {
        
        switch (self.chooseWhat) {
            case 1:
            {
                //phoneState
                [self.codeField becomeFirstResponder];
            }
                break;
            case 2:
            {
                //emaileState
                [self.passwordField becomeFirstResponder];
            }
                break;
            default:
                break;
        }
        
        
    }else if ([self.codeField isFirstResponder]) {
        
        [self.passwordField becomeFirstResponder];
        
        
    }else if ([self.passwordField isFirstResponder]){
        
        [textField endEditing:YES];
        [UIView animateWithDuration:0.2 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, 0);
            
        }];
        
        
    }

    return YES;
}

-(bool)textFieldShouldBeginEditing:(UITextField *)textField{

            if (textField == self.passwordField) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.transform = CGAffineTransformMakeTranslation(0, -90);
                    
                }];
                
            }

    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
