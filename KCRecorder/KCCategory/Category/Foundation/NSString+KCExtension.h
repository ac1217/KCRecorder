//
//  NSString+KCExtension.h
//  categoryDemo
//
//  Created by zhangweiwei on 16/5/6.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (KCExtension)

/*
 * 字符串验证
 */
//邮箱
- (BOOL)kc_validateEmail;
//手机号码验证
- (BOOL)kc_validateMobile;
//车牌号验证
- (BOOL)kc_validateCarNo;
//车型
- (BOOL)kc_validateCarType;
//用户名
- (BOOL)kc_validateUserName;
//真实姓名
- (BOOL)kc_validateTrueName;
//密码
- (BOOL)kc_validatePassword;
//昵称
- (BOOL)kc_validateNickname;
//身份证号
- (BOOL)kc_validateIdentityCard;
//字符长度范围
- (BOOL)kc_validateStringMinLength:(NSInteger)minLength maxLength:(NSInteger)maxLength;

- (NSString *)kc_firstLetter;

// 通过时间字符串生成时间
- (NSDate *)kc_dateWithFormatter:(NSString *)fmt;

- (CGSize)kc_textSizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font;
- (CGSize)kc_singleLineTextWithFont:(UIFont *)font;

- (NSString *)kc_MD5String;


- (NSString *)kc_documentPath;
- (NSString *)kc_cachePath;
- (NSString *)kc_tempPath;

@end
