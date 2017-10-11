//
//  UINavigationController+PushViewControllerWithAnimated.m
//  lightify
//
//  Created by xtmac on 21/1/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "UINavigationController+PushViewControllerWithAnimated.h"

@implementation UINavigationController (PushViewControllerWithAnimated)

-(void)pushViewControllerWithAnimated:(UIViewController *)viewController{
    [self pushViewController:viewController animated:YES];
}

-(void)popViewControllerWithAnimated{
    [self popViewControllerAnimated:YES];
}

-(void)popToRootViewControllerWithAnimated{
    [self popToRootViewControllerAnimated:YES];
}

- (void)pushViewControllerWithPopUpAnimated:(UIViewController *)viewController{
    [self.view.layer addAnimation:ButtonUpCatranstion forKey:nil];
    [self pushViewController:viewController animated:NO];
}

-(void)popViewControllerWithPopDownAnimated{
    [self.view.layer addAnimation:ButtonDownCatranstion forKey:nil];
    [self popViewControllerAnimated:NO];
}

@end
