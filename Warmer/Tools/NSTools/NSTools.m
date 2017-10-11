//
//  NSTools.m
//  lightify
//
//  Created by xtmac on 23/2/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import "NSTools.h"

@implementation NSTools

+(NSString *)dataToHex:(NSData *)data{
    NSMutableString *hex = [NSMutableString string];
    const unsigned char *hexChar = data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        [hex appendFormat:@"%02x", hexChar[i]];
    }
    return [NSString stringWithString:hex];
}

+(NSData *)hexToData:(NSString *)hexString{
    NSUInteger len = hexString.length / 2;
    const char *hexCode = [hexString UTF8String];
    char * bytes = (char *)malloc(len);
    
    char *pos = (char *)hexCode;
    for (NSUInteger i = 0; i < hexString.length / 2; i++) {
        sscanf(pos, "%2hhx", &bytes[i]);
        pos += 2 * sizeof(char);
    }
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

+(CalendarDate)dateToCalendar:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dd = [cal components:unitFlags fromDate:date];
    CalendarDate calendarDate;
    calendarDate.year = [dd year];
    calendarDate.month = [dd month];
    calendarDate.day = [dd day];
    calendarDate.hour = [dd hour];
    calendarDate.minute = [dd minute];
    calendarDate.second = [dd second];
    return calendarDate;
}

+(NSDate *)calendarToDate:(CalendarDate)calendarDate{
    NSString *dateString = [NSString stringWithFormat:@"%d-%d-%d %d:%d:%d", calendarDate.year, calendarDate.month, calendarDate.day, calendarDate.hour, calendarDate.minute, calendarDate.second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter dateFromString:dateString];
}

//判断文件是否存在

+(BOOL) fileIsExists:(NSString*) checkFile{
    return  [[NSFileManager defaultManager]fileExistsAtPath:checkFile];
}

#pragma mark 邮箱正则表达式
+(BOOL)validateEmail:(NSString *)email{
    
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:email];
    
}


#pragma mark 手机号码正则表达式
+(BOOL)validatePhone:(NSString *)phone{
    
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:phone];
}


/**
 *  密码不能含有英文和数字以外的字符
 *  密码必须为6-20位
 */
#pragma mark 密码正则表达式
+ (BOOL)validatePassword:(NSString *)password {
    NSString *regex = @"^[!-~]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password];
    
    
}

#pragma mark 昵称正则表达式
+ (BOOL)validateName:(NSString *)password {
    NSString *regex = @"^((?=[\x21-\x7e]+))$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:password]) {
        NSLog(@"yes yes yes");
    }else{
        NSLog(@"no no no");
    }
    return [pred evaluateWithObject:password];
}
@end
