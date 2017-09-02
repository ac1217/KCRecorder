//
//  KCRecorderEditor.h
//  KCRecorder
//
//  Created by zhangweiwei on 2017/9/1.
//  Copyright © 2017年 iMac. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@interface KCRecorderEditorCombineOption: NSObject

@property (nonatomic,strong) NSURL *audioURL;
@property (nonatomic,strong) NSURL *videoURL;

@property (nonatomic,strong) NSURL *outputURL;

@property (nonatomic,assign, getter=isContainVoice) BOOL containVoice;
@property (nonatomic,assign) NSTimeInterval audioStartTime;
@property (nonatomic,assign) NSTimeInterval audioDuration;
@property (nonatomic,assign) NSTimeInterval videoStartTime;
@property (nonatomic,assign) NSTimeInterval videoDuration;
@property (nonatomic,assign) float audioRate;
@property (nonatomic,assign) float videoRate;

@property (nonatomic,copy) NSString *outputFileType;

@end

@interface KCRecorderEditor : NSObject

+ (void)combineWithOption:(KCRecorderEditorCombineOption *)option
                            completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion;



+ (UIImage *)imageWithVideoURL:(NSURL *)url
                        atTime:(NSTimeInterval)time;

@end
