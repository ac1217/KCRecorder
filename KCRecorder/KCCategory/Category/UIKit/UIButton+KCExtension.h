//
//  UIButton+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/8/7.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KCButtonImagePosition) {
    KCButtonImagePositionDefault = 0,              //图片在左，文字在右，默认
    KCButtonImagePositionRight = 1,             //图片在右，文字在左
    KCButtonImagePositionTop = 2,               //图片在上，文字在下
    KCButtonImagePositionBottom = 3,            //图片在下，文字在上
};

@interface UIButton (KCExtension)


/**
 *  注意：这个方法需要在设置图片和文字之后才生效
 *
 *  @param spacing 图片和文字的间隔
 */
- (void)kc_setImagePosition:(KCButtonImagePosition)postion margin:(CGFloat)margin;


@property (nonatomic,assign) KCButtonImagePosition kc_imagePosition;
@property (nonatomic,assign) CGFloat kc_imageTitleSpacing;

@end
