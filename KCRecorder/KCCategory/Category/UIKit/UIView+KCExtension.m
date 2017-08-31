//
//  UIView+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UIView+KCExtension.h"
#import "CALayer+KCExtension.h"
#import <objc/message.h>

static NSString *const KCBadgeValueLabelKey = @"kc_badgeValueLabel";
static NSString *const KCBorderLayerKey = @"kc_borderLayer";
static NSString *KCViewTapBlockKey = @"KCViewTapBlockKey";

static NSString *const KCActivityIndicatorViewKey = @"kc_activityIndicatorView";

@interface UIView ()

@property (nonatomic, strong) UILabel *kc_badgeValueLabel;
@property (nonatomic, strong) CAShapeLayer *kc_borderLayer;

@property (nonatomic,strong) UIActivityIndicatorView *kc_activityIndicatorView;
@end

@implementation UIView (KCExtension)

#pragma mark -懒加载

- (UIActivityIndicatorView *)kc_activityIndicatorView
{
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, (__bridge const void *)(KCActivityIndicatorViewKey));
    
    if (!indicatorView) {
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.hidesWhenStopped = YES;
        [self addSubview:indicatorView];
        objc_setAssociatedObject(self, (__bridge const void *)(KCActivityIndicatorViewKey), indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:indicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:indicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
    }
    
    return indicatorView;
}

- (CAShapeLayer *)kc_borderLayer
{
    CAShapeLayer *borderLayer = objc_getAssociatedObject(self, (__bridge const void *)(KCBorderLayerKey));
    
    if (!borderLayer) {
        
        borderLayer = [CAShapeLayer layer];
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:borderLayer];
        objc_setAssociatedObject(self, (__bridge const void *)(KCBorderLayerKey), borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return borderLayer;
    
}

- (UILabel *)kc_badgeValueLabel
{
    UILabel *badgeValueLabel = objc_getAssociatedObject(self, (__bridge const void *)(KCBadgeValueLabelKey));
    
    if (!badgeValueLabel) {
        badgeValueLabel = [[UILabel alloc] init];
        badgeValueLabel.font = [UIFont systemFontOfSize:10];
        badgeValueLabel.textColor = [UIColor whiteColor];
        badgeValueLabel.textAlignment = NSTextAlignmentCenter;
        badgeValueLabel.layer.backgroundColor = [UIColor redColor].CGColor;
        [self addSubview:badgeValueLabel];
        objc_setAssociatedObject(self, (__bridge const void *)(KCBadgeValueLabelKey), badgeValueLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return badgeValueLabel;
    
}

#pragma mark -frame相关


- (void)setKc_x:(CGFloat)kc_x
{
    CGRect frame = self.frame;
    frame.origin.x = kc_x;
    self.frame = frame;
}

- (CGFloat)kc_x { return self.frame.origin.x; }

- (void)setKc_maxX:(CGFloat)kc_maxX { self.kc_x = kc_maxX - self.kc_width; }

- (CGFloat)kc_maxX { return CGRectGetMaxX(self.frame); }

- (void)setKc_maxY:(CGFloat)kc_maxY { self.kc_y = kc_maxY - self.kc_height; }

- (CGFloat)kc_maxY { return CGRectGetMaxY(self.frame); }

- (void)setKc_y:(CGFloat)kc_y
{
    CGRect frame = self.frame;
    frame.origin.y = kc_y;
    self.frame = frame;
}

- (CGFloat)kc_y { return self.frame.origin.y; }

- (void)setKc_centerX:(CGFloat)kc_centerX
{
    CGPoint center = self.center;
    center.x = kc_centerX;
    self.center = center;
}

- (CGFloat)kc_centerX { return self.center.x; }

- (void)setKc_centerY:(CGFloat)kc_centerY
{
    CGPoint center = self.center;
    center.y = kc_centerY;
    self.center = center;
}

- (CGFloat)kc_centerY { return self.center.y; }

- (void)setKc_width:(CGFloat)kc_width
{
    CGRect frame = self.frame;
    frame.size.width = kc_width;
    self.frame = frame;
}

- (CGFloat)kc_width { return self.frame.size.width; }

- (void)setKc_height:(CGFloat)kc_height
{
    CGRect frame = self.frame;
    frame.size.height = kc_height;
    self.frame = frame;
}

- (CGFloat)kc_height { return self.frame.size.height; }

- (void)setKc_size:(CGSize)kc_size
{
    CGRect frame = self.frame;
    frame.size = kc_size;
    self.frame = frame;
}

- (CGSize)kc_size { return self.frame.size; }

/**********************/

#pragma mark -transform相关
// helper to get pre transform frame
-(CGRect)kc_originalFrameAfterTransform {
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    return originalFrame;
}

// now get your corners
- (CGPoint)kc_topLeftAfterTransform {
    CGRect frame = [self kc_originalFrameAfterTransform];
    return [self kc_pointInViewAfterTransform:frame.origin];
}

- (CGPoint)kc_topRightAfterTransform {
    CGRect frame = [self kc_originalFrameAfterTransform];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self kc_pointInViewAfterTransform:point];
}

- (CGPoint)kc_bottomLeftAfterTransform {
    CGRect frame = [self kc_originalFrameAfterTransform];
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self kc_pointInViewAfterTransform:point];
}

- (CGPoint)kc_bottomRightAfterTransform {
    CGRect frame = [self kc_originalFrameAfterTransform];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self kc_pointInViewAfterTransform:point];
}

// 辅助方法
- (CGPoint)kc_pointInViewAfterTransform:(CGPoint)thePoint {
    // get offset from center
    CGPoint offset = CGPointMake(thePoint.x - self.center.x, thePoint.y - self.center.y);
    // get transformed point
    CGPoint transformedPoint = CGPointApplyAffineTransform(offset, self.transform);
    // make relative to center
    return CGPointMake(transformedPoint.x + self.center.x, transformedPoint.y + self.center.y);
}


/**********************/

#pragma mark -截图相关
- (UIImage *)kc_screenshot { return [self kc_screenshotWithRect:self.bounds]; }

- (UIImage *)kc_screenshotWithRect:(CGRect)rect;
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL)
    {
        return nil;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:context];
    }
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (BOOL)kc_isDisplayOnScreen
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGRect newF = [window convertRect:self.frame fromView:self.superview];
    
    return !self.isHidden && self.alpha > 0.01 && self.window == window && CGRectIntersectsRect(newF, window.bounds);
    
}

/**********************/

#pragma mark -分割线相关
+ (instancetype)kc_whiteSeparator
{
    UIView *view = [self new];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    return view;
}

+ (instancetype)kc_blackSeparator
{
    UIView *view = [self new];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    return view;
}

/**********************/

#pragma mark -xib相关
+ (instancetype)kc_viewFromXib { return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject]; }

+ (UINib *)kc_xib { return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil]; }


/**********************/
#pragma mark -显示红点
- (void)setKc_badgeFont:(UIFont *)kc_badgeFont
{
    self.kc_badgeValueLabel.font = kc_badgeFont;
}

- (UIFont *)kc_badgeFont
{
    return self.kc_badgeValueLabel.font;
}

- (void)setKc_badgeColor:(UIColor *)kc_badgeColor
{
    self.kc_badgeValueLabel.textColor = kc_badgeColor;
    
}

- (UIColor *)kc_badgeColor
{
    return self.kc_badgeValueLabel.textColor;
}

- (void)setKc_badgeValue:(NSString *)kc_badgeValue
{
    
    
    if (kc_badgeValue) {
        self.kc_badgeValueLabel.hidden = NO;
        self.kc_badgeValueLabel.text = kc_badgeValue;
        if (kc_badgeValue.length) {
            
            
            CGSize textSize = [kc_badgeValue sizeWithAttributes:@{NSFontAttributeName : self.kc_badgeValueLabel.font}];
            CGFloat h = textSize.height + self.kc_badgeValueLabel.font.lineHeight * 0.4;
            CGFloat minW = h;
            CGFloat w = textSize.width + self.kc_badgeValueLabel.font.lineHeight * 0.8;
            
            w = w < minW ? minW : w;
            
            self.kc_badgeValueLabel.frame = CGRectMake(self.frame.size.width - w * 0.5, - h * 0.5, w, h);
            
            self.kc_badgeValueLabel.layer.cornerRadius = h * 0.5;
            
        }else {
            
            CGFloat wh = 8;
            self.kc_badgeValueLabel.frame = CGRectMake(self.frame.size.width - wh * 0.5, - wh * 0.5, wh, wh);
            
            self.kc_badgeValueLabel.layer.cornerRadius = wh * 0.5;
        }
    }else {
        self.kc_badgeValueLabel.hidden = YES;
    }
}

- (NSString *)kc_badgeValue
{
    return self.kc_badgeValueLabel.text;
}

- (void)setKc_badgeBackgroundColor:(UIColor *)kc_badgeBackgroundColor
{
    self.kc_badgeValueLabel.layer.backgroundColor = kc_badgeBackgroundColor.CGColor;
}

- (UIColor *)kc_badgeBackgroundColor
{
    return [UIColor colorWithCGColor:self.kc_badgeValueLabel.layer.backgroundColor];
}

- (void)kc_setBadgeValue:(NSString *)badgeValue offset:(CGPoint)offset
{
    self.kc_badgeValue = badgeValue;
    
    CGRect temp = self.kc_badgeValueLabel.frame;
    temp.origin.x = self.frame.size.width - temp.size.width * 0.5 + offset.x;
    temp.origin.y = - temp.size.height * 0.5 + offset.y;
    
    self.kc_badgeValueLabel.frame = temp;
}

/**********************/

#pragma mark -layer
- (void)setKc_layerBackgroundColor:(UIColor *)kc_layerBackgroundColor
{
    self.layer.backgroundColor = kc_layerBackgroundColor.CGColor;
}

- (UIColor *)kc_layerBackgroundColor
{
    return [UIColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setKc_layerBorderColor:(UIColor *)kc_layerBorderColor
{
    self.layer.borderColor = kc_layerBorderColor.CGColor;
}

- (UIColor *)kc_layerBorderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setKc_layerCornerRadius:(CGFloat)kc_layerCornerRadius
{
    self.layer.cornerRadius = kc_layerCornerRadius;
}

- (CGFloat)kc_layerCornerRadius
{
    return self.layer.cornerRadius;
}

- (void)setKc_layerBorderWidth:(CGFloat)kc_layerBorderWidth
{
    self.layer.borderWidth = kc_layerBorderWidth;
}

- (CGFloat)kc_layerBorderWidth
{
    return self.layer.borderWidth;
}

- (void)setKc_layerCornerRadiusWithClips:(CGFloat)kc_layerCornerRadiusWithClips
{
    self.kc_layerCornerRadius = kc_layerCornerRadiusWithClips;
    self.clipsToBounds = YES;
    
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
}

- (CGFloat)kc_layerCornerRadiusWithClips
{
    return self.layer.cornerRadius;
}


- (void)kc_setBorderWithWidth:(CGFloat)width cornerRadius:(CGFloat)radius color:(UIColor *)color
{
    [self kc_setBorderWithWidth:width cornerRadius:radius color:color roundingCorners:UIRectCornerAllCorners];
}


- (void)kc_setBorderWithWidth:(CGFloat)width cornerRadius:(CGFloat)radius color:(UIColor *)color roundingCorners:(UIRectCorner)corners
{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, width, width) byRoundingCorners:corners cornerRadii:CGSizeMake(radius-width, radius-width)];
    self.kc_borderLayer.path = path.CGPath;
    self.kc_borderLayer.lineWidth = width;
    self.kc_borderLayer.strokeColor = color.CGColor;
    self.kc_borderLayer.frame = self.bounds;
    
}


- (void)kc_setRoundedCoverWithBackgroundColor:(UIColor *)color cornerRadius:(CGFloat)radius
{
    [self.layer kc_setRoundedCoverWithBackgroundColor:color.CGColor cornerRadius:radius];
}


/**
 *  手势点击
 */
- (void)kc_viewTap:(UITapGestureRecognizer *)tap
{
    void(^block)(UIView *, UITapGestureRecognizer *) = objc_getAssociatedObject(self, (__bridge const void *)(KCViewTapBlockKey));
    
    if (block) {
        block(self, tap);
    }
}

- (void)kc_setTapBlock:(void(^)(UIView *view, UITapGestureRecognizer *tap))block;
{
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kc_viewTap:)];
    
    [self addGestureRecognizer:tap];
    
    objc_setAssociatedObject(self, (__bridge const void *)(KCViewTapBlockKey), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


/**
 *  获取view的控制器
 */
- (UIViewController *)kc_viewController
{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}


- (void)kc_showActivityIndicator
{
    [self.kc_activityIndicatorView startAnimating];
}

- (void)kc_hideActivityIndicator
{
    [self.kc_activityIndicatorView stopAnimating];
}

- (void)kc_setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    self.kc_activityIndicatorView.activityIndicatorViewStyle = style;
}

@end
