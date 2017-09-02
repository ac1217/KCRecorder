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

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _URL = url;
        _containVoice = NO;
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
    return [KCRecorderEditor imageWithVideoURL:self.URL atTime:0];
}


- (void)finish:(void(^)())completion
{
    
    if (!self.accompanyAudioURL) {
        !completion ? : completion();
        return;
    }
    
    KCRecorderEditorCombineOption *option = [KCRecorderEditorCombineOption new];
    option.videoURL = self.URL;
    option.audioURL = self.accompanyAudioURL;
    option.audioStartTime = self.accompanyAudioStartTime;
    option.audioDuration = self.duration * self.accompanyAudioRate;
    option.audioRate = self.accompanyAudioRate;
    option.videoDuration = self.duration;
    option.containVoice = self.isContainVoice;
    option.outputURL = self.URL;
    
    [KCRecorderEditor combineWithOption:option completion:^(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !completion ? : completion();
        });
    }];

    
}

- (void)clear
{
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.URL.path]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:self.URL error:nil];
    }
}

@end
