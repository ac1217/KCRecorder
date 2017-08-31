//
//  UIColor+KCExtension.h
//  hiyd
//
//  Created by zhangweiwei on 16/5/19.
//  Copyright © 2016年 ouj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (KCExtension)

+ (UIColor *)kc_colorWithHexValue:(unsigned)hexValue;

+ (UIColor *)kc_colorWithHexString:(NSString *)hexString;
@end
