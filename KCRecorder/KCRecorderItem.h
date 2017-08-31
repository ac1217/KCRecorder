//
//  KCRecorderItem.h
//  KCRecorder
//
//  Created by iMac on 2017/8/31.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCRecorderItem : NSObject

@property (nonatomic,strong) NSURL *URL;

@property (nonatomic,assign) NSTimeInterval duration;

@property (nonatomic,assign, readonly) NSInteger size;

- (instancetype)initWithURL:(NSURL *)url;

@end
