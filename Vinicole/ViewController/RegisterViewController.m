//
//  RegisterViewController.m
//  Warmer
//
//  Created by apple on 2016/11/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "RegisterViewController.h"
#import "HttpRequest.h"
#import "NSTools.h"
#import "MBProgressHUD.h"

#import "LoginViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
{
    NSTimer *codeTimer;
    int countDownValue;
    MBProgressHUD *hud;
}

@property (nonatomic, assign) int chooseWhat;//1=phone 2=email
@property (weak, nonatomic) IBOutlet UIView *chooseView;
@property (weak, nonatomic) IBOutlet UIButton *choosePhoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *choosEmailBtn;



@property (weak, nonatomic) IBOutlet UITextField *accountField;

@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passworFieldConstant;

@property (weak, nonatomic) IBOutlet UITextField *nameField;


@end

@implementation RegisterViewController

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
            self.passworFieldConstant.constant = 20;
        }
            break;
        default:
            break;
    }
}


#pragma mark codeBtnAction
- (IBAction)getCode:(id)sender {
    if (![NSTools validatePhone:self.accountField.text]) {
        [self showWarningAlert:@"请输入正确的手机号码"];
        return;
    }
    
    [HttpRequest getVerifyCodeWithPhone:self.accountField.text didLoadData:^(id result, NSError *err) {
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
        [self.codeBtn setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00]];
        [self.codeBtn setTitle:NSLocalStr(@"获取验证码") forState:UIControlStateNormal];
        [codeTimer invalidate];
        return;
    }
    
    NSString *titleStr = [NSString stringWithFormat:@"%d%@",countDownValue,@"秒后重发"];
    [self.codeBtn setTitle:titleStr forState:UIControlStateNormal];
    countDownValue--;
}

#pragma mark - RegisterBtnAction
- (IBAction)nextAction:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        
    }];
    switch (self.chooseWhat) {
        case 1:
        {
            //phoneState
            if (![NSTools validatePhone:self.accountField.text]) {
                [self showWarningAlert:NSLocalStr(@"请输入正确的手机号码")];
                return;
            }
            
            if (_codeField.text.length == 0) {
                [self showWarningAlert:NSLocalStr(@"请输入正确的验证码")];
                return;
            }
            
            if (!((self.passwordField.text.length>=6)&&(self.passwordField.text.length<=16))) {
                
                [self showWarningAlert:NSLocalizedString(@"密码格式不正确，长度在6-16位！",nil)];
                return;
            }
            
            if (![NSTools validatePassword:self.passwordField.text]) {
                
                [self showWarningAlert:NSLocalizedString(@"密码格式不正确！",nil)];
                return;
            }
            
            [self registerWithAccount:self.accountField.text withNickname:self.nameField.text withPassword:self.passwordField.text codeStr:self.codeField.text];
        }
            break;
        case 2:
        {
            //emailState
            
            if (![NSTools validateEmail:self.accountField.text]) {
                [self showWarningAlert:NSLocalizedString(@"请输入正确的邮箱！",nil)];
                return;
            }
            if ((!((self.nameField.text.length>1)&&(self.nameField.text.length<=15))) || [NSTools validateName:self.nameField.text]) {
                
                [self showWarningAlert:NSLocalizedString(@"用户昵称格式不正确，长度在2-15位且不能包含特殊字符！",nil)];
                return;
            }
            if (!((self.passwordField.text.length>=6)&&(self.passwordField.text.length<=16))) {
                
                [self showWarningAlert:NSLocalizedString(@"密码格式不正确，长度在6-16位！",nil)];
                return;
            }
            if (![NSTools validatePassword:self.passwordField.text]) {
                
                [self showWarningAlert:NSLocalizedString(@"密码格式不正确！",nil)];
                return;
            }
            
            UIAlertController *altc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"邮箱确认",nil) message:[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"您的注册邮箱是:",nil),self.accountField.text] preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *cancelStr = NSLocalizedString(@"重新填写",nil);
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:cancelStr];
            [str addAttribute:NSForegroundColorAttributeName value:kGrayColor range:NSMakeRange(0, cancelStr.length)];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                self.accountField.text = self.nameField.text = self.passwordField.text = @"";
                
            }];
            [altc addAction:cancelAction];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"继续",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self registerWithAccount:self.accountField.text withNickname:self.nameField.text withPassword:self.passwordField.text];
                });
            }];
            
            [altc addAction:okAction];
            
            [self presentViewController:altc animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark RegisterForPhoneNum
- (void)registerWithAccount:(NSString *)account withNickname:(NSString *)nickname withPassword:(NSString *)pwd codeStr:(NSString *)code{
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    [HttpRequest registerWithAccount:account withNickname:nickname withVerifyCode:code withPassword:pwd didLoadData:^(id result, NSError *err) {
        if (err) {
            [self performSelectorOnMainThread:@selector(failAction:) withObject:err waitUntilDone:NO];
        }else{
            [self performSelectorOnMainThread:@selector(successAction) withObject:nil waitUntilDone:NO];
        }
    }];
    
}

- (void)failAction:(NSError *)err{
    
    [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    NSString *errStr;
    //    NSInteger code = err.code;
    
    if (err.code == -1009) {
        errStr = NSLocalStr(@"网络错误，请重试");
    }
    else if (err.code==4001005) {
        errStr = NSLocalStr(@"手机号码已注册");
    }else if (err.code == 4001003){
        errStr = NSLocalStr(@"手机验证码不存在");
    }else if(err.code == 4001004){
        errStr = NSLocalStr(@"手机验证码错误");
    }
    else{
        errStr = NSLocalStr(@"注册用户失败");
    }
    
    [self showWarningAlert:errStr];
    
}

- (void)successAction{
    
//    注册成功
    [[NSUserDefaults standardUserDefaults] setObject:self.accountField.text forKey:@"lastLoginAccount"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"lastLoginPwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    switch (self.chooseWhat) {
        case 1:
        {
            [self showWarningAlert:@"注册成功!" didFinish:^{
                
                LoginViewController *loginView = self.navigationController.viewControllers[0];
                [loginView setAccount:self.accountField.text password:self.passwordField.text];
                [self.navigationController popToViewController:loginView animated:YES];
            }];
        }
            break;
        case 2:
        {
            [self showWarningAlert:@"注册成功,请到邮箱查收激活邮件并激活!" didFinish:^{
                
                LoginViewController *loginView = self.navigationController.viewControllers[0];
                [loginView setAccount:self.accountField.text password:self.passwordField.text];
                [self.navigationController popToViewController:loginView animated:YES];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark RegisterForEmail
- (void)registerWithAccount:(NSString *)account withNickname:(NSString *)nickname withPassword:(NSString *)pwd{
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    
    [HttpRequest registerWithAccount:account withNickname:nickname withVerifyCode:nil withPassword:pwd didLoadData:^(id result, NSError *err) {
        if (err) {
            [self performSelectorOnMainThread:@selector(eamilFailAction:) withObject:err waitUntilDone:NO];
        }else{
            [self performSelectorOnMainThread:@selector(successAction) withObject:nil waitUntilDone:NO];
        }
        [hud performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    }];
}

- (void)eamilFailAction:(NSError *)err{
    if (err.code == -1009) {
        UIView *errView = [[UIView alloc]initWithFrame:CGRectMake(0, -66, MainWidth, 66)];
        [self.view.window addSubview:errView];
        [self showWarningAlert:NSLocalizedString(@"网络连接失败，请检查网络是否正常！",nil)];
        
    }
    else if (err.code==4001006) {
        UIView *errView = [[UIView alloc]initWithFrame:CGRectMake(0, -66, MainWidth, 66)];
        [self.view.window addSubview:errView];
        [self showWarningAlert:[NSString stringWithFormat:@"%@%@",self.accountField.text,NSLocalizedString(@"邮箱已被注册，请更换注册邮箱！", nil)]];
    }else{
        UIView *errView = [[UIView alloc]initWithFrame:CGRectMake(0, -66, MainWidth, 66)];
        [self.view.window addSubview:errView];
        [self showWarningAlert:NSLocalizedString(@"注册失败",nil)];
    }
}


#pragma mark - AohtherAction
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
       
        [self.nameField becomeFirstResponder];

        
    }else if ([self.nameField isFirstResponder]){
        [textField endEditing:YES];
        [UIView animateWithDuration:0.2 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, 0);
            
        }];
    }
    
    return YES;
}

-(bool)textFieldShouldBeginEditing:(UITextField *)textField{
    
    switch (self.chooseWhat) {
        case 1:
        {
            if (textField == self.passwordField) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.transform = CGAffineTransformMakeTranslation(0, -90);
                    
                }];
                
            }else if (textField == self.nameField){
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.transform = CGAffineTransformMakeTranslation(0, -160);
                    
                }];

            }
        }
            break;
        case 2:
        {
            if (textField == self.nameField){
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.transform = CGAffineTransformMakeTranslation(0, -90);
                    
                }];
                
            }
        }
            
        default:
            break;
    }
    
    return YES;
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
