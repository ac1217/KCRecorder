//
//  NSAttributedString+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 2016/10/12.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (KCExtension)

+ (instancetype)kc_attributedStringWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor;

+ (instancetype)kc_attributedStringWithString:(NSString *)string font:(UIFont *)font;

+ (instancetype)kc_attributedStringWithString:(NSString *)string textColor:(UIColor *)textColor;


@end
