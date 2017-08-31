//
//  NSMutableDictionary+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/21.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "NSMutableDictionary+KCExtension.h"
#import <objc/message.h>

@implementation NSMutableDictionary (KCExtension)

+ (void)load
{
    Class cls = [self class];
    
    Method setObjForKey1 = class_getInstanceMethod(cls, @selector(setObject:forKey:));
    
    Method setObjForKey2 = class_getInstanceMethod(cls, @selector(kc_setObject:forKey:));
    
    method_exchangeImplementations(setObjForKey1 , setObjForKey2);
}

- (void)kc_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    
    if (!anObject) {
        
        NSLog(@"警告：(Dictionary:%@)添加的对象为nil",self);
        
        return;
    }
    
    [self kc_setObject:anObject forKey:aKey];
}

@end
