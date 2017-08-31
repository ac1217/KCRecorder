//
//  CADisplayLink+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/7/8.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "CADisplayLink+KCExtension.h"
#import <objc/runtime.h>

@implementation CADisplayLink (KCExtension)

static NSString *KCDisplayLinkBlockKey = @"KCDisplayLinkBlockKey";

+ (void)kc_block:(CADisplayLink *)link {
    
    void(^block)(CADisplayLink *link) = objc_getAssociatedObject(self, (__bridge const void *)(KCDisplayLinkBlockKey));
    
    if (block) {
        block(link);
    }
}

+ (CADisplayLink *)kc_displayLinkWithBlock:(void(^)(CADisplayLink *link))block
{
    objc_setAssociatedObject(self, (__bridge const void *)(KCDisplayLinkBlockKey), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return [CADisplayLink displayLinkWithTarget:self selector:@selector(kc_block:)];
}

@end
