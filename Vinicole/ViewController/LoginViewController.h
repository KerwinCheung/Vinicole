//
//  LoginViewController.h
//  Warmer
//
//  Created by apple on 2016/11/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController


-(void)AutoLogin;

-(void)setAccount:(NSString *)account password:(NSString *)password;
@end
