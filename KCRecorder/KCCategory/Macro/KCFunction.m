//
//  KCFunction.m
//  categoryDemo
//
//  Created by zhangweiwei on 16/6/29.
//  Copyright © 2016年 Erica. All rights reserved.
//

#import "KCFunction.h"


CGFloat kc_CGPointTwoPointDistance(CGPoint point, CGPoint other)
{

    CGFloat xDist = (other.x - point.x);
    CGFloat yDist = (other.y - point.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

NSTimeInterval kc_codeExecuteTimeInBlock(void(^block)())
{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    !block ? : block();
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    
//    NSLog(@"Linked in %f ms", linkTime *1000.0);
    
    return linkTime;
    
}
