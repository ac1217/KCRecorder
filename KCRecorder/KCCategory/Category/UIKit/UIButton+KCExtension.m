//
//  UIButton+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/8/7.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UIButton+KCExtension.h"
#import <objc/runtime.h>

static NSString *const KCButtonImagePositionKey = @"imagePosition";
static NSString *const KCButtonImageTitleSpacingKey = @"imageTitleSpacing";

@implementation UIButton (KCExtension)

+ (void)load
{
    
    Method layoutSubviews1 = class_getInstanceMethod(self, NSSelectorFromString(@"layoutSubviews"));
    Method layoutSubviews2 = class_getInstanceMethod(self, @selector(kc_layoutSubviews));
    
    method_exchangeImplementations(layoutSubviews1 , layoutSubviews2);
}

- (void)kc_layoutSubviews
{
    [self kc_layoutSubviews];
    
    if (self.kc_imagePosition != KCButtonImagePositionDefault) {
        
        [self kc_setImagePosition:self.kc_imagePosition margin:self.kc_imageTitleSpacing];
    }
    
}

- (void)setKc_imageTitleSpacing:(CGFloat)kc_imageTitleSpacing
{
    objc_setAssociatedObject(self, (__bridge const void *)(KCButtonImageTitleSpacingKey), @(kc_imageTitleSpacing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (CGFloat)kc_imageTitleSpacing
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(KCButtonImageTitleSpacingKey)) doubleValue];
}

- (void)setKc_imagePosition:(KCButtonImagePosition)kc_imagePosition
{
    objc_setAssociatedObject(self, (__bridge const void *)(KCButtonImagePositionKey), @(kc_imagePosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KCButtonImagePosition)kc_imagePosition
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(KCButtonImagePositionKey)) integerValue];
}


- (void)kc_setImagePosition:(KCButtonImagePosition)postion margin:(CGFloat)margin
{
    
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGSize labelSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
    
    CGFloat labelWidth = labelSize.width;
    CGFloat labelHeight = labelSize.height;
    
    CGFloat imageOffsetX = (imageWidth + labelWidth) / 2 - imageWidth / 2;//image中心移动的x距离
    CGFloat imageOffsetY = imageHeight / 2 + margin / 2;//image中心移动的y距离
    CGFloat labelOffsetX = (imageWidth + labelWidth / 2) - (imageWidth + labelWidth) / 2;//label中心移动的x距离
    CGFloat labelOffsetY = labelHeight / 2 + margin / 2;//label中心移动的y距离
    
    CGFloat tempWidth = MAX(labelWidth, imageWidth);
    CGFloat changedWidth = labelWidth + imageWidth - tempWidth;
    CGFloat tempHeight = MAX(labelHeight, imageHeight);
    CGFloat changedHeight = labelHeight + imageHeight + margin - tempHeight;
    
    switch (postion) {
        case KCButtonImagePositionDefault:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -margin/2, 0, margin/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, margin/2, 0, -margin/2);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, margin/2, 0, margin/2);
            break;
            
        case KCButtonImagePositionRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + margin/2, 0, -(labelWidth + margin/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + margin/2), 0, imageWidth + margin/2);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, margin/2, 0, margin/2);
            break;
            
        case KCButtonImagePositionTop:
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
            self.contentEdgeInsets = UIEdgeInsetsMake(imageOffsetY, -changedWidth/2, changedHeight-imageOffsetY, -changedWidth/2);
            break;
            
        case KCButtonImagePositionBottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX, labelOffsetY, labelOffsetX);
            self.contentEdgeInsets = UIEdgeInsetsMake(changedHeight-imageOffsetY, -changedWidth/2, imageOffsetY, -changedWidth/2);
            break;
            
        default:
            break;
    }
    
}

@end
