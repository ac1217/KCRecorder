//
//  UIImageView+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UIImageView+KCExtension.h"
#import "UIImage+KCExtension.h"

@implementation UIImageView (KCExtension)

- (void)kc_blurEffectWithStyle:(UIBlurEffectStyle)style
{
    UIVisualEffectView *effectview = nil;
    for (UIVisualEffectView *view in self.subviews) {
        if ([view isKindOfClass:[UIVisualEffectView class]]) {
            effectview = view;
            break;
        }
    }
    
    if (!effectview) {
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:style];
        effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        [self addSubview:effectview];
    }
    
    effectview.frame = self.bounds;

}

@end
