//
//  NSDate+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KCExtension)

/*
 * 通过时间戳获取日期字符串
 */
+ (NSString *)kc_dateStringWithTimeInterval:(NSTimeInterval)time formatter:(NSString *)fmt;
/*
 * 获取时间字符串
 */
- (NSString *)kc_dateStringWithFormatter:(NSString *)fmt;

/**
 *  判断某个时间是否为今年
 */
- (BOOL)kc_isThisYear;
/**
 *  判断某个时间是否为昨天
 */
- (BOOL)kc_isYesterday;
/**
 *  判断某个时间是否为今天
 */
- (BOOL)kc_isToday;

/*
 * 处理某个时间到当前时间的间隔，并返回格式化好的时间字符串（新浪微博时间处理效果）
 */
- (NSString *)kc_weiboFormat;
- (NSString *)kc_wechatFormat;

/*
 * 今天0点
 */
+ (NSDate *)kc_todayZero;

@end
