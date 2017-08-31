//
//  UIImageView+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (KCExtension)
// 给Imageview加毛玻璃效果，样式->UIBlurEffectStyle
- (void)kc_blurEffectWithStyle:(UIBlurEffectStyle)style;



@end
