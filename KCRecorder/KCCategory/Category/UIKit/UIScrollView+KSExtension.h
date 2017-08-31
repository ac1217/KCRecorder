//
//  UIScrollView+KSExtension.h
//  KuShow
//
//  Created by iMac on 2017/6/16.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, KCScrollViewScrollDirectionTo) {
    KCScrollViewScrollDirectionToNone = 0,
    KCScrollViewScrollDirectionToLeft = 1,
    KCScrollViewScrollDirectionToRight = 2,
    KCScrollViewScrollDirectionToTop = 3,
    KCScrollViewScrollDirectionToBottom = 4,
    KCScrollViewScrollDirectionToBottomRight = 5,
    KCScrollViewScrollDirectionToTopLeft = 6,
    KCScrollViewScrollDirectionToBottomLeft = 7,
    KCScrollViewScrollDirectionToTopRight = 8,
};

@interface UIScrollView (KSExtension)

@property (nonatomic,assign) KCScrollViewScrollDirectionTo kc_scrollDirectionTo;

@property (nonatomic,copy) void(^kc_scrollDirectionToDidChangedBlock)(KCScrollViewScrollDirectionTo d);

@end
