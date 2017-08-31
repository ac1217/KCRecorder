//
//  UIColor+KCExtension.m
//  hiyd
//
//  Created by zhangweiwei on 16/5/19.
//  Copyright © 2016年 ouj. All rights reserved.
//

#import "UIColor+KCExtension.h"

@implementation UIColor (KCExtension)


+ (UIColor *)kc_colorWithHexValue:(unsigned)hexValue {

    return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 green:((hexValue & 0xFF00) >> 8)/255.0 blue:(hexValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)kc_colorWithHexString:(NSString *)hexString
{
    
    
    if ([hexString hasPrefix:@"0x"]) {
        hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }else if ([hexString hasPrefix:@"#"]) {
        
        hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [self kc_colorWithHexValue:rgbValue];
}


@end
