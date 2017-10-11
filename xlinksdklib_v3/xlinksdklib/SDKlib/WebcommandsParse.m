//
//  WebcommandsParse.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/31.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "WebcommandsParse.h"

static WebcommandsParse *_shareObjected = nil;

@implementation WebcommandsParse

+(WebcommandsParse *)sharedObject{
    @synchronized(self){
        if (_shareObjected == nil) {
            _shareObjected = [[WebcommandsParse alloc]init];
        }
    }
    return _shareObjected;
}


-(void)parseWebcommandParse:(NSString *)commands{
    
//    [NSJSONSerialization JSONObjectWithData:nil options:0 error:nil];
    
    
    

}



@end
