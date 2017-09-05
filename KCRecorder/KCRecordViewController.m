//
//  ViewController.m
//  KCRecorder
//
//  Created by iMac on 2017/8/30.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecordViewController.h"
#import "KCRecorder.h"
#import "KCVideoViewController.h"
#import "KSProgressView.h"
#import "KSVideoListController.h"

@interface KCRecordViewController ()<KCRecorderDataSource>
@property (strong, nonatomic) KSProgressView *progressView;
@property (nonatomic,strong) KCRecorder *recorder;
@end

@implementation KCRecordViewController

- (KCRecorder *)recorder
{
    if (!_recorder) {
        _recorder = [KCRecorder new];
        __weak typeof(self) weakSelf = self;
        _recorder.dataSource = self;
        _recorder.timeInterval = 0.1;
        _recorder.view.frame = self.view.bounds;
        [_recorder setFilter:self.recorder.beautifyFilter];
//        _recorder.currentTimeBlock = ^(KCRecorder *recorder, NSTimeInterval currentTime) {
//            
//            [weakSelf.progressView setProgress:currentTime / recorder.duration animated:YES];
//            
//        };
//        
//        _recorder.finishBlock = ^(KCRecorder *recorder) {
//            
//            [weakSelf.progressView markAtCurrentProgress];
//            
//        };
//        
//        _recorder.completionBlock = ^(KCRecorder *recorder) {
//            [weakSelf push:nil];
//        };
    }
    return _recorder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _progressView = [KSProgressView new];
    _progressView.markColor = [UIColor whiteColor];
    [self.view addSubview:_progressView];
    _progressView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 5);
    
    [self.view insertSubview:self.recorder.view atIndex:0];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        [self.recorder prepare];
        [self.recorder beginPreview];
        
    });

    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.recorder.isPrepare) {
        
        [self.recorder beginPreview];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.recorder.isPrepare) {
        
        [self.recorder endPreview];
    }
}

#pragma mark -KCRecorderDataSource

- (BOOL)recorder:(KCRecorder *)recorder shouldContainVoiceForItem:(KCRecorderItem *)item
{
    return NO;
}

- (NSTimeInterval)recorder:(KCRecorder *)recorder accompanyAudioStartTimeForItem:(KCRecorderItem *)item
{
    return 47;
}

- (NSURL *)recorder:(KCRecorder *)recorder accompanyAudioURLForItem:(KCRecorderItem *)item
{
//    return nil;
    return [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"m4a"];
}

- (NSURL *)recorder:(KCRecorder *)recorder destinationURLWithCurrentTime:(NSTimeInterval)currentTime
{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *path = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%zd.mp4", [[NSDate date] timeIntervalSince1970]]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    return url;
}

- (NSTimeInterval)durationWithRecorder:(KCRecorder *)recorder
{
    return 15;
}

- (IBAction)start
{
    
    [self.recorder start];
    
}
- (IBAction)finish
{
    [self.recorder stop];
    
}
- (IBAction)face:(UISwitch *)sender {
    
    if (sender.isOn) {
        [self.recorder setFilter:self.recorder.beautifyFilter];
    }else {
        [self.recorder setFilter:nil];
    }
}
- (IBAction)exchange:(id)sender {
    
    [self.recorder switchCamera];
}
- (IBAction)torne:(id)sender {
    
    [self.recorder switchTorch];
}
- (IBAction)delete:(id)sender {
    
    [self.progressView removeLastMark];
    [self.recorder removeLastItem];
}
- (IBAction)push:(id)sender {
    
    KSVideoListController *vc = [KSVideoListController new];
    vc.items = self.recorder.items;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
