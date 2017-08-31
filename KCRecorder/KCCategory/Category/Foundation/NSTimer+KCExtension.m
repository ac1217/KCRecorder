//
//  NSTimer+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/7/8.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "NSTimer+KCExtension.h"

@implementation NSTimer (KCExtension)

+ (void)kc_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)kc_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(kc_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)kc_timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(kc_ExecBlock:) userInfo:[block copy] repeats:repeats];
}
@end
