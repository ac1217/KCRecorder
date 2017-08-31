//
//  UITextView+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/17.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (KCExtension)

// 占位文字
@property (nonatomic, copy) NSString *kc_placeholder;
@property (nonatomic, strong) UIColor *kc_placeholderColor;
@property (nonatomic,strong) NSAttributedString *kc_placeholderAttributedString;

@property (nonatomic,assign) NSInteger kc_maxLength;

@property (nonatomic,copy) void(^kc_textViewDidEditToMaxLengthBlock)(UITextView *tv);

@end
