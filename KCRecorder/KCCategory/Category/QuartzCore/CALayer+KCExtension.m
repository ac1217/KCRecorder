//
//  CALayer+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/17.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "CALayer+KCExtension.h"
#import <objc/message.h>

static NSString *const KCCoverLayerKey = @"kc_coverLayer";

@interface CALayer ()

@property (nonatomic, strong) CAShapeLayer *kc_coverLayer;

@end


@implementation CALayer (KCExtension)

- (CAShapeLayer *)kc_coverLayer
{
    CAShapeLayer *coverLayer = objc_getAssociatedObject(self, (__bridge const void *)(KCCoverLayerKey));
    
    if (!coverLayer) {
        
        coverLayer = [CAShapeLayer layer];
        coverLayer.fillRule = kCAFillRuleEvenOdd;
        [self addSublayer:coverLayer];
        objc_setAssociatedObject(self, (__bridge const void *)(KCCoverLayerKey), coverLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return coverLayer;
}


// 增加圆角遮盖

- (void)kc_setRoundedCoverWithBackgroundColor:(CGColorRef)color cornerRadius:(CGFloat)radius
{
    [self insertSublayer:self.kc_coverLayer above:self.sublayers.lastObject];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, -1, -1)];
    
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius]];
    
    self.kc_coverLayer.path = path.CGPath;
    
    self.kc_coverLayer.fillColor = color;
    
    self.masksToBounds = YES;
}




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

- (void)setKc_positionX:(CGFloat)kc_positionX
{
    CGPoint position = self.position;
    position.x = kc_positionX;
    self.position = position;
}

- (CGFloat)kc_positionX { return self.position.x; }

- (void)setKc_positionY:(CGFloat)kc_positionY
{
    CGPoint position = self.position;
    position.y = kc_positionY;
    self.position = position;
}

- (CGFloat)kc_positionY{ return self.position.y; }

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



@end
