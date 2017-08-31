//
//  CALayer+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/17.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CALayer (KCExtension)

/*
 * 快速设置frame、center、size
 */
@property (nonatomic, assign) CGFloat kc_x;
@property (nonatomic, assign) CGFloat kc_y;
@property (nonatomic, assign) CGFloat kc_maxX;
@property (nonatomic, assign) CGFloat kc_maxY;
@property (nonatomic, assign) CGFloat kc_positionX;
@property (nonatomic, assign) CGFloat kc_positionY;
@property (nonatomic, assign) CGFloat kc_width;
@property (nonatomic, assign) CGFloat kc_height;
@property (nonatomic, assign) CGSize kc_size;

// 增加圆角遮盖
- (void)kc_setRoundedCoverWithBackgroundColor:(CGColorRef)color cornerRadius:(CGFloat)radius;
@end
