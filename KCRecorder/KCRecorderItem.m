//
//  KCRecorderItem.m
//  KCRecorder
//
//  Created by iMac on 2017/8/31.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "KCRecorderItem.h"
#import <AVFoundation/AVFoundation.h>

@implementation KCRecorderItem

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _URL = url;
    }
    return self;
}

- (NSInteger)size
{
   NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:_URL.path error:nil];
    return attr.fileSize;
}


@end
