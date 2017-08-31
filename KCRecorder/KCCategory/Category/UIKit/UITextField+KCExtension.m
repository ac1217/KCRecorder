//
//  UITextField+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/17.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UITextField+KCExtension.h"
#import <objc/runtime.h>

static NSString *const KCTextFieldPlaceholderLabelKey = @"_placeholderLabel";

static NSString *const KCTextFieldMaxLengthKey = @"kc_textFieldMaxLength";
static NSString *const KCTextFieldDidEditToMaxLengthBlockKey = @"kc_textFieldDidEditToMaxLengthBlock";

@implementation UITextField (KCExtension)

- (void)setKc_textFieldDidEditToMaxLengthBlock:(void (^)(UITextField *))kc_textFieldDidEditToMaxLengthBlock
{
    
    objc_setAssociatedObject(self, (__bridge const void *)(KCTextFieldDidEditToMaxLengthBlockKey), kc_textFieldDidEditToMaxLengthBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITextField *))kc_textFieldDidEditToMaxLengthBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(KCTextFieldDidEditToMaxLengthBlockKey));
}

- (void)setKc_maxLength:(NSInteger)kc_maxLength
{
    [self addTarget:self action:@selector(kc_textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
    
    objc_setAssociatedObject(self, (__bridge const void *)(KCTextFieldMaxLengthKey), @(kc_maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)kc_textFieldTextChange
{
    if (!self.kc_maxLength) {
        return;
    }
    
    if (self.text.length > self.kc_maxLength || self.attributedText.length > self.kc_maxLength) {
        [self deleteBackward];
        
        !self.kc_textFieldDidEditToMaxLengthBlock ? : self.kc_textFieldDidEditToMaxLengthBlock(self);
        
    }
}

- (NSInteger)kc_maxLength
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(KCTextFieldMaxLengthKey)) integerValue];
}

- (void)setKc_placeholderColor:(UIColor *)kc_placeholderColor
{
    [[self valueForKeyPath:KCTextFieldPlaceholderLabelKey] setTextColor:kc_placeholderColor];
}

- (UIColor *)kc_placeholderColor
{
    return [[self valueForKeyPath:KCTextFieldPlaceholderLabelKey] textColor];
}

@end
