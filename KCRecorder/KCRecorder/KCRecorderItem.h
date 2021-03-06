//
//  KCRecorderItem.h
//  KCRecorder
//
//  Created by iMac on 2017/8/31.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCRecorderItem : NSObject

@property (nonatomic,strong) NSURL *URL;

@property (nonatomic,assign) NSTimeInterval startTime;
@property (nonatomic,assign) NSTimeInterval endTime;

@property (nonatomic,assign, readonly) NSTimeInterval duration;

@property (nonatomic,assign, readonly) NSInteger size;

@property (nonatomic,assign) float rate;

@property (nonatomic,strong, readonly) UIImage *firstFrameImage;

@property (nonatomic,assign, getter=isContainVoice) BOOL containVoice;

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic,strong) NSURL *accompanyAudioURL;
@property (nonatomic,assign) NSTimeInterval accompanyAudioStartTime;
@property (nonatomic,assign) NSTimeInterval accompanyAudioEndTime;
@property (nonatomic,assign, readonly) NSTimeInterval accompanyAudioDuration;

- (void)finish:(void(^)())completion;

- (void)clear;

@end
