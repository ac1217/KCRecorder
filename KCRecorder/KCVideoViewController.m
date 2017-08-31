//
//  VideoViewController.m
//  KCRecorder
//
//  Created by iMac on 2017/8/30.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCVideoViewController.h"
#import "KSPlayer.h"
@interface KCVideoViewController ()
@property (nonatomic,strong) KSPlayer *player;
@end

@implementation KCVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _player = [KSPlayer new];
    _player.loopCount = NSIntegerMax;
    _player.URL = self.url;
    
    _player.view.frame = self.view.bounds;
    [self.view addSubview:_player.view];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
