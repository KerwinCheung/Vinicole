//
//  CATransition+Extension.m
//  CbyGE
//
//  Created by AllenKwok on 16/1/22.
//  Copyright © 2016年 Xlink.cn. All rights reserved.
//

#import "CATransition+Extension2.h"

#define animationTime 0.25

@implementation CATransition (Extension2)

+ (instancetype)buttonUpCatranstion{
    // 创建CATransition对象 不要写成: CATransaction
    CATransition *animation = [CATransition animation];
    animation.type = @"moveIn";
    // 设置动画方向
    animation.subtype = kCATransitionFromTop;
    // 动画时间
    animation.duration = animationTime;
    // 设置动画速率(可变的)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    return animation;
}

+ (instancetype)buttonDownCatranstion{
    // 创建CATransition对象 不要写成: CATransaction
    CATransition *animation = [CATransition animation];
    animation.type = @"reveal";
    // 设置动画方向
    animation.subtype = kCATransitionFromBottom;
    // 动画时间
    animation.duration = animationTime;
    // 设置动画速率(可变的)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    return animation;
}

+ (instancetype)buttonRightCatranstion{
    // 创建CATransition对象 不要写成: CATransaction
    CATransition *animation = [CATransition animation];
    animation.type = @"reveal";
    // 设置动画方向
    animation.subtype = kCATransitionFromLeft;
    // 动画时间
    animation.duration = animationTime;
    // 设置动画速率(可变的)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    return animation;
}

@end
