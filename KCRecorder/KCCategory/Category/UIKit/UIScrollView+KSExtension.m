//
//  UIScrollView+KSExtension.m
//  KuShow
//
//  Created by iMac on 2017/6/16.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "UIScrollView+KSExtension.h"
#import <objc/runtime.h>

static NSString *const kc_scrollDirectionToDidChangedBlockKey = @"kc_scrollDirectionToDidChangedBlock";
static NSString *const kc_scrollDirectionToKey = @"kc_scrollDirectionTo";
static NSString *const kc_previousContentOffsetKey = @"kc_previousContentOffset";

@interface UIScrollView ()
@property (nonatomic,assign) CGPoint kc_previousContentOffset;
@end

@implementation UIScrollView (KSExtension)

- (void)setKc_previousContentOffset:(CGPoint)kc_previousContentOffset
{
    
    objc_setAssociatedObject(self, (__bridge const void *)(kc_previousContentOffsetKey), [NSValue valueWithCGPoint:kc_previousContentOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)kc_previousContentOffset
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(kc_previousContentOffsetKey)) CGPointValue];
}

- (void)setKc_scrollDirectionTo:(KCScrollViewScrollDirectionTo)kc_scrollDirectionTo
{
    
    objc_setAssociatedObject(self, (__bridge const void *)(kc_scrollDirectionToKey), @(kc_scrollDirectionTo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KCScrollViewScrollDirectionTo)kc_scrollDirectionTo
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(kc_scrollDirectionToKey)) integerValue];
}

- (void (^)(KCScrollViewScrollDirectionTo))kc_scrollDirectionToDidChangedBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kc_scrollDirectionToDidChangedBlockKey));
}

- (void)setKc_scrollDirectionToDidChangedBlock:(void (^)(KCScrollViewScrollDirectionTo))kc_scrollDirectionToDidChangedBlock
{
    objc_setAssociatedObject(self, (__bridge const void *)(kc_scrollDirectionToDidChangedBlockKey), kc_scrollDirectionToDidChangedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);

    
}


+ (void)load
{
    Class cls = [self class];
    
    Method dealloc1 = class_getInstanceMethod(cls, @selector(setContentOffset:));
    Method dealloc2 = class_getInstanceMethod(cls, @selector(setKc_contentOffset:));
    
    method_exchangeImplementations(dealloc1 , dealloc2);
    
}

- (void)setKc_contentOffset:(CGPoint)contentOffset
{
    
    [self setKc_contentOffset:contentOffset];
    
    KCScrollViewScrollDirectionTo previousD = self.kc_scrollDirectionTo;
    
    if (contentOffset.y == self.kc_previousContentOffset.y) {
        
        if (contentOffset.x > self.kc_previousContentOffset.x) {
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToRight;
        }else if (contentOffset.x < self.kc_previousContentOffset.x) {
            
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToLeft;
        }
        
    }else if (contentOffset.x == self.kc_previousContentOffset.x) {
        if (contentOffset.y > self.kc_previousContentOffset.y) {
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToBottom;
        }else if (contentOffset.y < self.kc_previousContentOffset.y) {
            
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToTop;
        }
        
    }else {
        
        if (contentOffset.x > self.kc_previousContentOffset.x && contentOffset.y > self.kc_previousContentOffset.y) {
            
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToBottomRight;
        }else if (contentOffset.x < self.kc_previousContentOffset.x && contentOffset.y > self.kc_previousContentOffset.y) {
            
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToBottomLeft;
        }else if (contentOffset.x < self.kc_previousContentOffset.x && contentOffset.y < self.kc_previousContentOffset.y) {
            
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToTopLeft;
        }else if (contentOffset.x > self.kc_previousContentOffset.x && contentOffset.y < self.kc_previousContentOffset.y) {
            
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToTopRight;
        }else {
            self.kc_scrollDirectionTo = KCScrollViewScrollDirectionToNone;
            
        }
        
    }
    
//    if (previousD != self.kc_scrollDirectionTo) {
    
        !self.kc_scrollDirectionToDidChangedBlock ? : self.kc_scrollDirectionToDidChangedBlock(self.kc_scrollDirectionTo);
        
        
//    }
    
    
    self.kc_previousContentOffset = contentOffset;
}


@end
