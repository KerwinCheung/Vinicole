//
//  NSTools.h
//  lightify
//
//  Created by xtmac on 23/2/16.
//  Copyright © 2016年 xtmac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct CalendarDate{
    UInt16  year;
    UInt8   month;
    UInt8   day;
    UInt8   hour;
    UInt8   minute;
    UInt8   second;
}CalendarDate;

@interface NSTools : NSObject

+(CalendarDate)dateToCalendar:(NSDate *)date;

+(NSDate *)calendarToDate:(CalendarDate)calendarDate;

+(NSString *)dataToHex:(NSData *)data;

+(NSData *)hexToData:(NSString *)hexString;

/**
 *  判断文件是否存在
 *
 *  @param checkFile 文件路径
 *
 *  @return 文件是否存在
 */
+(BOOL) fileIsExists:(NSString*) checkFile;

/**
 *  邮箱正则表达式
 *
 *  @param email 邮箱地址
 *
 *  @return 是否正确的邮箱地址
 */
+(BOOL)validateEmail:(NSString *)email;

/**
 *  手机号码正则表达式
 *
 *  @param phone 手机号码
 *
 *  @return 是否正确的手机号码
 */
+(BOOL)validatePhone:(NSString *)phone;

/**
 *  判断密码强度 必须字母加数字 6位以上
 *
 *  @param password 密码
 *
 *  @return 通过返回YES
 */
+ (BOOL)validatePassword:(NSString *)password;

+ (BOOL)validateName:(NSString *)password;
@end
