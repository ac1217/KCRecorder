//
//  KCRecorder.m
//  KCRecorder
//
//  Created by iMac on 2017/8/30.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorder.h"

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

#pragma mark -DataSource

- (float)accompanyAudioRate
{
    
    if ([_dataSource respondsToSelector:@selector(accompanyAudioRateWithRecorder:)]) {
        return [_dataSource accompanyAudioRateWithRecorder:self];
    }
    return 1;
}

- (NSURL *)accompanyAudioURL
{
    
    if ([_dataSource respondsToSelector:@selector(accompanyAudioURLWithRecorder:)]) {
        return [_dataSource accompanyAudioURLWithRecorder:self];
    }
    return nil;
}

- (NSTimeInterval)accompanyAudioStartTime
{
    if ([_dataSource respondsToSelector:@selector(accompanyAudioStartTimeWithRecorder:)]) {
        return [_dataSource accompanyAudioStartTimeWithRecorder:self];
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
        _fileType = AVFileTypeQuickTimeMovie;
        _view = [KCRecorderView new];
        _items = @[].mutableCopy;
        _filter = _emptyFilter;
        // 1、创建滤镜组
        _beautifyFilter = [[GPUImageFilterGroup alloc] init];
        
        // 2、创建滤镜（设置滤镜的引用关系）
        // 2-1、 初始化滤镜
        GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init]; // 磨皮
        GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init]; // 曝光
        GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init]; // 美白
        GPUImageSaturationFilter *satureationFilter = [[GPUImageSaturationFilter alloc] init]; // 饱和
        
        // 2-2、设置滤镜的引用关系
        [bilateralFilter addTarget:brightnessFilter];
        [brightnessFilter addTarget:exposureFilter];
        [exposureFilter addTarget:satureationFilter];
        
        // 3、设置滤镜组链的起点&&终点
        _beautifyFilter.initialFilters = @[bilateralFilter];
        _beautifyFilter.terminalFilter = satureationFilter;
        
//        _beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        _emptyFilter = [[GPUImageFilter  alloc] init];
        _cameraPosition = AVCaptureDevicePositionFront;
        _timeInterval = 1;
    }
    return self;
}

#pragma mark -Public Method
- (void)removeLastItem
{
    [self removeItemAtIndex:_items.count - 1];
}

- (void)removeItemAtIndex:(NSInteger)index
{
    if (index < 0 && index >= _items.count) {
        return;
    }
    
    [_items removeObjectAtIndex:index];
    
    [self resetCurrentTime];
}

- (void)beginPreview
{
    [_camera resumeCameraCapture];
}

- (void)endPreview
{
    [_camera pauseCameraCapture];
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

- (void)prepare
{
   GPUImageVideoCamera *camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_sessionPreset cameraPosition:_cameraPosition];
    camera.delegate = self;
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
        
    }
    
    _camera = camera;
    
    _isPrepare = YES;
    
}

- (void)start
{
    if (self.duration && _currentTime >= self.duration) {
        return;
    }
    
    if (_status == KCRecorderStatusRecording) {
        return;
    }
    
    NSURL *url = self.destinationURL;
    
    KCRecorderItem *item = [[KCRecorderItem alloc] initWithURL:url];
    item.duration = _currentTime;
    [_items addObject:item];
    
    unlink([url.path UTF8String]);
    
    CGSize size = _videoSize;
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = _view.bounds.size;
    }
    
    //写入视频大小
    NSInteger numPixels = size.width * size.height;
    //每像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{
                                            AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(60),
                                             AVVideoMaxKeyFrameIntervalKey : @(60),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
                                            };
    
    //视频属性
    NSDictionary *outputSetting = @{
                                    AVVideoCodecKey : AVVideoCodecH264,
                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(size.width),
                                       AVVideoHeightKey : @(size.height),
                                       AVVideoCompressionPropertiesKey : compressionProperties
                                    };
    
    GPUImageMovieWriter *writer = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:size fileType:_fileType outputSettings:outputSetting];
    
    __weak typeof(self) weakSelf = self;
    writer.completionBlock = ^{
        
        !weakSelf.finishBlock ? : weakSelf.finishBlock(weakSelf);
        
        if (weakSelf.duration && weakSelf.currentTime >= weakSelf.duration) {
            
            !weakSelf.completionBlock ? : weakSelf.completionBlock(weakSelf);
        }
        
    };
    writer.failureBlock = ^(NSError *error) {
        
        !weakSelf.failureBlock ? : weakSelf.failureBlock(weakSelf, error);
        NSLog(@"failureBlock");
    };
    
    writer.encodingLiveVideo = YES;
    writer.hasAudioTrack = YES;
    
    switch (_track) {
        case KCRecorderTrackBoth:{
            
            _camera.audioEncodingTarget = writer;
            [_filter addTarget:writer];
            
            
            // 音频设置
//            NSDictionary *audioSetting =  @{
//                                            AVEncoderBitRatePerChannelKey : @(28000),
//                                               AVFormatIDKey : @(kAudioFormatMPEG4AAC),
//                                               AVNumberOfChannelsKey : @(2),
//                                               AVSampleRateKey : @(22050)
//                                            };
//            [writer setHasAudioTrack:YES audioSettings:audioSetting];
        }
            break;
        case KCRecorderTrackVideo:
            
            _camera.audioEncodingTarget = nil;
            [_filter addTarget:writer];
//            [writer setHasAudioTrack:YES audioSettings:nil];
            break;
        case KCRecorderTrackAudio:
        {
            // 音频设置
//            NSDictionary *audioSetting =  @{ AVEncoderBitRatePerChannelKey : @(28000),
//                                             AVFormatIDKey : @(kAudioFormatMPEG4AAC),
//                                             AVNumberOfChannelsKey : @(1),
//                                             AVSampleRateKey : @(22050) };
//            [writer setHasAudioTrack:YES audioSettings:audioSetting];
            _camera.audioEncodingTarget = writer;
        }
            break;
            
        default:
            break;
    }
    
    [writer startRecording];
    _writer = writer;
    
    _player.rate = self.accompanyAudioRate;
    _player.currentTime = _currentTime + self.accompanyAudioStartTime;
    [_player play];
    
    _status = KCRecorderStatusRecording;
    
    !_recordStatusBlock ? : _recordStatusBlock(self, _status);
    [self addTimer];
    
}

- (void)stop
{
    if (_status == KCRecorderStatusStopped) {
        return;
    }
    
    [_filter removeTarget:_writer];
    _camera.audioEncodingTarget = nil;
    [_player pause];
    [_writer finishRecordingWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _status = KCRecorderStatusStopped;
            !_recordStatusBlock ? : _recordStatusBlock(self, _status);
        });
        
    }];
    KCRecorderItem *item = _items.lastObject;
    item.duration = _currentTime - item.duration;
    [self removeTimer];
}

- (void)resume
{
    if (_status == KCRecorderStatusRecording) {
        return;
    }
    [_writer setPaused:NO];
    _player.rate = self.accompanyAudioRate;
    [_player play];
    _status = KCRecorderStatusRecording;
    !_recordStatusBlock ? : _recordStatusBlock(self, _status);
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
    !_recordStatusBlock ? : _recordStatusBlock(self, _status);
    [self removeTimer];
}

- (void)cancel
{
    if (_status == KCRecorderStatusStopped) {
        return;
    }
    [_writer cancelRecording];
    _status = KCRecorderStatusStopped;
    !_recordStatusBlock ? : _recordStatusBlock(self, _status);
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
    _currentTime += _timer.timeInterval;
    !_currentTimeBlock ? : _currentTimeBlock(self, _currentTime);
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
    !_currentTimeBlock ? : _currentTimeBlock(self, _currentTime);
}

#pragma mark -GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
}

@end
