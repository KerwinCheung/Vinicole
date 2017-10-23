//
//  BaseViewController.h
//  EAWADA
//
//  Created by apple on 16/10/8.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

-(UIAlertController *)showWarningAlert:(NSString *)msg;
-(UIAlertController *)showWarningAlert:(NSString *)msg didFinish:(void (^)(void))finish;
-(UIAlertController *)showWarningAlert:(NSString *)msg withTitle:(NSString *)title didFinish:(void (^)(void))finish;


- (id)loadViewControllerWithStoryboardName:(NSString *)sbName withViewControllerName:(NSString *)vcName;

@end
