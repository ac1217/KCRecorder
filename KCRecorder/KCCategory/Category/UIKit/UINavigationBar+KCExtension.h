//
//  UINavigationBar+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/7.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (KCExtension)

@property (nonatomic, assign) CGFloat kc_backgroundAlpha;
@property (nonatomic, assign) BOOL kc_backgroundHidden;

- (void)kc_setBackgroundHidden:(BOOL)hidden animate:(BOOL)animate;

@end
