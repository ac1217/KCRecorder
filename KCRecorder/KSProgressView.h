//
//  KSProgressView.h
//  KSProgressView
//
//  Created by zhangweiwei on 2017/6/20.
//  Copyright © 2017年 erica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSProgressView : UIView

@property (nonatomic,assign) float loadProgress;
@property (nonatomic,assign) float progress;

- (void)setLoadProgress:(float)loadProgress animated:(BOOL)animated;
- (void)setProgress:(float)progress animated:(BOOL)animated;

- (void)markAtProgress:(float)progress;
- (void)markAtCurrentProgress;
- (void)markAtProgress:(float)progress color:(UIColor *_Nullable)color;
- (void)markAtCurrentProgressWithColor:(UIColor *_Nullable)color;
- (void)removeAllMark;
- (void)removeLastMark;


@property (nonatomic,assign) CGFloat barCornerRadius;

@property(nonatomic, strong, nullable) UIColor* progressTintColor;
@property(nonatomic, strong, nullable) UIColor* trackTintColor;
@property(nonatomic, strong, nullable) UIImage* progressImage;
@property(nonatomic, strong, nullable) UIImage* trackImage;
@property(nonatomic, strong, nullable) UIColor* loadTintColor;
@property(nonatomic, strong, nullable) UIImage* loadImage;

@property(nonatomic, strong, nullable) UIColor* markColor;


@property (nonatomic,strong, nullable) NSArray <UIColor *>* progressTintColors;

@end
