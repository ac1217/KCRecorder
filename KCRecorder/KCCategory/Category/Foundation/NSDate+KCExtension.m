//
//  NSDate+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "NSDate+KCExtension.h"


@implementation NSDateFormatter (KCExtension)

+ (instancetype)sharedDateFormatter {
    
    static id instance_;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[NSDateFormatter alloc] init];
    });
    return instance_;
    
}

@end

@implementation NSDate (KCExtension)


+ (NSString *)kc_dateStringWithTimeInterval:(NSTimeInterval)time formatter:(NSString *)fmt
{
    return [[NSDate dateWithTimeIntervalSince1970:time] kc_dateStringWithFormatter:fmt];
}

- (NSString *)kc_dateStringWithFormatter:(NSString *)fmt
{
    NSDateFormatter *dateFmt = [NSDateFormatter sharedDateFormatter];
    dateFmt.dateFormat = fmt;
    return [dateFmt stringFromDate:self];
}

/**
 *  判断某个时间是否为今年
 */
- (BOOL)kc_isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 获得某个时间的年月日时分秒
    NSDateComponents *dateCmps = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *nowCmps = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return dateCmps.year == nowCmps.year;
}

/**
 *  判断某个时间是否为昨天
 */
- (BOOL)kc_isYesterday { return [[NSCalendar currentCalendar] isDateInYesterday:self]; }

/**
 *  判断某个时间是否为今天
 */
- (BOOL)kc_isToday { return [[NSCalendar currentCalendar] isDateInToday:self]; }

- (NSString *)kc_weiboFormat
{
    NSDateFormatter *fmt = [NSDateFormatter sharedDateFormatter];;
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    // 微博的创建日期
    // 当前时间
    NSDate *now = [NSDate date];
    
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 计算两个日期之间的差值
    NSDateComponents *cmps = [calendar components:unit fromDate:self toDate:now options:0];
    
    if ([self kc_isThisYear]) { // 今年
        if ([self kc_isYesterday]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:self];
        } else if ([self kc_isToday]) { // 今天
            if (cmps.hour >= 1) {
                return [NSString stringWithFormat:@"%d小时前", (int)cmps.hour];
            } else if (cmps.minute >= 1) {
                return [NSString stringWithFormat:@"%d分钟前", (int)cmps.minute];
            } else {
                return @"1分钟内";
            }
        } else { // 今年的其他日子
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:self];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:self];
    }

}


- (NSString *)kc_wechatFormat
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if (self.kc_isThisYear) {
        
       NSDateComponents *cmps = [calendar components:NSCalendarUnitHour fromDate:self];
        
        NSInteger hour = cmps.hour;
        
        if (self.kc_isToday) {
            
            if (hour > 0 && hour < 6) {
                return [self kc_dateStringWithFormatter:@"凌晨hh:mm"];
            }else if (hour >= 6 && hour < 12) {
                
                return [self kc_dateStringWithFormatter:@"上午hh:mm"];
            }else if (hour >= 12 && hour < 18) {
                
                return [self kc_dateStringWithFormatter:@"下午hh:mm"];
            }else {
                
                return [self kc_dateStringWithFormatter:@"晚上hh:mm"];
            }
            
        }else if (self.kc_isYesterday) {
            
            if (hour > 0 && hour < 6) {
                return [self kc_dateStringWithFormatter:@"昨天 凌晨hh:mm"];
            }else if (hour >= 6 && hour < 12) {
                
                return [self kc_dateStringWithFormatter:@"昨天 上午hh:mm"];
            }else if (hour >= 12 && hour < 18) {
                
                return [self kc_dateStringWithFormatter:@"昨天 下午hh:mm"];
            }else {
                
                return [self kc_dateStringWithFormatter:@"昨天 晚上hh:mm"];
            }
            
            
        }else {
            
            NSDate *now = [NSDate date];
            NSDateComponents *deltaCmps = [calendar components:NSCalendarUnitDay fromDate:self toDate:now options:0];
            
            NSDateComponents *cmps = [calendar components:NSCalendarUnitWeekday fromDate:self];
            
            NSInteger days = deltaCmps.day;
            NSInteger weeks = cmps.weekday;
            
            if (days > 7) {
                return [self kc_dateStringWithFormatter:@"yyyy-MM-dd"];
            }else {
                NSArray *weekString = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
                
                
                if (hour > 0 && hour < 6) {
                    return [self kc_dateStringWithFormatter:[NSString stringWithFormat:@"%@ 凌晨hh:mm", weekString[weeks - 1]]];
                }else if (hour >= 6 && hour < 12) {
                    
                    return [self kc_dateStringWithFormatter:[NSString stringWithFormat:@"%@ 上午hh:mm", weekString[weeks - 1]]];
                }else if (hour >= 12 && hour < 18) {
                    
                    return [self kc_dateStringWithFormatter:[NSString stringWithFormat:@"%@ 下午hh:mm", weekString[weeks - 1]]];
                }else {
                    
                    return [self kc_dateStringWithFormatter:[NSString stringWithFormat:@"%@ 晚上hh:mm", weekString[weeks - 1]]];
                }
            }
            
        }
        
    }else {
        return [self kc_dateStringWithFormatter:@"yyyy-MM-dd"];
    }
    
    
}


+ (NSDate *)kc_todayZero
{
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    NSDate *today = [calendar dateFromComponents:components];
    
    return today;

}

@end
