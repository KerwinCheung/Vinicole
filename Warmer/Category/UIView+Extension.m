//
//  UIView+Extension.m
//  jingmei2
//
//  Created by 安胜强 on 16/3/22.
//  Copyright © 2016年 Kerwin. All rights reserved.
//

// 最大的尺寸
#define ZCMAXSize CGSizeMake(MAXFLOAT, MAXFLOAT)

// 快速实例
#define Object(Class) [[Class alloc] init];

#import "UIView+Extension.h"

@implementation UIView (Extension)

-(void)AnimationDown{
    CABasicAnimation *positonAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    positonAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    positonAnimation.fromValue = [NSNumber numberWithFloat:0];
    positonAnimation.toValue = [NSNumber numberWithFloat:66];
    
    positonAnimation.duration = 0.25f;
    positonAnimation.fillMode = kCAFillModeForwards;
    
    positonAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:positonAnimation forKey:kCAAnimationRotateAuto];
}

-(void)AnimationUp{
    CABasicAnimation *positonAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    positonAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    positonAnimation.fromValue = [NSNumber numberWithFloat:66];
    positonAnimation.toValue = [NSNumber numberWithFloat:0];
    
    positonAnimation.duration = 0.25f;
    positonAnimation.fillMode = kCAFillModeForwards;
    
    positonAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:positonAnimation forKey:kCAAnimationRotateAuto];
}

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (CGFloat)MaxX
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)MaxY
{
    return CGRectGetMaxY(self.frame);
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}



/** 水平居中 */
- (void)alignHorizontal
{
    self.x = (self.superview.width - self.width) * 0.5;
}

/** 垂直居中 */
- (void)alignVertical
{
    self.y = (self.superview.height - self.height) * 0.5;
}

/** 添加子控件 */
- (void)addSubview:(Class)classs propertyName:(NSString *)propertyName
{
    id subView = Object(classs);
    if ([self isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)self;
        [cell.contentView addSubview:subView];
    } else {
        [self addSubview:subView];
    }
    [self setValue:subView forKeyPath:propertyName];
}



@end
