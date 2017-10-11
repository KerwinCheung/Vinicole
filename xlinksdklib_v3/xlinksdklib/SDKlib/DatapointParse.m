//
//  DatapointParse.m
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/30.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#import "DatapointParse.h"
#import "SDKHeader.h"
#import "DataPointObject.h"

@implementation DatapointParse

+(NSArray *)parseDataPointBuffer:(NSMutableData *)buf andParseTemplate:(NSString *)dataPointModel {
    
    NSLog(@"===================%lu",(unsigned long)buf.length);
    __b1 b[buf.length];
    [buf getBytes:b length:buf.length];
    for (int i = 0; i<buf.length; i++) {
        NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$%02x",b[i]);
    }
    
    NSMutableArray * dpCollect = [[NSMutableArray alloc]init];
    
    NSError *err;
    
    NSArray *arrTemplate = [NSJSONSerialization JSONObjectWithData:[dataPointModel dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
    
    if (err) {
        NSLog(@"%@",err);
        return nil;
    }
    
    int row = (int)arrTemplate.count/8;
    
    int col = (int)arrTemplate.count%8;
    
    if (col!=0) {
        row ++;
    }
    
    __b1 validate[row];
    
    [buf getBytes:validate length:row];
    
    int footPrint = row;
    
    for (int i = 0; i<row; i++) {
        __b1 temp = validate[i];
        for (int j=0; j<8; j++) {
            
            int index = i * 8 + j;
            BOOL flag =  temp>>j&1;
            if (flag) {
                if (index < arrTemplate.count) {
                    DataPointObject * tempObjt = [[DataPointObject alloc]init];
                   
                    id dpTemplate = arrTemplate[index];
                    
                    tempObjt.type = [[dpTemplate objectForKey:@"type"]intValue];
                    
                    tempObjt.index = [[dpTemplate objectForKey:@"index"]intValue];
                    
                    switch (tempObjt.type) {
                        case 1:
                        {
                            __b1 vl;
                            [buf getBytes:&vl range:NSMakeRange(footPrint, 1)];
                            tempObjt.value = vl;
                            footPrint+=1;
                        }
                            break;
                        case 2:
                        {
                            __b2 vl;
                            [buf getBytes:&vl range:NSMakeRange(footPrint, 2)];
                            tempObjt.value = ntohs(vl);
                            NSLog(@"***************%d",footPrint);
                            
                            footPrint+=2;
                        }
                            break;
                        case 4:
                        {
                            __b4 vl;
                            [buf getBytes:&vl range:NSMakeRange(footPrint, 4)];
                            tempObjt.value = ntohl(vl);
                            footPrint+=4;
                        }
                            break;
                        default:
                            break;
                    }
                    
                    [dpCollect addObject:tempObjt];
                    
                }
            }
        }
    }
    
    for (DataPointObject *dp in dpCollect) {
        NSLog(@"index %d type %d value %d",dp.index,dp.type,dp.value);
    }

    return dpCollect;
}

+(NSMutableData *)bufferDataWithIndex:(int )index andValue:(int )vlu forParseTemplate:(NSString *)dataPointModel{

    NSMutableData *buf = [[NSMutableData alloc]init];
    int buflength=0;
    NSArray * arr = [NSJSONSerialization JSONObjectWithData:[dataPointModel dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    
//    __b1 valide1 = 1<<5;
//    __b1 valide2 = 0;
    
    int row = (int)arr.count/8;
    int col = (int)arr.count%8;
    
    if (col!=0) {
        row ++;
    }
    
    
    for (int i=0; i<arr.count; i++) {
        id temp =arr[i];
        int step = [[temp objectForKey:@"type"]intValue];
        buflength+=step;
        
    }
    
    for (int i=0; i<index; i++) {
        
        
        
    }
    
    buflength+=row;
    [buf resetBytesInRange:NSMakeRange(0, buflength)];
    
    
    int rindex = index/8;
    int cindex = index%8;
    
    for (int i = 0; i<row; i++) {
        if (i==rindex) {
            __b1 value = 1<<cindex;
            [buf appendBytes:&value length:1];
        }else{
            __b1 value =0;
            [buf appendBytes:&value length:1];
        }
    }
    
    
    
    //[buf appendBytes:&valide1 length:1];
    //[buf appendBytes:&valide2 length:1];
    
    for (int i=0; i<arr.count; i++) {
        
        id temp = arr[i];
        
        int tempType = [[temp objectForKey:@"type"] intValue];
        
        
            switch (tempType)
            {
                case 1:
                {
                    __b1 value =vlu;
                    [buf appendBytes:&value length:1];
                }
                    break;
                case 2:
                {
                    
                    __b2 temp =vlu;
                    __b2 value = htons(temp);
                    [buf appendBytes:&value length:2];
                
                }
                    break;
                case 4:
                {
                    __b4 value = htonl(vlu);
                    
                    
                    [buf appendBytes:&value length:4];
                }
                    break;
                default:
                    break;
            }
        
    }
    
    return buf;
    
}


@end
