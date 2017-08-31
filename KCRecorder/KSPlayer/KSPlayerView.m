//
//  KSPlayerView.m
//  KSPlayer
//
//  Created by iMac on 2017/8/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KSPlayerView.h"

@implementation KSPlayerView

- (void)setPlayerLayer:(UIView *)playerLayer
{
    
    [_playerLayer removeFromSuperview];
    _playerLayer = playerLayer;
    [self addSubview:playerLayer];
    [self setNeedsLayout];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.layer.bounds;
}

@end
