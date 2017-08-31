//
//  KSPlayer.h
//  KSPlayer
//
//  Created by iMac on 2017/8/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSPlayerView.h"

typedef enum : NSUInteger {
    KSPlayerPlayStatusUnknow,
    KSPlayerPlayStatusStoped,
    KSPlayerPlayStatusPlaying,
    KSPlayerPlayStatusPaused
} KSPlayerPlayStatus;

typedef enum : NSUInteger {
    KSPlayerLoadStatusUnknown,
    KSPlayerLoadStatusPlayable,
    KSPlayerLoadStatusPlaythroughOK,
    KSPlayerLoadStatusStalled
} KSPlayerLoadStatus;

@interface KSPlayer : NSObject

// 播放器状态
@property (nonatomic,assign, readonly) KSPlayerPlayStatus playStatus;
@property (nonatomic,assign, readonly) KSPlayerPlayStatus loadStatus;

@property (nonatomic,strong, readonly) KSPlayerView *view;

@property (nonatomic,strong) NSURL *URL;

@property (nonatomic,assign, readonly) NSTimeInterval duration;

@property (nonatomic,assign) BOOL autoPlay;
@property (nonatomic,assign) BOOL playInBackground;
@property (nonatomic,assign) NSInteger loopCount;

@property (nonatomic,assign) float rate;
    
//@property (nonatomic,assign) NSTimeInterval startTime;
//@property (nonatomic,assign) NSTimeInterval playDuration;
@property (nonatomic,assign) NSTimeInterval startPlayTime;
@property (nonatomic,assign) NSTimeInterval endPlayTime;
    
- (void)seekToTime:(NSTimeInterval)time;

// 播放进度回调
@property (nonatomic,copy) void(^playProgressBlock)(KSPlayer *player, float time, float duration, float progress);

@property (nonatomic,copy) void(^playStatusBlock)(KSPlayer *player,KSPlayerPlayStatus status);

@property (nonatomic,copy) void(^loadStatusBlock)(KSPlayer *player,KSPlayerLoadStatus status);

@property (nonatomic,copy) void(^preparedToPlayBlock)(KSPlayer *player);

@property (nonatomic,copy) void(^playFinishBlock)(KSPlayer *player);
    
@property (nonatomic,copy) void(^readyForDisplayBlock)(KSPlayer *player);

@property (nonatomic,copy) void(^thumbnailImageRenderBlock)(KSPlayer *player, UIImage *image, NSTimeInterval time);

- (void)pause;
- (void)stop;
- (void)play;

@end
