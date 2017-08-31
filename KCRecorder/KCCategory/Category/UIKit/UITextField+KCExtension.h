//
//  UITextField+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/17.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (KCExtension)

@property (nonatomic, strong) UIColor *kc_placeholderColor;

@property (nonatomic,assign) NSInteger kc_maxLength;

@property (nonatomic,copy) void(^kc_textFieldDidEditToMaxLengthBlock)(UITextField *tf);

@end
