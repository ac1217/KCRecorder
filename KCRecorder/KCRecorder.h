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

typedef enum : NSUInteger {
    KCRecorderTrackBoth,
    KCRecorderTrackAudio,
    KCRecorderTrackVideo
} KCRecorderTrack;

@class KCRecorder;

@protocol KCRecorderDataSource <NSObject>

- (NSURL *)recorder:(KCRecorder *)recorder destinationURLWithCurrentTime:(NSTimeInterval)currentTime;

@optional
- (NSTimeInterval)durationWithRecorder:(KCRecorder *)recorder;
- (NSURL *)accompanyAudioURLWithRecorder:(KCRecorder *)recorder;
- (NSTimeInterval)accompanyAudioStartTimeWithRecorder:(KCRecorder *)recorder;
- (float)accompanyAudioRateWithRecorder:(KCRecorder *)recorder;

@end

@interface KCRecorder : NSObject

@property (nonatomic,assign, readonly) BOOL isPrepare;

@property (nonatomic,strong, readonly) NSMutableArray <KCRecorderItem *>*items;

@property (nonatomic,weak) id<KCRecorderDataSource> dataSource;

@property (nonatomic,assign, readonly) KCRecorderStatus status;

@property (nonatomic,assign) KCRecorderTrack track;

@property (nonatomic,copy) void(^recordStatusBlock)(KCRecorder *recorder, KCRecorderStatus status);

@property (nonatomic,assign, readonly) NSTimeInterval duration;
@property (nonatomic,assign) NSTimeInterval timeInterval;
@property (nonatomic,assign) NSTimeInterval currentTime;

@property (nonatomic,copy) void(^currentTimeBlock)(KCRecorder *recorder, NSTimeInterval currentTime);

@property (nonatomic,copy) void(^completionBlock)(KCRecorder *recorder);
@property (nonatomic,copy) void(^finishBlock)(KCRecorder *recorder);
@property (nonatomic,copy) void(^failureBlock)(KCRecorder *recorder, NSError *error);

// 美颜滤镜
@property (nonatomic,strong, readonly) GPUImageFilterGroup *beautifyFilter;
// 空滤镜
@property (nonatomic,strong, readonly) GPUImageFilter *emptyFilter;
@property(nonatomic) AVCaptureTorchMode torchMode;

- (void)switchTorch;

- (void)removeItemAtIndex:(NSInteger)index;
- (void)removeLastItem;


@property (nonatomic,copy) NSString *sessionPreset;
@property (nonatomic,assign) AVCaptureDevicePosition cameraPosition;

@property(nonatomic) CGPoint focusPointOfInterest;
@property(nonatomic) AVCaptureFocusMode focusMode;

@property (nonatomic,assign) CGSize videoSize;
@property (nonatomic,copy) NSString *fileType;



- (void)prepare;
- (void)destory;

- (void)beginPreview;
- (void)endPreview;

- (void)setFilter:(GPUImageOutput *)filter;

- (void)start;
- (void)resume;
- (void)pause;
- (void)stop;
- (void)cancel;

- (void)switchToCameraPosition:(AVCaptureDevicePosition)position;
- (void)switchCamera;

@property (nonatomic,strong, readonly) KCRecorderView *view;

@end
