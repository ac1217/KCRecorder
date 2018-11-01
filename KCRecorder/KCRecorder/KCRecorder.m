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
    KCRecorderStatus _status;
    GPUImageFilterGroup *_beautifyFilter;
    GPUImageFilter *_emptyFilter;
    NSMutableArray *_items;
    BOOL _isPrepare;
    
}

@property (nonatomic,strong) GPUImageStillCamera *camera;

@property (nonatomic,strong) GPUImageMovieWriter *writer;

//@property (nonatomic,strong) AVAssetReader *reader;
//@property (nonatomic,strong) AVAssetReaderOutput *readerOutput;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) AVAudioPlayer *player;

@end

@implementation KCRecorder

#pragma mark -Setter

#pragma mark -Getter
- (KCRecorderItem *)currentItem
{
    return self.items.lastObject;
}


#pragma mark -DataSource

- (BOOL)shouldPlayAudioWhenReocrding
{
    
    if ([_dataSource respondsToSelector:@selector(recorder:shouldPlayAudioWhenReocrdingForItem:)]) {
        return [_dataSource recorder:self shouldPlayAudioWhenReocrdingForItem:self.currentItem];
    }
    
    return YES;
}

//- (BOOL)shouldContainVoice
//{
//    
//    if ([_dataSource respondsToSelector:@selector(recorder:shouldContainVoiceForItem:)]) {
//        return [_dataSource recorder:self shouldContainVoiceForItem:self.currentItem];
//    }
//    return YES;
//}

- (float)rate
{
    
    if ([_dataSource respondsToSelector:@selector(recorder:rateForItem:)]) {
        return [_dataSource recorder:self rateForItem:self.currentItem];
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
        return [_dataSource recorder:self accompanyAudioStartTimeForItem:self.currentItem];
    }
    return 0;
}

- (NSURL *)destinationURL
{
    return [_dataSource recorder:self destinationURLWithCurrentTime:_currentTime];
}

#pragma mark -Life Cycle
- (void)dealloc
{
    
    [self destory];
}


- (instancetype)init
{
    if (self = [super init]) {
//        AVCaptureSessionPresetiFrame960x540
        _sessionPreset = AVCaptureSessionPresetHigh;
        _fileType = AVFileTypeMPEG4;
        _view = [KCRecorderView new];
        _items = @[].mutableCopy;
        // 1、创建滤镜组
        _beautifyFilter = [[GPUImageFilterGroup alloc] init];
        
        // 2、创建滤镜（设置滤镜的引用关系）
        // 2-1、 初始化滤镜
        GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init]; // 磨皮
        bilateralFilter.distanceNormalizationFactor = 4;
        GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init]; // 曝光
//        exposureFilter.exposure = 1;
        GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init]; // 美白
        brightnessFilter.brightness = 0.1;
        GPUImageSaturationFilter *satureationFilter = [[GPUImageSaturationFilter alloc] init]; // 饱和
        satureationFilter.saturation = 1.1;
        
        // 2-2、设置滤镜的引用关系
        [bilateralFilter addTarget:brightnessFilter];
        [brightnessFilter addTarget:exposureFilter];
        [exposureFilter addTarget:satureationFilter];
        
        // 3、设置滤镜组链的起点&&终点
        [_beautifyFilter addFilter:bilateralFilter];
        [_beautifyFilter addFilter:brightnessFilter];
        [_beautifyFilter addFilter:exposureFilter];
        _beautifyFilter.initialFilters = @[bilateralFilter];
        _beautifyFilter.terminalFilter = satureationFilter;
        
        _emptyFilter = [[GPUImageFilter  alloc] init];
        
        _filter = _beautifyFilter;
        
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
    
    if ([_delegate respondsToSelector:@selector(recorder:didRemovedItem:atIndex:)]) {
        [_delegate recorder:self didRemovedItem:item atIndex:index];
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

- (BOOL)isTorchSupport
{
    return self.cameraPosition == AVCaptureDevicePositionBack;
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


- (void)setFilter:(GPUImageOutput <GPUImageInput>*)filter
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
//    _reader = nil;
//    _readerOutput = nil;
    [self removeTimer];
}


- (void)prepareWithCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    GPUImageStillCamera *camera = [[GPUImageStillCamera alloc] initWithSessionPreset:_sessionPreset cameraPosition:cameraPosition];
    camera.delegate = self;
//    [camera.videoCaptureConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeCinematic];
    
//    camera.captureSessionPreset = AVCaptureSessionPreset640x480;
    
    //输出图像旋转方式
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    camera.horizontallyMirrorFrontFacingCamera = YES;
    [camera addAudioInputsAndOutputs];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GPUImageView *gpuView = [[GPUImageView alloc] init];
        gpuView.fillMode = 2;
//        gpuView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        gpuView.clipsToBounds = YES;
        _gpuView = gpuView;
        _view.recorderLayer = gpuView;
        [_filter addTarget:gpuView];
        
    });
    
//    AVMediaType
    
    [camera addTarget:_filter];
    
    [camera startCameraCapture];
    
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
    KCRecorderItem *item = [[KCRecorderItem alloc] init];
    [_items addObject:item];
    
    if ([_delegate respondsToSelector:@selector(recorder:willStartForItem:)]) {
        [_delegate recorder:self willStartForItem:self.currentItem];
    }
    
    NSURL *url = self.destinationURL;
    self.currentItem.containVoice = self.hasVoiceTrack;
    self.currentItem.URL = url;
    self.currentItem.rate = self.rate;
    self.currentItem.accompanyAudioURL = self.accompanyAudioURL;
    self.currentItem.startTime = _currentTime;
    self.currentItem.accompanyAudioStartTime = [self accompanyAudioStartTime];
    
    unlink([url.path UTF8String]);
    
    CGSize size = _videoSize;
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(_view.bounds.size.width, _view.bounds.size.height);
    }
    
    /**/
    NSDictionary *videoSetting = _videoSetting;
    
    if (!videoSetting) {
        //写入视频大小
        NSInteger numPixels = size.width * size.height;
        //每像素比特
        CGFloat bitsPerPixel = 3;
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{
                                                AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                AVVideoExpectedSourceFrameRateKey : @(20),
                                                AVVideoMaxKeyFrameIntervalKey : @(20),
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
    }
    
    GPUImageMovieWriter *writer = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:size fileType:_fileType outputSettings:videoSetting];
    
    __weak typeof(self) weakSelf = self;
    
    writer.completionBlock = ^{
        
        [weakSelf.currentItem finish:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                NSString *currentTimeStr = [NSString stringWithFormat:@"%f", weakSelf.currentTime];
                NSString *durationStr = [NSString stringWithFormat:@"%f", weakSelf.duration];
                
                
                // 这样比较才准确
                if (weakSelf.duration && currentTimeStr.floatValue >= durationStr.floatValue) {
                    
                    if ([weakSelf.delegate respondsToSelector:@selector(recorder:didCompletedForItems:)]) {
                        
                        [weakSelf.delegate recorder:weakSelf didCompletedForItems:weakSelf.items];
                    }
                    
                }
            });
            
        }];
        
        
    };
    writer.failureBlock = ^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(recorder:didFailedForItem:error:)]) {
                [weakSelf.delegate recorder:weakSelf didFailedForItem:weakSelf.currentItem error:error];
            }
        });
        
    };
    
    writer.encodingLiveVideo = YES;
    
    [writer setHasAudioTrack:YES audioSettings:nil];
    
//    if (self.hasVoiceTrack) {
    _camera.audioEncodingTarget = writer;
//    }

    [_filter addTarget:writer];
    [writer startRecording];
    _writer = writer;
    
    if (self.accompanyAudioURL) {
        /*
        AVAsset *asset = [AVAsset assetWithURL:[self accompanyAudioURL]];
        NSError *error = nil;
        _reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
        
        if (!error) {
            
            CMTime start = CMTimeMakeWithSeconds([self accompanyAudioStartTime], asset.duration.timescale);
            CMTime dutation = CMTimeMakeWithSeconds(self.duration, asset.duration.timescale);
            _reader.timeRange = CMTimeRangeMake(start, dutation);
            
            NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
            AVAssetTrack *audioTrack = audioTracks.firstObject;
            
            NSDictionary *outputSetting = @{
                                            AVSampleRateKey : @([[AVAudioSession sharedInstance] sampleRate]),
                                            AVNumberOfChannelsKey: @1,
                                            AVFormatIDKey : @(kAudioFormatLinearPCM)
                                            };
            
            _readerOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:outputSetting];
            _readerOutput.supportsRandomAccess = YES;
            if ([_reader canAddOutput:_readerOutput]) {
                [_reader addOutput:_readerOutput];
            }
            [_reader startReading];
            
        }*/
        
        
        if ([self shouldPlayAudioWhenReocrding]) {
            
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.accompanyAudioURL error:nil];
            _player.enableRate = YES;
            [_player play];
            _player.currentTime = self.currentItem.accompanyAudioStartTime;
            _player.rate = 1 / self.currentItem.rate;
            
        }
        
    }
    
    
    _status = KCRecorderStatusRecording;
    [self statusDidChanged];
    [self addTimer];
    
    if ([_delegate respondsToSelector:@selector(recorder:didStartedForItem:)]) {
        [_delegate recorder:self didStartedForItem:self.currentItem];
    }
    
}

- (void)stop
{
    if (_status == KCRecorderStatusStopped) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(recorder:willStopForItem:)]) {
        [_delegate recorder:self willStopForItem:self.currentItem];
    }
    
    
    self.currentItem.endTime = self.currentTime;
    
    self.currentItem.accompanyAudioEndTime = self.player.currentTime;
    
    [_player pause];
    
    _status = KCRecorderStatusStopped;
    [self statusDidChanged];
    [self removeTimer];
    
    __weak typeof(self) weakSelf = self;
    [_writer finishRecordingWithCompletionHandler:^{
        
        [weakSelf.filter removeTarget:weakSelf.writer];
        weakSelf.camera.audioEncodingTarget = nil;
        weakSelf.writer = nil;
        
        
    }];
    
    if ([_delegate respondsToSelector:@selector(recorder:didStoppedForItem:)]) {
        [_delegate recorder:weakSelf didStoppedForItem:self.currentItem];
    }
    
    
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
    if (_status != KCRecorderStatusRecording) {
        return;
    }

    _currentTime += _timer.timeInterval / self.rate;
    _accompanyAudioCurrentTime = _player.currentTime;
    !_currentTimeDidChangedBlock ? : _currentTimeDidChangedBlock(self, _currentTime);
    
    if ([_delegate respondsToSelector:@selector(recorderCurrentTimeDidChanged:)]) {
        [_delegate recorderCurrentTimeDidChanged:self];
    }
    
//    NSLog(@"%f---%f", _currentTime, self.duration);
    
    if (self.duration && _currentTime >= self.duration) {
        
//        NSLog(@"_currentTime == self.duration");
        
        [self stop];
    }
}

- (void)resetCurrentTime
{
    _currentTime = 0;
    for (KCRecorderItem *item in _items) {
        _currentTime += (item.duration / item.rate);
    }
    
    NSTimeInterval accompanyCurrentTime = self.currentItem.accompanyAudioEndTime;
    
    if (!accompanyCurrentTime) {
        accompanyCurrentTime = [self accompanyAudioStartTime];
    }
    
    _accompanyAudioCurrentTime = accompanyCurrentTime;
    
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

#pragma mark -GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if ([_delegate respondsToSelector:@selector(recorder:willOutputSampleBuffer:)]) {
        [_delegate recorder:self willOutputSampleBuffer:sampleBuffer];
    }
    
    
    /*
    if (_status == KCRecorderStatusRecording) {
        
        
        if (_reader) {
            // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
                if (_reader.status == AVAssetReaderStatusReading) {
                    
                    CMSampleBufferRef audioBuffer = [_readerOutput copyNextSampleBuffer];
                    
                    if (audioBuffer != NULL) {
                        [_writer processAudioBuffer:audioBuffer];
                        KSLog(@"写入samplebuffer");
                    }else {
                        KSLog(@"samplebuffer 为 nil");
                    }
                    
                }
            
            
            
        }
        
    }*/
    
}


- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if ([_delegate respondsToSelector:@selector(recorder:didOutputSampleBuffer:)]) {
        [_delegate recorder:self didOutputSampleBuffer:sampleBuffer];
    }
}


@end
