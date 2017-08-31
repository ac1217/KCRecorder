//
//  UIViewController+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/7.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UIViewController+KCExtension.h"
#import "UINavigationBar+KCExtension.h"

@implementation UIViewController (KCExtension)

- (void)setKc_navgationBarBackgroundHidden:(BOOL)kc_navgationBarBackgroundHidden
{
    self.navigationController.navigationBar.kc_backgroundHidden = kc_navgationBarBackgroundHidden;
}

- (BOOL)kc_navgationBarBackgroundHidden
{
    return self.navigationController.navigationBar.kc_backgroundHidden;
}

- (void)setKc_navgationBarBackgroundAlpha:(CGFloat)navgationBarBackgroundAlpha
{
    self.navigationController.navigationBar.kc_backgroundAlpha = navgationBarBackgroundAlpha;
    
}

- (CGFloat)kc_navgationBarBackgroundAlpha
{
    return self.navigationController.navigationBar.kc_backgroundAlpha;
}

- (void)kc_setNavigationBarBackgroundHidden:(BOOL)hidden animate:(BOOL)animate
{
    [self.navigationController.navigationBar kc_setBackgroundHidden:hidden animate:animate];
}

+ (instancetype)kc_viewControllerFromStoryboard:(NSString *)sbName
{
  return [self kc_viewControllerFromStoryboard:sbName identifier:NSStringFromClass(self)];
}


+ (instancetype)kc_viewControllerFromStoryboard:(NSString *)sbName identifier:(NSString *)ID
{
    
    return [[UIStoryboard storyboardWithName:sbName bundle:nil] instantiateViewControllerWithIdentifier:ID];
}

@end
