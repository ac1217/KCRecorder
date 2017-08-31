//
//  UITextView+KCExtension.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/17.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "UITextView+KCExtension.h"
#import <objc/message.h>

static NSString *const KCTextViewPlaceholderLabelKey = @"kc_textViewPlaceholderLabel";

static NSString *const KCTextViewMaxLengthKey = @"kc_textViewMaxLength";
static NSString *const KCTextViewDidEditToMaxLengthBlockKey = @"kc_textViewDidEditToMaxLengthBlock";

@interface UITextView ()
@property (nonatomic, strong) UILabel *kc_placeholderLabel;
@end

@implementation UITextView (KCExtension)

- (UILabel *)kc_placeholderLabel
{
    UILabel *placeholderLabel = objc_getAssociatedObject(self, (__bridge const void *)(KCTextViewPlaceholderLabelKey));
    if (!placeholderLabel) {
        placeholderLabel = [[UILabel alloc] init];
        placeholderLabel.font = self.font;
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        placeholderLabel.textColor = [UIColor lightGrayColor];
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.textAlignment = self.textAlignment;
        [self addSubview:placeholderLabel];
        objc_setAssociatedObject(self, (__bridge const void *)(KCTextViewPlaceholderLabelKey), placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        CGFloat H = self.textContainer.lineFragmentPadding + self.textContainerInset.left;
        CGFloat V = self.textContainerInset.top;
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:H]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:V]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:H * -2]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kc_textViewTextChange) name:UITextViewTextDidChangeNotification object:self];
    }
    
    return placeholderLabel;

}

+ (void)load
{
    Class cls = [self class];
    
    Method dealloc1 = class_getInstanceMethod(cls, NSSelectorFromString(@"dealloc"));
    Method dealloc2 = class_getInstanceMethod(cls, @selector(kc_dealloc));
    
    method_exchangeImplementations(dealloc1 , dealloc2);
    
    Method font1 = class_getInstanceMethod(cls, @selector(setFont:));
    Method font2 = class_getInstanceMethod(cls, @selector(kc_setFont:));
    
    method_exchangeImplementations(font1 , font2);
    
    Method text1 = class_getInstanceMethod(cls, @selector(setText:));
    Method text2 = class_getInstanceMethod(cls, @selector(kc_setText:));
    
    method_exchangeImplementations(text1 , text2);
    
    
    Method attrText1 = class_getInstanceMethod(cls, @selector(setAttributedText:));
    Method attrText2 = class_getInstanceMethod(cls, @selector(kc_setAttributedText:));
    
    method_exchangeImplementations(attrText1 , attrText2);
    
    Method textAliment1 = class_getInstanceMethod(cls, @selector(setTextAlignment:));
    Method textAliment2 = class_getInstanceMethod(cls, @selector(kc_setTextAlignment:));
    
    method_exchangeImplementations(textAliment1 , textAliment2);
}

- (void)kc_dealloc
{
    [self kc_dealloc];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)kc_setAttributedText:(NSAttributedString *)attrText
{
    [self kc_setAttributedText:attrText];
    
    [self kc_textViewTextChange];
}

- (void)kc_setTextAlignment:(NSTextAlignment)textAlignment
{
    [self kc_setTextAlignment:textAlignment];
    
    self.kc_placeholderLabel.textAlignment = textAlignment;
}


- (void)kc_setText:(NSString *)text
{
    [self kc_setText:text];
    
    [self kc_textViewTextChange];
}

- (void)kc_setFont:(UIFont *)font
{
    [self kc_setFont:font];
    
    self.kc_placeholderLabel.font = font;
    
}

- (void)setKc_placeholder:(NSString *)kc_placeholder
{
    
    self.kc_placeholderLabel.text = kc_placeholder;

}

- (void)setKc_placeholderAttributedString:(NSAttributedString *)kc_placeholderAttributedString
{
    self.kc_placeholderLabel.attributedText = kc_placeholderAttributedString;
}

- (NSAttributedString *)kc_placeholderAttributedString
{
    return self.kc_placeholderLabel.attributedText;
}

- (NSString *)kc_placeholder
{
    return self.kc_placeholderLabel.text;
}

- (void)setKc_placeholderColor:(UIColor *)kc_placeholderColor
{
    [self.kc_placeholderLabel setTextColor:kc_placeholderColor];
}

- (UIColor *)kc_placeholderColor
{
    return [self.kc_placeholderLabel textColor];
}

- (void)setKc_maxLength:(NSInteger)kc_maxLength
{
//    [self addTarget:self action:@selector(kc_textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
    
    objc_setAssociatedObject(self, (__bridge const void *)(KCTextViewMaxLengthKey), @(kc_maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setKc_textViewDidEditToMaxLengthBlock:(void (^)(UITextView *))kc_textViewDidEditToMaxLengthBlock
{
    
    objc_setAssociatedObject(self, (__bridge const void *)(KCTextViewDidEditToMaxLengthBlockKey), kc_textViewDidEditToMaxLengthBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITextView *))kc_textViewDidEditToMaxLengthBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(KCTextViewDidEditToMaxLengthBlockKey));
}

- (void)kc_textViewTextChange
{
    self.kc_placeholderLabel.hidden = self.hasText;
    
    if (!self.kc_maxLength) {
        return;
    }
    
    if (self.text.length > self.kc_maxLength || self.attributedText.length > self.kc_maxLength) {
        [self deleteBackward];
        !self.kc_textViewDidEditToMaxLengthBlock ? : self.kc_textViewDidEditToMaxLengthBlock(self);
    }
}

- (NSInteger)kc_maxLength
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(KCTextViewMaxLengthKey)) integerValue];
}

@end
