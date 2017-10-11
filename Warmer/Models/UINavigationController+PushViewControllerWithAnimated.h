//
//  UINavigationController+PushViewControllerWithAnimated.h
//  lightify
//
//  Created by xtmac on 21/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (PushViewControllerWithAnimated)

-(void)pushViewControllerWithAnimated:(UIViewController *)viewController;

-(void)popViewControllerWithAnimated;

-(void)popToRootViewControllerWithAnimated;

/**
 *  以向上弹出方式push页面
 */
- (void)pushViewControllerWithPopUpAnimated:(UIViewController *)viewController;

/**
 *  以向下弹出方式pop页面
 */
-(void)popViewControllerWithPopDownAnimated;

@end
