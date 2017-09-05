//
//  KCRecorder.m
//  KCRecorder
//
//  Created by iMac on 2017/8/30.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorder.h"
#import "KCRecorderEditor.h"

@interface KCRecorder ()<GPUImageVideoCameraDelegate>{
    KCRecorderView *_view;
    GPUImageView *_gpuView;
    GPUImageOutput *_filter;
    KCRecorderStatus _status;
    GPUImageFilterGroup *_beautifyFilter;
    GPUImageFilter *_emptyFilter;
    NSMutableArray *_items;
    BOOL _isPrepare;
}

@property (nonatomic,strong) GPUImageVideoCamera *camera;

@property (nonatomic,strong) GPUImageMovieWriter *writer;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) AVAudioPlayer *player;

@end

@implementation KCRecorder

#pragma mark -Getter
- (NSTimeInterval)accompanyAudioCurrentTime
{
    return _player.currentTime;
}


#pragma mark -DataSource

- (BOOL)shouldPlayAudioWhenReocrding
{
    
    if ([_dataSource respondsToSelector:@selector(recorder:shouldPlayAudioWhenReocrdingForItem:)]) {
        return [_dataSource recorder:self shouldPlayAudioWhenReocrdingForItem:_items.lastObject];
    }
    
    return YES;
}

- (BOOL)shouldContainVoice
{
    
    if ([_dataSource respondsToSelector:@selector(recorder:shouldContainVoiceForItem:)]) {
        return [_dataSource recorder:self shouldContainVoiceForItem:_items.lastObject];
    }
    return YES;
}

- (float)rate
{
    
    if ([_dataSource respondsToSelector:@selector(recorder:rateForItem:)]) {
        return [_dataSource recorder:self rateForItem:_items.lastObject];
    }
    return 1;
}

- (NSURL *)accompanyAudioURL
{
    
    if ([_dataSource respondsToSelector:@selector(recorder:accompanyAudioURLForItem:)]) {
        return [_dataSource recorder:self accompanyAudioURLForItem:_items.lastObject];
    }
    return nil;
}

- (NSTimeInterval)accompanyAudioStartTime
{
    if ([_dataSource respondsToSelector:@selector(recorder:accompanyAudioStartTimeForItem:)]) {
        return [_dataSource recorder:self accompanyAudioStartTimeForItem:_items.lastObject];
    }
    return 0;
}

- (NSURL *)destinationURL
{
    return [_dataSource recorder:self destinationURLWithCurrentTime:_currentTime];
}

- (NSTimeInterval)duration
{
    if ([_dataSource respondsToSelector:@selector(durationWithRecorder:)]) {
        return [_dataSource durationWithRecorder:self];
    }
    return 0;
}

#pragma mark -Life Cycle
- (void)dealloc
{
    [self destory];
    [self removeTimer];
    
}


- (instancetype)init
{
    if (self = [super init]) {
        
        _sessionPreset = AVCaptureSessionPresetHigh;
        _fileType = AVFileTypeMPEG4;
        _view = [KCRecorderView new];
        _items = @[].mutableCopy;
        
        // 1、创建滤镜组
        _beautifyFilter = [[GPUImageFilterGroup alloc] init];
        
        // 2、创建滤镜（设置滤镜的引用关系）
        // 2-1、 初始化滤镜
        GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init]; // 磨皮
        GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init]; // 曝光
        GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init]; // 美白
//        brightnessFilter.brightness = 0.5;
        GPUImageSaturationFilter *satureationFilter = [[GPUImageSaturationFilter alloc] init]; // 饱和
        
        // 2-2、设置滤镜的引用关系
        [bilateralFilter addTarget:brightnessFilter];
        [brightnessFilter addTarget:exposureFilter];
        [exposureFilter addTarget:satureationFilter];
        
        // 3、设置滤镜组链的起点&&终点
        _beautifyFilter.initialFilters = @[bilateralFilter];
        _beautifyFilter.terminalFilter = satureationFilter;
        
        _emptyFilter = [[GPUImageFilter  alloc] init];
        _filter = _emptyFilter;
        
        _timeInterval = 1;
        
        
    }
    return self;
}

#pragma mark -Public Method
- (KCRecorderItem *)removeLastItem
{
    return [self removeItemAtIndex:_items.count - 1];
}

- (KCRecorderItem *)removeItemAtIndex:(NSInteger)index
{
    if (index < 0 && index >= _items.count) {
        return nil;
    }
    
    KCRecorderItem *item = _items[index];
    
    [_items removeObjectAtIndex:index];
    
    [self resetCurrentTime];
    
    if ([self.delegate respondsToSelector:@selector(recorder:didRemovedItem:atIndex:)]) {
        [self.delegate recorder:self didRemovedItem:item atIndex:index];
    }
    
    return item;
}

- (void)beginPreview
{
    if (_isPrepare) {
        
        [_camera resumeCameraCapture];
    }
}

- (void)endPreview
{
    
    if (_isPrepare) {
        
        [_camera pauseCameraCapture];
    }
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode
{
    
    
    if([_camera.inputCamera lockForConfiguration:nil]) {
        
        // 聚焦模式
        if ([_camera.inputCamera isFocusModeSupported:focusMode]) {
            [_camera.inputCamera setFocusMode:focusMode];
        }
    
    }
    [_camera.inputCamera unlockForConfiguration];
}

- (void)setFocusPointOfInterest:(CGPoint)focusPointOfInterest
{
    
    if([_camera.inputCamera lockForConfiguration:nil]) {
        
        if ([_camera.inputCamera isFocusPointOfInterestSupported]) {
            [_camera.inputCamera setFocusPointOfInterest:focusPointOfInterest];
        }
        
        
    }
    [_camera.inputCamera unlockForConfiguration];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    if([_camera.inputCamera lockForConfiguration:nil]) {
        
        if ([_camera.inputCamera isTorchModeSupported:torchMode]) {
            [_camera.inputCamera setTorchMode:torchMode];
        }
    }
    [_camera.inputCamera unlockForConfiguration];
}

- (AVCaptureTorchMode)torchMode
{
    return _camera.inputCamera.torchMode;
}

 - (AVCaptureDevicePosition)cameraPosition
{
    return _camera.cameraPosition;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    switch (cameraPosition) {
        case AVCaptureDevicePositionBack:
            
            if (_camera.isFrontFacingCameraPresent) {
                [_camera rotateCamera];
            }
            
            break;
        case AVCaptureDevicePositionFront:
        {
            if (_camera.isBackFacingCameraPresent) {
                [_camera rotateCamera];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)switchTorch
{
    if([_camera.inputCamera lockForConfiguration:nil]) {
        
        switch (_camera.inputCamera.torchMode) {
            case AVCaptureTorchModeOn:
                
                if ([_camera.inputCamera isTorchModeSupported:AVCaptureTorchModeOff]) {
                    [_camera.inputCamera setTorchMode:AVCaptureTorchModeOff];
                }
                break;
            case AVCaptureTorchModeOff:
                
                if ([_camera.inputCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [_camera.inputCamera setTorchMode:AVCaptureTorchModeOn];
                }
                
                break;
            case AVCaptureTorchModeAuto:
                
                if ([_camera.inputCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [_camera.inputCamera setTorchMode:AVCaptureTorchModeOn];
                }
                
                break;
                
            default:
                break;
        }
        
    }
    [_camera.inputCamera unlockForConfiguration];
}


- (void)setFilter:(GPUImageOutput *)filter
{
    _filter = filter;
    
    if (!_filter) {
        _filter = _emptyFilter;
    }
    
    if (!_isPrepare) {
        return;
    }
    
    [_camera removeAllTargets];
    
    [_filter addTarget:_gpuView];
    [_camera addTarget:_filter];
    
}


- (void)destory
{
//    _camera.inputCamera.torchMode
    [_camera stopCameraCapture];
    [_camera removeAllTargets];
    [_filter removeAllTargets];
    _camera = nil;
    _filter = nil;
    _writer = nil;
    _gpuView = nil;
    _player = nil;
    _view.recorderLayer = nil;
    _isPrepare = NO;
}


- (void)prepareWithCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    GPUImageVideoCamera *camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_sessionPreset cameraPosition:cameraPosition];
    
    [camera.videoCaptureConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeCinematic];
    //输出图像旋转方式
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    camera.horizontallyMirrorFrontFacingCamera = YES;
    [camera addAudioInputsAndOutputs];
    
    GPUImageView *gpuView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    gpuView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    gpuView.clipsToBounds = YES;
    _gpuView = gpuView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _view.recorderLayer = gpuView;
    });
    
    [_filter addTarget:gpuView];
    
    [camera addTarget:_filter];
    
    [camera startCameraCapture];
    
    if (self.accompanyAudioURL) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.accompanyAudioURL error:nil];
        _player.enableRate = YES;
        [_player prepareToPlay];
        _player.currentTime = self.accompanyAudioStartTime;
        
    }
    
    _camera = camera;
    
    _isPrepare = YES;
    
    if ([_delegate respondsToSelector:@selector(recorderDidPrepared:)]) {
        [_delegate recorderDidPrepared:self];
    }
    
}

- (void)prepare
{
    [self prepareWithCameraPosition:AVCaptureDevicePositionFront];
    
}

- (void)start
{
    if (self.duration && _currentTime >= self.duration) {
        return;
    }
    
    if (_status == KCRecorderStatusRecording) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(recorderWillStart:)]) {
        [self.delegate recorderWillStart:self];
    }
    
    NSURL *url = self.destinationURL;
    
    KCRecorderItem *item = [[KCRecorderItem alloc] initWithURL:url];
    item.rate = self.rate;
    item.accompanyAudioURL = self.accompanyAudioURL;
    
    KCRecorderItem *lastItem = _items.lastObject;
    
    if (lastItem) {
        item.accompanyAudioStartTime = lastItem.accompanyAudioEndTime;
    }else {
        item.accompanyAudioStartTime = [self accompanyAudioStartTime];
    }
    
    item.startTime = _currentTime;
    
    [_items addObject:item];
    
    unlink([url.path UTF8String]);
    
    CGSize size = _videoSize;
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(_view.bounds.size.width, _view.bounds.size.height);
    }
    
    /*
    NSDictionary *videoSetting = _videoSetting;
    
    if (!videoSetting) {
        //写入视频大小
        NSInteger numPixels = size.width * size.height;
        //每像素比特
        CGFloat bitsPerPixel = 8;
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{
                                                AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                AVVideoExpectedSourceFrameRateKey : @(60),
                                                AVVideoMaxKeyFrameIntervalKey : @(60),
                                                AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
                                                };
        
        //视频属性
        videoSetting = @{
                          AVVideoCodecKey : AVVideoCodecH264,
                          AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
                          AVVideoWidthKey : @(size.width),
                          AVVideoHeightKey : @(size.height),
                          AVVideoCompressionPropertiesKey : compressionProperties
                          };
    }*/
    
    GPUImageMovieWriter *writer = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:size fileType:_fileType outputSettings:_videoSetting];
    
    __weak typeof(self) weakSelf = self;
    writer.completionBlock = ^{
        
        item.endTime = _currentTime;
        item.accompanyAudioEndTime = _player.currentTime;
        
        [item finish:^{
            
            if ([weakSelf.delegate respondsToSelector:@selector(recorder:didStoppedForItem:)]) {
                [weakSelf.delegate recorder:weakSelf didStoppedForItem:item];
            }
            
            if (weakSelf.duration && weakSelf.currentTime >= weakSelf.duration) {
                
                if ([weakSelf.delegate respondsToSelector:@selector(recorder:didCompletedForItems:)]) {
                    [weakSelf.delegate recorder:weakSelf didCompletedForItems:weakSelf.items];
                }
                
            }
        }];
        
        
    };
    writer.failureBlock = ^(NSError *error) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(recorder:didFailedForItem:error:)]) {
            [weakSelf.delegate recorder:weakSelf didFailedForItem:item error:error];
        }
        
    };
    
    writer.encodingLiveVideo = YES;
    
    if ([self shouldContainVoice]) {
        writer.hasAudioTrack = YES;
        _camera.audioEncodingTarget = writer;
    }
    
    [_filter addTarget:writer];
    [writer startRecording];
    _writer = writer;
    
    if ([self shouldPlayAudioWhenReocrding]) {
        
        _player.currentTime = item.accompanyAudioStartTime;
        _player.rate = 1 / item.rate;
        [_player play];
        
    }
    
    _status = KCRecorderStatusRecording;
    [self statusDidChanged];
    [self addTimer];
    
    if ([_delegate respondsToSelector:@selector(recorder:didStartedForItem:)]) {
        [_delegate recorder:self didStartedForItem:item];
    }
    
}

- (void)stop
{
    if (_status == KCRecorderStatusStopped) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(recorderWillStop:)]) {
        [self.delegate recorderWillStop:self];
    }
    
    [_writer finishRecordingWithCompletionHandler:^{
        
        [_filter removeTarget:_writer];
        _camera.audioEncodingTarget = nil;
        [_player pause];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self removeTimer];
            
        });
        
    }];
    
    _status = KCRecorderStatusStopped;
    [self statusDidChanged];
    
}

- (void)resume
{
    if (_status == KCRecorderStatusRecording) {
        return;
    }
    [_writer setPaused:NO];
    
    if ([self shouldPlayAudioWhenReocrding]) {
        
        [_player play];
        
    }
    _status = KCRecorderStatusRecording;
    [self statusDidChanged];
    [self addTimer];
}

- (void)pause
{
    
    if (_status == KCRecorderStatusStopped || _status == KCRecorderStatusPaused) {
        return;
    }
    [_writer setPaused:YES];
    [_player pause];
    _status = KCRecorderStatusPaused;
    [self statusDidChanged];
    [self removeTimer];
}

- (void)cancel
{
    if (_status == KCRecorderStatusStopped) {
        return;
    }
    [_writer cancelRecording];
    _status = KCRecorderStatusStopped;
    [self statusDidChanged];
    [self removeTimer];
    
    [_items removeLastObject];
    [self resetCurrentTime];
}

- (void)switchCamera
{
    [_camera rotateCamera];
}

- (void)switchToCameraPosition:(AVCaptureDevicePosition)position
{
    switch (position) {
        case AVCaptureDevicePositionBack:
            
            if (_camera.isFrontFacingCameraPresent) {
                [_camera rotateCamera];
            }
            break;
        case AVCaptureDevicePositionFront:
        {
            if (_camera.isBackFacingCameraPresent) {
                [_camera rotateCamera];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)addTimer
{
    _timer = [NSTimer timerWithTimeInterval:_timeInterval target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)updateCurrentTime
{
    _currentTime += _timer.timeInterval / self.rate;
    
    !_currentTimeDidChangedBlock ? : _currentTimeDidChangedBlock(self, _currentTime);
    
    if ([_delegate respondsToSelector:@selector(recorderCurrentTimeDidChanged:)]) {
        [_delegate recorderCurrentTimeDidChanged:self];
    }
    
    
    if (self.duration && _currentTime >= self.duration) {
        
        [self stop];
    }
}

- (void)resetCurrentTime
{
    _currentTime = 0;
    for (KCRecorderItem *item in _items) {
        _currentTime += item.duration;
    }
    !_currentTimeDidChangedBlock ? : _currentTimeDidChangedBlock(self, _currentTime);
    
    if ([_delegate respondsToSelector:@selector(recorderCurrentTimeDidChanged:)]) {
        [_delegate recorderCurrentTimeDidChanged:self];
    }
    
}

- (void)statusDidChanged
{
    if ([_delegate respondsToSelector:@selector(recorderStatusDidChanged:)]) {
        [_delegate recorderStatusDidChanged:self];
    }
    !_statusDidChangedBlock ? : _statusDidChangedBlock(self, _status);
}

@end
