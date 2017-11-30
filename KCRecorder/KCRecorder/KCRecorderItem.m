//
//  KCRecorderItem.m
//  KCRecorder
//
//  Created by iMac on 2017/8/31.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorderItem.h"
#import <AVFoundation/AVFoundation.h>
#import "KCRecorderEditor.h"

@interface KCRecorderItem()

@end

@implementation KCRecorderItem

- (NSTimeInterval)duration
{
    return (self.endTime - self.startTime) * self.rate;
}

- (NSTimeInterval)accompanyAudioDuration
{
    return self.accompanyAudioEndTime - self.accompanyAudioStartTime;
}

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _URL = url;
        _containVoice = NO;
        _rate = 1;
    }
    return self;
}

- (NSInteger)size
{
   NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:_URL.path error:nil];
    return attr.fileSize;
}

- (UIImage *)firstFrameImage
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.URL];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.appliesPreferredTrackTransform = YES;
    
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    
    CMTime actualTime;
    
    CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(0 * asset.duration.timescale, asset.duration.timescale) actualTime:&actualTime error:nil];
    
    return [UIImage imageWithCGImage:cgImage];
    
}


- (void)finish:(void(^)())completion
{
    
    if (!self.accompanyAudioURL) {
    
        !completion ? : completion();
        
        return;
    }

    
    KCRecorderEditorOption *option = [KCRecorderEditorOption new];
    option.videoURL = self.URL;
    option.audioURL = self.accompanyAudioURL;
    option.audioStartTime = self.accompanyAudioStartTime;
    option.audioDuration = self.accompanyAudioDuration;
    option.videoRate = self.rate;
    option.videoStartTime = 0;
    option.videoDuration = self.duration;
    option.containVoice = self.isContainVoice;
    option.outputURL = self.URL;
    
    [KCRecorderEditor combineWithOption:option completion:^(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status) {
        
        !completion ? : completion();
    }];

    
}

- (void)clear
{
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.URL.path]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:self.URL error:nil];
    }
}

@end
