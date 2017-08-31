//
//  KSProgressView.m
//  KSProgressView
//
//  Created by zhangweiwei on 2017/6/20.
//  Copyright © 2017年 erica. All rights reserved.
//

#import "KSProgressView.h"

@interface KSProgressView ()

@property (nonatomic,strong) UIImageView *loadBar;
@property (nonatomic,strong) UIImageView *progressBar;
@property (nonatomic,strong) UIImageView *trackBar;
@property (nonatomic,strong) NSMutableArray *markViews;
@property (nonatomic,strong) CAGradientLayer *progressLayer;

@end

@implementation KSProgressView

- (void)setProgressTintColors:(NSArray<UIColor *> *)progressTintColors
{
    _progressTintColors = progressTintColors;
    
    if (progressTintColors) {
        
        NSMutableArray *colors = @[].mutableCopy;
        for (UIColor *color in progressTintColors) {
            [colors addObject:(id)color.CGColor];
        }
        
        self.progressLayer.colors = colors;
        [self.progressBar.layer addSublayer:self.progressLayer];
    }else {
        [self.progressLayer removeFromSuperlayer];
    }
    
}

- (CAGradientLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAGradientLayer layer];
        _progressLayer.startPoint = CGPointMake(0, 0.5);
        _progressLayer.endPoint = CGPointMake(1, 0.5);
    }
    return _progressLayer;
}

- (NSMutableArray *)markViews
{
    if (!_markViews) {
        _markViews = [NSMutableArray array];
    }
    return _markViews;
}

- (void)removeAllMark
{
    [self.markViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.markViews removeAllObjects];
}

- (void)removeLastMark
{
    UIView *lastMark = self.markViews.lastObject;
    
    [UIView animateWithDuration:0.25 animations:^{
        lastMark.alpha = 0;
    } completion:^(BOOL finished) {
        
        [lastMark removeFromSuperview];
        [self.markViews removeObject:lastMark];
    }];
    
}

- (void)setLoadImage:(UIImage *)loadImage
{
    _loadImage = loadImage;
    
    self.loadBar.image = loadImage;
}

- (void)setProgressImage:(UIImage *)progressImage
{
    _progressImage = progressImage;
    
    self.progressBar.image = progressImage;
}

- (void)setTrackImage:(UIImage *)trackImage
{
    _trackImage = trackImage;
    
    self.trackBar.image = trackImage;
}

- (void)markAtCurrentProgress
{
    [self markAtProgress:self.progress];
}

- (void)markAtCurrentProgressWithColor:(UIColor *)color
{
    [self markAtProgress:self.progress color:color];
}

- (void)markAtProgress:(float)progress
{
    
    [self markAtProgress:progress color:self.markColor];
}

- (void)setBarCornerRadius:(CGFloat)barCornerRadius
{
    self.progressBar.layer.cornerRadius = barCornerRadius;
    self.loadBar.layer.cornerRadius = barCornerRadius;
    
    self.trackBar.layer.cornerRadius = barCornerRadius;
    
    self.layer.cornerRadius = barCornerRadius;
}

- (void)markAtProgress:(float)progress color:(UIColor *)color
{
    UIView *mark = [UIView new];
    mark.backgroundColor = color;
    
    [self addSubview:mark];
    mark.frame = CGRectMake(self.bounds.size.width * progress, 0, 2, self.bounds.size.height);
    
    mark.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        mark.alpha = 1;
    }];
    
    
    [self.markViews addObject:mark];
    
    
}

- (void)setProgress:(float)progress
{
    
    
    [self setProgress:progress animated:NO];
}

- (void)setLoadProgress:(float)loadProgress
{
    
    
    [self setLoadProgress:loadProgress animated:NO];
}

- (UIImageView *)loadBar
{
    if (!_loadBar) {
        _loadBar = [UIImageView new];
        _loadBar.clipsToBounds = YES;
        _loadBar.contentMode = UIViewContentModeScaleAspectFill;
        
        _loadBar.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:0.25];
        _loadBar.backgroundColor = [UIColor clearColor];
    }
    return _loadBar;
}

- (UIImageView *)progressBar
{
    if (!_progressBar) {
        _progressBar = [UIImageView new];
        _progressBar.clipsToBounds = YES;
        _progressBar.contentMode = UIViewContentModeScaleAspectFill;
        _progressBar.backgroundColor = [UIColor orangeColor];
    }
    return _progressBar;
}

- (UIImageView *)trackBar
{
    if (!_trackBar) {
        _trackBar = [UIImageView new];
        _trackBar.clipsToBounds = YES;
        _trackBar.contentMode = UIViewContentModeScaleAspectFill;
        _trackBar.backgroundColor = [UIColor grayColor];
        _trackBar.backgroundColor = [UIColor clearColor];
    }
    return _trackBar;
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if (progress > 1) {
        progress = 1;
    }else if (progress < 0) {
        progress = 0;
    }
    
    _progress = progress;
    
    if (animated) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGFloat progressBarW = self.bounds.size.width * progress;
            
            CGRect progressBarFrame = self.progressBar.frame;
            progressBarFrame.size.width = progressBarW;
            self.progressBar.frame = progressBarFrame;
            
        } completion:nil];
        
        
    }else {
        
        CGFloat progressBarW = self.bounds.size.width * progress;
        
        CGRect progressBarFrame = self.progressBar.frame;
        progressBarFrame.size.width = progressBarW;
        self.progressBar.frame = progressBarFrame;
        
    }
}

- (void)setLoadProgress:(float)loadProgress animated:(BOOL)animated
{
    if (loadProgress > 1) {
        loadProgress = 0;
    }else if (loadProgress < 0) {
        loadProgress = 0;
    }
    _loadProgress = loadProgress;
    
    if (animated) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGFloat loadBarW = self.bounds.size.width * loadProgress;
            
            CGRect loadBarFrame = self.loadBar.frame;
            loadBarFrame.size.width = loadBarW;
            self.loadBar.frame = loadBarFrame;
            
        } completion:nil];
        
        
    }else {
        
        CGFloat loadBarW = self.bounds.size.width * loadProgress;
        
        CGRect loadBarFrame = self.loadBar.frame;
        loadBarFrame.size.width = loadBarW;
        self.loadBar.frame = loadBarFrame;
        
    }

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.trackBar];
        [self addSubview:self.loadBar];
        [self addSubview:self.progressBar];
        
        NSMutableArray *colorsArray = [NSMutableArray array];
        NSInteger count = 100;
        for (NSInteger i = 0; i < count; i += 1) {
            CGFloat g = 186 + i * -124 / count;
            CGFloat b = 19 + i * 100 / count;
            UIColor *color = [UIColor colorWithRed:1 green:g/255.0 blue:b/255.0 alpha:1];
            [colorsArray addObject:color];
        }
        self.progressTintColors = colorsArray;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.trackBar.frame = self.bounds;
    
    
    CGRect loadBarFrame = self.loadBar.frame;
    loadBarFrame.origin.x = 0;
    loadBarFrame.origin.y = 0;
    loadBarFrame.size.height = self.bounds.size.height;
    self.loadBar.frame = loadBarFrame;
    
    CGRect progressBarFrame = self.progressBar.frame;
    progressBarFrame.origin.x = 0;
    progressBarFrame.origin.y = 0;
    progressBarFrame.size.height = self.bounds.size.height;
    self.progressBar.frame = progressBarFrame;
    
    self.progressLayer.frame = self.bounds;
}

@end
