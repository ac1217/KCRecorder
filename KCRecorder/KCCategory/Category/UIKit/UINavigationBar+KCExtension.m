//
//  UINavigationBar+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/7.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UINavigationBar+KCExtension.h"
#import "KCConst.h"

@implementation UINavigationBar (KCExtension)

- (void)setKc_backgroundAlpha:(CGFloat)kc_backgroundAlpha
{
    
    [self.subviews.firstObject setAlpha:kc_backgroundAlpha];
    
}

- (CGFloat)kc_backgroundAlpha
{
    return [self.subviews.firstObject alpha];
}

- (void)setKc_backgroundHidden:(BOOL)kc_backgroundHidden
{
    self.kc_backgroundAlpha = !kc_backgroundHidden;
}

- (BOOL)kc_backgroundHidden
{
    return !self.kc_backgroundAlpha;
}


- (void)kc_setBackgroundHidden:(BOOL)hidden animate:(BOOL)animate
{
    
    if (animate) {
        [UIView animateWithDuration:KCDefaultAnimationDuration animations:^{
            self.kc_backgroundHidden = hidden;
        }];
    }else {
        self.kc_backgroundHidden = hidden;
    }
}

@end
