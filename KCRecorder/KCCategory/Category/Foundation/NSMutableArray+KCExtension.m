//
//  NSMutableArray+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/21.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "NSMutableArray+KCExtension.h"
#import <objc/message.h>

@implementation NSMutableArray (KCExtension)


+ (void)load
{
    Class cls = [self class];
    
    Method addObj1 = class_getInstanceMethod(cls, @selector(addObject:));
    
    Method addObj2 = class_getInstanceMethod(cls, @selector(kc_addObject:));
    method_exchangeImplementations(addObj1 , addObj2);
    
    
    Method insertObj1 = class_getInstanceMethod(cls, @selector(insertObject:atIndex:));
    
    Method insertObj2 = class_getInstanceMethod(cls, @selector(kc_insertObject:atIndex:));
    
    method_exchangeImplementations(insertObj1 , insertObj2);
}

- (void)kc_addObject:(id)anObject
{
    
#if DEBUG
    
#else
    if (!anObject) {
        
        NSLog(@"警告：(Array:%@)添加的对象为nil",self);
        
        return;
    }
#endif
    
    [self kc_addObject:anObject];
    
}

- (void)kc_insertObject:(id)anObject atIndex:(NSUInteger)index
{
  
#if DEBUG
    
#else
    if (!anObject) {
        
        NSLog(@"警告：(Array:%@)添加的对象为nil", self);
        
        return;
    }
    
    if (index >= self.count || index < 0) {
        
        NSLog(@"警告：(Array:%@)数组越界index=%zd,count=%zd", self, index, self.count);
        
        return;
    }
#endif
    
    
    
    [self kc_insertObject:anObject atIndex:index];
}

@end
