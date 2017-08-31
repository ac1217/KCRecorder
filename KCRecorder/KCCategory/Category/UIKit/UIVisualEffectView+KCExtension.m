//
//  UIVisualEffectView+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/9/13.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UIVisualEffectView+KCExtension.h"

@implementation UIVisualEffectView (KCExtension)


+ (instancetype)kc_blurEffectViewWithBlurEffectStyle:(UIBlurEffectStyle)style
{
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
//    UIVibrancyEffect *effect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:style]];
    return [[UIVisualEffectView alloc] initWithEffect:effect];
}

@end
