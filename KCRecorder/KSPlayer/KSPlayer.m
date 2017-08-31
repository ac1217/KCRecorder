//
//  KSPlayer.m
//  KSPlayer
//
//  Created by iMac on 2017/8/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KSPlayer.h"

//#import <IJKMediaFramework/IJKMediaPlayer.h>
//#import <KSYMediaPlayer/KSYMediaPlayer.h>

#import <MediaPlayer/MediaPlayer.h>

@interface KSPlayer (){
    
    KSPlayerView *_view;
    
    NSInteger _currentLoopCount;
    
    
    
}
//@property (nonatomic,strong) IJKFFMoviePlayerController *player; 
@property (nonatomic,strong) MPMoviePlayerController *player;


@property (nonatomic,strong) dispatch_source_t playProgressTimer;


@end

@implementation KSPlayer

+ (void)initialize
{
    
//    [IJKFFMoviePlayerController setLogReport:NO];
//    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEFAULT];
//#ifdef DEBUG
//    
//    [IJKFFMoviePlayerController setLogReport:YES];
//    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
//#else
//    [IJKFFMoviePlayerController setLogReport:NO];
//    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEFAULT];
//#endif
    
}

- (void)dealloc
{
    [self destoryPlayer];
}

- (void)destoryPlayer
{
    
    [self removePlayProgressTimer];
    [self removePlayerObserver];
    [self.player stop];
//    [self.player shutdown];
    self.view.playerLayer = nil;
    self.player = nil;
}

- (void)createPlayer
{
    
//    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
//    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];
//    [options setPlayerOptionIntValue:0 forKey:@"videotoolbox"];
    //解码参数，画面更清晰
//    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter"];
//    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame"];
//    [options setPlayerOptionIntValue:0 forKey:@"max_cached_duration"];
//    [options setPlayerOptionIntValue:0 forKey:@"infbuf"];
//    [options setPlayerOptionIntValue:1 forKey:@"packet-buffering"];
    
//    IJKFFMoviePlayerController *player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.URL withOptions:options];
//    player.shouldAutoplay = self.autoPlay;
//    player.scalingMode = IJKMPMovieScalingModeAspectFit;
//    [player setPauseInBackground:!self.playInBackground];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:self.URL];
    player.shouldAutoplay = self.autoPlay;
//    player.shouldAutoplay = NO;
    player.controlStyle = MPMovieControlStyleNone;
    player.repeatMode = MPMovieRepeatModeNone;
    [player prepareToPlay];
    player.view.userInteractionEnabled = NO;
    [player requestThumbnailImagesAtTimes:@[@(self.startPlayTime),@1.0] timeOption:MPMovieTimeOptionExact];
//    player.view.backgroundColor = [UIColor clearColor];
//    player.backgroundView.backgroundColor = [UIColor clearColor];
    self.view.playerLayer = player.view;
    self.player = player;
    [self addPlayerObserver];
//    [self addPlayProgressTimer];
}

- (KSPlayerView *)view
{
    if (!_view) {
        _view = [KSPlayerView new];
    }
    return _view;
}

- (instancetype)init
{
    if (self = [super init]) {
        _autoPlay = YES;
        _loopCount = 1;
    }
    return self;
}

- (void)setURL:(NSURL *)URL
{
    _URL = URL;
    
    [self destoryPlayer];
    
    if (URL) {
        
        [self createPlayer];
    }
    
}

- (void)setRate:(float)rate
{
    self.player.currentPlaybackRate = rate;
}

- (float)rate
{
    return self.player.currentPlaybackRate;
}

- (NSTimeInterval)duration
{
    return self.player.duration;
}

- (void)setVolume:(float)volume
{
//    self.player.playbackVolume = volume;
}

- (float)volume
{
//    return self.player.playbackVolume;
    return 0;
}

- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)stop
{
    [self.player stop];
}

- (KSPlayerPlayStatus)playStatus
{
    
    switch (self.player.playbackState) {
        case MPMoviePlaybackStatePaused:
        return KSPlayerPlayStatusPaused;
        break;
        case MPMoviePlaybackStateStopped:
        return KSPlayerPlayStatusStoped;
        break;
        case MPMoviePlaybackStatePlaying:
        return KSPlayerPlayStatusPlaying;
        break;
        
        default:
        return KSPlayerPlayStatusUnknow;
        break;
    }
}

- (void)seekToTime:(NSTimeInterval)time
{
    
    self.player.currentPlaybackTime = time;
    
    if (self.autoPlay) {
        [self.player play];
    }
    
    
}

- (void)removePlayProgressTimer
{
    
    if (self.playProgressTimer) {
        
        dispatch_source_cancel(self.playProgressTimer);
        self.playProgressTimer = nil;
    }
}

- (void)addPlayProgressTimer
{
    [self removePlayProgressTimer];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    
    //间隔时间
    uint64_t interval = 0.1 * NSEC_PER_SEC;
    
    dispatch_source_set_timer(timer, start, interval, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        
        CGFloat progress = weakSelf.player.currentPlaybackTime / weakSelf.player.duration;
        
        !weakSelf.playProgressBlock ? : weakSelf.playProgressBlock(weakSelf, weakSelf.player.currentPlaybackTime, weakSelf.player.duration, progress);
        
        if (weakSelf.startPlayTime && weakSelf.endPlayTime && weakSelf.player.currentPlaybackTime >= weakSelf.endPlayTime) {
            
            [weakSelf pause];
            [weakSelf playerPlaybackDidFinishNotification:nil];
            
        }
        
        
    });
    dispatch_resume(timer);
    self.playProgressTimer = timer;
}

#pragma mark -KVO
- (void)addPlayerObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerPlaybackDidFinishNotification:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerPlaybackStateDidChangeNotification:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChangeNotification:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackIsPreparedToPlayDidChangeNotification:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.player];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerReadyForDisplayDidChangeNotification:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerThumbnailImageRequestDidFinishNotification:)
                                                 name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                               object:self.player];
    
    
}

- (void)removePlayerObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerReadyForDisplayDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.player];
    
    
}


- (void)playerThumbnailImageRequestDidFinishNotification:(NSNotification *)note
{
    
    NSTimeInterval time = [note.userInfo[MPMoviePlayerThumbnailTimeKey] doubleValue];
    UIImage *image = note.userInfo[MPMoviePlayerThumbnailImageKey];
    
    !self.thumbnailImageRenderBlock ? : self.thumbnailImageRenderBlock(self, image, time);
    
}

- (void)playerReadyForDisplayDidChangeNotification:(NSNotification *)note
{
    if (self.player.readyForDisplay) {
        
        !self.readyForDisplayBlock ? : self.readyForDisplayBlock(self);
    }
}

- (void)playbackIsPreparedToPlayDidChangeNotification:(NSNotification*)notification
{
    
//    self.player.initialPlaybackTime = self.startPlayTime;
//    self.player.endPlaybackTime = self.endPlayTime;
    [self seekToTime:self.startPlayTime];
    
    !self.preparedToPlayBlock ? : self.preparedToPlayBlock(self);
    
}

    
- (void)playerLoadStateDidChangeNotification:(NSNotification*)notification
{
    MPMovieLoadState loadState = self.player.loadState;
    if ((loadState & MPMovieLoadStatePlaythroughOK) != 0) {
        !self.loadStatusBlock ? : self.loadStatusBlock(self, KSPlayerLoadStatusPlaythroughOK);
    } else if ((loadState & MPMovieLoadStateStalled) != 0) {
        !self.loadStatusBlock ? : self.loadStatusBlock(self, KSPlayerLoadStatusStalled);
    } else if((loadState & MPMovieLoadStatePlayable) != 0){
        
        !self.loadStatusBlock ? : self.loadStatusBlock(self, KSPlayerLoadStatusPlayable);
    }
    

}

- (void)playerPlaybackStateDidChangeNotification:(NSNotification*)notification
{
    
    switch (self.player.playbackState)
    {
        case MPMoviePlaybackStateStopped: {
            
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusStoped);
            [self removePlayProgressTimer];
            
            break;
        }
        case MPMoviePlaybackStatePlaying: {
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusPlaying);
            [self addPlayProgressTimer];
            break;
        }
            
        case MPMoviePlaybackStatePaused: {
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusPaused);
            [self removePlayProgressTimer];
            break;
        }
        case MPMoviePlaybackStateInterrupted: {
            [self removePlayProgressTimer];
            break;
        }
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward: {
            
            [self removePlayProgressTimer];
            break;
        }
        default: {
            !self.playStatusBlock ? : self.playStatusBlock(self, KSPlayerPlayStatusUnknow);
            
            [self removePlayProgressTimer];
            break;
        }
    }
}

- (void)playerPlaybackDidFinishNotification:(NSNotification*)notification
{
    
    _currentLoopCount++;
    
    if (_currentLoopCount >= self.loopCount) {
        
        _currentLoopCount = 0;
        
        [self.player stop];
        
        !self.playFinishBlock ? : self.playFinishBlock(self);
        
    }else {
        
        [self seekToTime:self.startPlayTime];
//        [self.player play];
        
    }
    
//    !self.playProgressBlock ? : self.playProgressBlock(self, self.player.currentPlaybackTime, self.player.duration, 1);
    
}

@end
