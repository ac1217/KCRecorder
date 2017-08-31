//
//  UIViewController+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/7.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KCExtension)

@property (nonatomic, assign) CGFloat kc_navgationBarBackgroundAlpha;
@property (nonatomic, assign) BOOL kc_navgationBarBackgroundHidden;


- (void)kc_setNavigationBarBackgroundHidden:(BOOL)hidden animate:(BOOL)animate;

/**
 *  快速从SB加载对应控制器
 *
 *  @param sbName SB名字，必须在Main bundle内。控制器ID为对应类名。
 *
 *  @return sb内控制器
 */
+ (instancetype)kc_viewControllerFromStoryboard:(NSString *)sbName;
/**
 *  下面指定控制器的id
 */
+ (instancetype)kc_viewControllerFromStoryboard:(NSString *)sbName identifier:(NSString *)ID;

@end
