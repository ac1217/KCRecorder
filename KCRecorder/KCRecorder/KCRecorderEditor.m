//
//  KCRecorderEditor.m
//  KCRecorder
//
//  Created by zhangweiwei on 2017/9/1.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorderEditor.h"
#import <UIKit/UIKit.h>

@implementation KCRecorderEditorOption


- (instancetype)init
{
    if (self = [super init]) {
        _outputFileType = AVFileTypeMPEG4;
        _videoRate = 1;
        _audioRate = 1;
        _presetName = AVAssetExportPresetHighestQuality;
    }
    return self;
}

@end


@implementation KCRecorderEditor


+ (void)rateWithOption:(KCRecorderEditorOption *)option
                  completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion
{
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:option.videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    [compositionAudioTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
//    if (option.audioRate != 1) {
    
        [compositionAudioTrack scaleTimeRange:audioTrack.timeRange
                                   toDuration:CMTimeMultiplyByFloat64(audioTrack.timeRange.duration, (1 / option.audioRate))];
//    }
    
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    [compositionVideoTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
//    if (option.videoRate != 1) {
    
        [compositionVideoTrack scaleTimeRange:videoTrack.timeRange
                                   toDuration:CMTimeMultiplyByFloat64(videoTrack.timeRange.duration, (1 / option.videoRate))];
//    }
    
    unlink([option.outputURL.path UTF8String]);
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:option.presetName];
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = option.outputFileType;
    
    assetExportSession.outputURL = option.outputURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !completion ? : completion(option.outputURL, assetExportSession.status == AVAssetExportSessionStatusCompleted, assetExportSession.status);
        });
        
    }];
}

+ (void)mergeWithOption:(KCRecorderEditorOption *)option
             completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion
{
    
    if (!option.videoURLArray.count) {
        
        !completion ? : completion(nil, NO, AVAssetExportSessionStatusFailed);
        
        return;
    }
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (NSInteger i = 0; i < option.videoURLArray.count; i++) {
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:option.videoURLArray[i] options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
        
        AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        
        [compositionAudioTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:kCMTimeInvalid error:nil];
        
//        [compositionAudioTrack scaleTimeRange:audioTrack.timeRange toDuration:audioTrack.timeRange.duration];
        
        [compositionVideoTrack insertTimeRange:videoTrack.timeRange ofTrack:videoTrack atTime:kCMTimeInvalid error:nil];
        
//        [compositionVideoTrack scaleTimeRange:videoTrack.timeRange toDuration:videoTrack.timeRange.duration];
    }
    
    
    unlink([option.outputURL.path UTF8String]);
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:option.presetName];
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = option.outputFileType;
    
    assetExportSession.outputURL = option.outputURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ? : completion(option.outputURL, assetExportSession.status == AVAssetExportSessionStatusCompleted, assetExportSession.status);
        });
        
    }];
}

+ (void)combineWithOption:(KCRecorderEditorOption *)option completion:(void (^)(NSURL *, BOOL, AVAssetExportSessionStatus))completion
{
    
    /**/
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:option.audioURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:option.videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(option.videoStartTime, videoAsset.duration.timescale), CMTimeMakeWithSeconds(option.videoDuration, videoAsset.duration.timescale));
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    
    
    /**/
    if (option.isContainVoice) {
        
        AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
        
        
        if (option.videoRate != 1) {
            [compositionVoiceTrack scaleTimeRange:videoTimeRange
                                       toDuration:CMTimeMultiplyByFloat64(videoTimeRange.duration, 1 / option.videoRate)];
        }
    }
    
    if (option.videoRate != 1) {
    
        [compositionVideoTrack scaleTimeRange:videoTimeRange
                                   toDuration:CMTimeMultiplyByFloat64(videoTimeRange.duration, 1 / option.videoRate)];
        
        
    }
    
    CMTimeRange audioTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(option.audioStartTime, audioAsset.duration.timescale), CMTimeMakeWithSeconds(option.audioDuration, audioAsset.duration.timescale));
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
    if (option.audioRate != 1) {
    
        [compositionAudioTrack scaleTimeRange:audioTimeRange
                                       toDuration:CMTimeMultiplyByFloat64(audioTimeRange.duration, 1 / option.audioRate)];
    }
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:option.presetName];
    
    unlink([option.outputURL.path UTF8String]);
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = option.outputFileType;
    
    assetExportSession.outputURL = option.outputURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
  
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !completion ? : completion(option.outputURL, assetExportSession.status == AVAssetExportSessionStatusCompleted, assetExportSession.status);
        });
        
    }];

}


+ (UIImage *)imageWithVideoURL:(NSURL *)url atTime:(NSTimeInterval)time
{
    
    
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.appliesPreferredTrackTransform = YES;
    
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    
    CMTime actualTime;
    
    CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(time * asset.duration.timescale, asset.duration.timescale) actualTime:&actualTime error:nil];
    
    return [UIImage imageWithCGImage:cgImage];
}


+ (void)cutWithOption:(KCRecorderEditorOption *)option
           completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion
{
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVAsset *asset = [AVAsset assetWithURL:option.videoURL];
    
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(option.videoStartTime, asset.duration.timescale), CMTimeMakeWithSeconds(option.videoDuration, asset.duration.timescale));
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:timeRange ofTrack:([asset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [asset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:timeRange ofTrack:([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [asset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:option.presetName];
    
    unlink([option.outputURL.path UTF8String]);
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = option.outputFileType;
    
    assetExportSession.outputURL = option.outputURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !completion ? : completion(option.outputURL, assetExportSession.status == AVAssetExportSessionStatusCompleted, assetExportSession.status);
        });
        
    }];
}


+ (void)revertWithOption:(KCRecorderEditorOption *)option
              completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSError *error;
        // Initialize the reader
        AVAsset *asset = [AVAsset assetWithURL:option.videoURL];
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
        
        NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
        AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                            outputSettings:readerOutputSettings];
        [reader addOutput:readerOutput];
        [reader startReading];
        
        // read in the samples
        NSMutableArray *samples = [[NSMutableArray alloc] init];
        
        CMSampleBufferRef sample;
        while(sample = [readerOutput copyNextSampleBuffer]) {
            [samples addObject:(__bridge id)sample];
            CFRelease(sample);
        }
        
        // Initialize the writer
        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:option.outputURL
                                                          fileType:AVFileTypeMPEG4
                                                             error:&error];
        NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey,
                                               nil];
        NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                              [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                              videoCompressionProps, AVVideoCompressionPropertiesKey,
                                              nil];
        
        AVAssetWriterInput *videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoOutputSettings
                                                                       sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
        [videoInput setExpectsMediaDataInRealTime:NO];
        
        // Initialize an input adaptor so that we can append PixelBuffer
        AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:videoInput sourcePixelBufferAttributes:nil];
        
        [writer addInput:videoInput];
        
        [writer startWriting];
        
        [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[0])];
        
        // Append the frames to the output.
        // Notice we append the frames from the tail end, using the timing of the frames from the front.
        for(NSInteger i = 0; i < samples.count; i++) {
            // Get the presentation time for the frame
            CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[i]);
            
            // take the image/pixel buffer from tail end of the array
            CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)samples[samples.count - i - 1]);
            
            while (!videoInput.readyForMoreMediaData) {
                [NSThread sleepForTimeInterval:0.1];
            }
            
            [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
            
        }
        
        [writer finishWriting];
        
//        [writer finishWritingWithCompletionHandler:^{
        
            //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
            AVMutableComposition* mixComposition = [AVMutableComposition composition];
            
            AVAsset *videoAsset = [AVAsset assetWithURL:option.outputURL];
            
            CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
            
            //视频采集compositionVideoTrack
            AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
            //TimeRange截取的范围长度
            //ofTrack来源
            //atTime插放在视频的时间位置
            [compositionVideoTrack insertTimeRange:timeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
            
            
            //音频采集compositionCommentaryTrack
            AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [compositionAudioTrack insertTimeRange:timeRange ofTrack:([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [asset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
            
            //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
            AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:option.presetName];
            
            unlink([option.outputURL.path UTF8String]);
            
            //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
            assetExportSession.outputFileType = option.outputFileType;
            
            assetExportSession.outputURL = option.outputURL;
            //输出文件是否网络优化
            assetExportSession.shouldOptimizeForNetworkUse = YES;
            
            [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    !completion ? : completion(option.outputURL, assetExportSession.status == AVAssetExportSessionStatusCompleted, assetExportSession.status);
                });
                
            }];
            
//        }];
        
    });
    
}


@end
