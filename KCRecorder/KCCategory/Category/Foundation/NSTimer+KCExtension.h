//
//  NSTimer+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/7/8.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (KCExtension)

+ (NSTimer *)kc_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

+ (NSTimer *)kc_timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

@end
