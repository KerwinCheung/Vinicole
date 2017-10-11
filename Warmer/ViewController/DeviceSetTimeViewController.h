//
//  DeviceSetTimeViewController.h
//  Warmer
//
//  Created by Apple on 2017/6/24.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "BaseViewController.h"

@interface DeviceSetTimeViewController : BaseViewController

 /*
 1=豆浆 2=鲜玉米糊 3=烧水 4=绿豆/迷糊
 */
@property (nonatomic ,assign) NSInteger doWhat;

@property (nonatomic,strong) DeviceModel *deviceModel;

@end
