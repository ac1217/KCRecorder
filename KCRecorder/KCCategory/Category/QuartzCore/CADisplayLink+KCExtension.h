//
//  CADisplayLink+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/7/8.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CADisplayLink (KCExtension)

+ (CADisplayLink *)kc_displayLinkWithBlock:(void(^)(CADisplayLink *link))block;

@end
