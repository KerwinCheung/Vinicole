//
//  DataManage.h
//  lightify
//
//  Created by xtmac on 4/3/16.
//  Copyright © 2016年 xlink.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManage : NSObject

+(DataManage *)share;

-(void)start;
-(void)stop;

-(void)tryConnect;
@end
