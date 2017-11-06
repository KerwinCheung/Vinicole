 //
//  BaseViewController.m
//  EAWADA
//
//  Created by apple on 16/10/8.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        
    }];
    [self.view endEditing:YES];
    
}

-(UIAlertController *)showWarningAlert:(NSString *)msg{
    return [self showWarningAlert:NSLocalStr(msg) didFinish:nil];
}

-(UIAlertController *)showWarningAlert:(NSString *)msg didFinish:(void (^)(void))finish{
    return [self showWarningAlert:msg withTitle:@"提示" didFinish:finish];
}

-(UIAlertController *)showWarningAlert:(NSString *)msg withTitle:(NSString *)title didFinish:(void (^)(void))finish{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (finish != nil) {
            finish();
        }
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:true completion:nil];
    return alertController;
}

- (id)loadViewControllerWithStoryboardName:(NSString *)sbName withViewControllerName:(NSString *)vcName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:sbName bundle:nil];
    //    Class class = NSClassFromString(vcName);
    id viewController = [storyboard instantiateViewControllerWithIdentifier:vcName];
    return viewController;
}

- (IBAction)LeftBarBtnActin:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
