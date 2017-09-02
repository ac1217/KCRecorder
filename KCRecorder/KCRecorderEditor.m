//
//  KCRecorderEditor.m
//  KCRecorder
//
//  Created by zhangweiwei on 2017/9/1.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorderEditor.h"
#import <UIKit/UIKit.h>

@implementation KCRecorderEditorCombineOption

- (instancetype)init
{
    if (self = [super init]) {
        _outputFileType = AVFileTypeMPEG4;
        _videoRate = 1;
        _audioRate = 1;
    }
    return self;
}

@end

@implementation KCRecorderEditor

+ (void)combineWithOption:(KCRecorderEditorCombineOption *)option completion:(void (^)(NSURL *, BOOL, AVAssetExportSessionStatus))completion
{
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:option.audioURL options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:option.videoURL options:nil];
    
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(option.videoStartTime, videoAsset.duration.timescale), CMTimeMakeWithSeconds(option.videoDuration, videoAsset.duration.timescale));
    
    
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
     //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    
    if (option.isContainVoice) {
    
        AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:nil atTime:kCMTimeZero error:nil];
    }
    
    
    //声音长度截取范围==视频长度
    //    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    CMTimeRange audioTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(option.audioStartTime, audioAsset.duration.timescale), CMTimeMakeWithSeconds(option.audioDuration, audioAsset.duration.timescale));
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    //AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    unlink([option.outputURL.path UTF8String]);
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = option.outputFileType;
    
    assetExportSession.outputURL = option.outputURL;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        
        !completion ? : completion(option.outputURL, assetExportSession.status == AVAssetExportSessionStatusCompleted, assetExportSession.status);
        
        
        
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



@end
