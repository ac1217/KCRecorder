//
//  KCRecorderView.m
//  KCRecorder
//
//  Created by iMac on 2017/8/31.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorderView.h"

@implementation KCRecorderView

 - (void)setRecorderLayer:(UIView *)recorderLayer
 {
 
 [_recorderLayer removeFromSuperview];
 _recorderLayer = recorderLayer;
 [self addSubview:recorderLayer];
 [self setNeedsLayout];
 
 }
 
 - (void)layoutSubviews
 {
 [super layoutSubviews];
 
 self.recorderLayer.frame = self.layer.bounds;
 }

@end
