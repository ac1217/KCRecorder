//
//  NSAttributedString+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 2016/10/12.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "NSAttributedString+KCExtension.h"

@implementation NSAttributedString (KCExtension)


+ (instancetype)kc_attributedStringWithString:(NSString *)string font:(UIFont *)font textColor:(UIColor *)textColor
{
    
    return [[self alloc] initWithString:string attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName: textColor}];
    
}

+ (instancetype)kc_attributedStringWithString:(NSString *)string font:(UIFont *)font
{
    
    return [[self alloc] initWithString:string attributes:@{NSFontAttributeName : font}];
}

+ (instancetype)kc_attributedStringWithString:(NSString *)string textColor:(UIColor *)textColor
{
    
    return [[self alloc] initWithString:string attributes:@{ NSForegroundColorAttributeName: textColor}];
}


@end
