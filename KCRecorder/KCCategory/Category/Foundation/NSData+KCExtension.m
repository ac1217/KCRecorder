//
//  NSData+KCExtension.m
//  Sugar
//
//  Created by iMac on 2017/8/15.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "NSData+KCExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (KCExtension)

- (NSString *)kc_MD5String
{
    const char *cStr = (const char*)[self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)self.length, result);
    
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [mutableString appendFormat:@"%02x", result[i]];
    
    return [NSString stringWithString:mutableString];
}

@end
