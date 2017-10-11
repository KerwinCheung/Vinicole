//
//  DataPointObject.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/30.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 [{"index":0,"type":1},
  {"index":1,"type":1},
  {"index":2,"type":1},
  {"index":3,"type":1},
  {"index":4,"type":1},
  {"index":5,"type":1},
  {"index":6,"type":1},
  {"index":7,"type":1},
  {"index":8,"type":1},
  {"index":9,"type":1},
  {"index":10,"type":2},
  {"index":11,"type":2},
  {"index":12,"type":2},
  {"index":13,"type":2} 
 ]
*/

@interface DataPointObject : NSObject

@property (nonatomic,assign)int index;
@property (nonatomic,assign)int type;
@property (nonatomic,assign)int value;

@end
