//
//  UIView+Extension.h
//  jingmei2
//
//  Created by 安胜强 on 16/3/22.
//  Copyright © 2016年 Kerwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat MaxX;
@property (nonatomic, assign) CGFloat MaxY;

/** 水平居中 */
- (void)alignHorizontal;
/** 垂直居中 */
- (void)alignVertical;
/** 添加子控件 */
- (void)addSubview:(Class)classs propertyName:(NSString *)propertyName;

@end
