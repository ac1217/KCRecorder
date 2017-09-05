//
//  KCRecorder.h
//  KCRecorder
//
//  Created by iMac on 2017/8/30.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "KCRecorderItem.h"
#import "KCRecorderView.h"

typedef enum : NSUInteger {
    KCRecorderStatusStopped,
    KCRecorderStatusRecording,
    KCRecorderStatusPaused
} KCRecorderStatus;


@class KCRecorder;

@protocol KCRecorderDataSource <NSObject>

- (NSURL *)recorder:(KCRecorder *)recorder destinationURLWithCurrentTime:(NSTimeInterval)currentTime;

@optional // 背景音乐相关
- (NSTimeInterval)durationWithRecorder:(KCRecorder *)recorder;

- (NSURL *)recorder:(KCRecorder *)recorder accompanyAudioURLForItem:(KCRecorderItem *)item;

- (NSTimeInterval)recorder:(KCRecorder *)recorder accompanyAudioStartTimeForItem:(KCRecorderItem *)item;

- (float)recorder:(KCRecorder *)recorder rateForItem:(KCRecorderItem *)item;

- (BOOL)recorder:(KCRecorder *)recorder shouldContainVoiceForItem:(KCRecorderItem *)item;

- (BOOL)recorder:(KCRecorder *)recorder shouldPlayAudioWhenReocrdingForItem:(KCRecorderItem *)item;

@end

@protocol KCRecorderDelegate <NSObject>

@optional

- (void)recorderStatusDidChanged:(KCRecorder *)recorder;
- (void)recorderDidPrepared:(KCRecorder *)recorder;
- (void)recorderCurrentTimeDidChanged:(KCRecorder *)recorder;


- (void)recorderWillStart:(KCRecorder *)recorder;
- (void)recorderWillStop:(KCRecorder *)recorder;

- (void)recorder:(KCRecorder *)recorder didStartedForItem:(KCRecorderItem *)item;
- (void)recorder:(KCRecorder *)recorder didStoppedForItem:(KCRecorderItem *)item;
- (void)recorder:(KCRecorder *)recorder didFailedForItem:(KCRecorderItem *)item error:(NSError *)error;

- (void)recorder:(KCRecorder *)recorder didCompletedForItems:(NSArray <KCRecorderItem *>*)items;
- (void)recorder:(KCRecorder *)recorder didRemovedItem:(KCRecorderItem *)item atIndex:(NSInteger)index;


@end

@interface KCRecorder : NSObject

// 是否已经准备好
@property (nonatomic,assign, readonly) BOOL isPrepare;

// 录制的视频数组
@property (nonatomic,strong, readonly) NSMutableArray <KCRecorderItem *>*items;

// 数据源
@property (nonatomic,weak) id<KCRecorderDataSource> dataSource;
// 代理
@property (nonatomic,weak) id<KCRecorderDelegate> delegate;

// 录制状态
@property (nonatomic,assign, readonly) KCRecorderStatus status;


// 录制状态回调
@property (nonatomic,copy) void(^statusDidChangedBlock)(KCRecorder *recorder, KCRecorderStatus status);
// 录制进度回调
@property (nonatomic,copy) void(^currentTimeDidChangedBlock)(KCRecorder *recorder, NSTimeInterval currentTime);

// 总录制时长，当没实现数据源方法，则为不限时长
@property (nonatomic,assign, readonly) NSTimeInterval duration;
// 进度回调频率
@property (nonatomic,assign) NSTimeInterval timeInterval;
// 当前录制进度
@property (nonatomic,assign) NSTimeInterval currentTime;
// 当前伴奏播放进度
@property (nonatomic,assign, readonly) NSTimeInterval accompanyAudioCurrentTime;


// 美颜滤镜
@property (nonatomic,strong, readonly) GPUImageFilterGroup *beautifyFilter;
// 空滤镜
@property (nonatomic,strong, readonly) GPUImageFilter *emptyFilter;
// 设置滤镜
- (void)setFilter:(GPUImageOutput *)filter;


// 移除index位置的视频
- (KCRecorderItem *)removeItemAtIndex:(NSInteger)index;
// 移除最后一个视频
- (KCRecorderItem *)removeLastItem;

// 视频参数设置
@property (nonatomic,strong) NSDictionary *videoSetting;

// 硬件参数设置
@property (nonatomic,copy) NSString *sessionPreset;
@property (nonatomic,assign) AVCaptureDevicePosition cameraPosition;
@property(nonatomic) AVCaptureTorchMode torchMode;
@property(nonatomic) CGPoint focusPointOfInterest;
@property(nonatomic) AVCaptureFocusMode focusMode;

// 拍摄的视频分辨率
@property (nonatomic,assign) CGSize videoSize;
// 拍摄的视频文件类型
@property (nonatomic,copy) NSString *fileType;

// 切换手电筒
- (void)switchTorch;
// 切换相机
- (void)switchCamera;


// 预备，该方法会阻塞线程，请在子线程调用
- (void)prepare; // default font camera
- (void)prepareWithCameraPosition:(AVCaptureDevicePosition)cameraPosition;
// 释放
- (void)destory;

// 开始预览视图
- (void)beginPreview;
// 结束预览视图
- (void)endPreview;


// 开始录制
- (void)start;
// 继续录制
- (void)resume;
// 暂停录制
- (void)pause;
// 停止录制
- (void)stop;
// 取消录制
- (void)cancel;

// 预览视图
@property (nonatomic,strong, readonly) KCRecorderView *view;

@end
