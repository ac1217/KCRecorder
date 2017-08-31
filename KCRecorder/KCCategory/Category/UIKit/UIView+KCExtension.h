//
//  UIView+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KCExtension)
/*
 * 快速设置frame、center、size
 */
@property (nonatomic, assign) CGFloat kc_x;
@property (nonatomic, assign) CGFloat kc_y;
@property (nonatomic, assign) CGFloat kc_maxX;
@property (nonatomic, assign) CGFloat kc_maxY;
@property (nonatomic, assign) CGFloat kc_centerX;
@property (nonatomic, assign) CGFloat kc_centerY;
@property (nonatomic, assign) CGFloat kc_width;
@property (nonatomic, assign) CGFloat kc_height;
@property (nonatomic, assign) CGSize kc_size;

/*
 * transform后获取四个点真实坐标
 */
// 原来的frame
-(CGRect)kc_originalFrameAfterTransform;
// 以下为4个点坐标
-(CGPoint)kc_topLeftAfterTransform;
-(CGPoint)kc_topRightAfterTransform;
-(CGPoint)kc_bottomLeftAfterTransform;
-(CGPoint)kc_bottomRightAfterTransform;

/*
 * 截取view上正在显示的内容
 */
// 整个view内容截取
- (UIImage *)kc_screenshot;
// 指定区域截取
- (UIImage *)kc_screenshotWithRect:(CGRect)rect;

/**
 *  是否显示在屏幕上
 */
- (BOOL)kc_isDisplayOnScreen;

/*
 * 快速创建分割线view
 */
// 白色分割线
+ (instancetype)kc_whiteSeparator;
// 黑色分割线
+ (instancetype)kc_blackSeparator;

/*
 * 加载XIB
 */
// 从xib加载view
+ (instancetype)kc_viewFromXib;
// 获取view的xib对象
+ (UINib *)kc_xib;

/*
 * 显示红点, 默认在右上角
 */
@property (nonatomic, strong) UIFont *kc_badgeFont;
@property (nonatomic, strong) UIColor *kc_badgeColor;
@property (nonatomic, copy) NSString *kc_badgeValue;
@property (nonatomic, strong) UIColor *kc_badgeBackgroundColor;
- (void)kc_setBadgeValue:(NSString *)badgeValue offset:(CGPoint)offset;

/*
 * 图层相关
 */
@property (nonatomic, strong) UIColor *kc_layerBackgroundColor;
@property (nonatomic, strong) UIColor *kc_layerBorderColor;
@property (nonatomic, assign) CGFloat kc_layerBorderWidth;
@property (nonatomic, assign) CGFloat kc_layerCornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat kc_layerCornerRadiusWithClips;


- (void)kc_setBorderWithWidth:(CGFloat)width cornerRadius:(CGFloat)radius color:(UIColor *)color;

- (void)kc_setBorderWithWidth:(CGFloat)width cornerRadius:(CGFloat)radius color:(UIColor *)color roundingCorners:(UIRectCorner)corners;


// 增加圆角遮盖
- (void)kc_setRoundedCoverWithBackgroundColor:(UIColor *)color cornerRadius:(CGFloat)radius;

/**
 *  手势点击
 */
- (void)kc_setTapBlock:(void(^)(UIView *view, UITapGestureRecognizer *tap))block;

/**
 *  获取view的控制器
 */
- (UIViewController *)kc_viewController;


/**
 *  indicator
 */
- (void)kc_showActivityIndicator;
- (void)kc_hideActivityIndicator;
- (void)kc_setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;

@end
