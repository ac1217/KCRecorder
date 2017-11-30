//
//  KCRecorderEditor.h
//  KCRecorder
//
//  Created by zhangweiwei on 2017/9/1.
//  Copyright © 2017年 iMac. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@interface KCRecorderEditorOption: NSObject

@property (nonatomic,strong) NSURL *outputURL;
@property (nonatomic,copy) NSString *outputFileType;

@property (nonatomic,copy) NSString *presetName;

@property (nonatomic,strong) NSURL *audioURL;
@property (nonatomic,strong) NSURL *videoURL;

@property (nonatomic,assign, getter=isContainVoice) BOOL containVoice;
@property (nonatomic,assign) NSTimeInterval audioStartTime;
@property (nonatomic,assign) NSTimeInterval audioDuration;
@property (nonatomic,assign) NSTimeInterval videoStartTime;
@property (nonatomic,assign) NSTimeInterval videoDuration;

@property (nonatomic,assign) float audioRate;
@property (nonatomic,assign) float videoRate;

@property (nonatomic,strong) NSArray *videoURLArray;

@end


@interface KCRecorderEditor : NSObject

+ (void)combineWithOption:(KCRecorderEditorOption *)option
                            completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion;

+ (void)mergeWithOption:(KCRecorderEditorOption *)option
             completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion;

+ (void)rateWithOption:(KCRecorderEditorOption *)option
            completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion;

+ (void)cutWithOption:(KCRecorderEditorOption *)option
              completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion;

+ (void)revertWithOption:(KCRecorderEditorOption *)option
            completion:(void(^)(NSURL *outputURL, BOOL success, AVAssetExportSessionStatus status))completion;

+ (UIImage *)imageWithVideoURL:(NSURL *)url
                        atTime:(NSTimeInterval)time;

@end
