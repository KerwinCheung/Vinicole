//
//  CATransition+Extension.h
//  CbyGE
//
//  Created by AllenKwok on 16/1/22.
//  Copyright © 2016年 Xlink.cn. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define ButtonUpCatranstion [CATransition buttonUpCatranstion]
#define ButtonDownCatranstion [CATransition buttonDownCatranstion]
#define ButtonRightCatranstion [CATransition buttonRightCatranstion]

@interface CATransition (Extension2)

+ (instancetype)buttonUpCatranstion;

+ (instancetype)buttonDownCatranstion;

+ (instancetype)buttonRightCatranstion;

@end
