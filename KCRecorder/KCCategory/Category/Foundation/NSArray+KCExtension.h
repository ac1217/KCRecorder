//
//  NSArray+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (KCExtension)
// 数组元素倒序
- (instancetype)kc_reverseObjects;


- (instancetype)kc_map:(id(^)(id obj))block;

- (instancetype)kc_filter:(BOOL(^)(id obj))block;

@end
