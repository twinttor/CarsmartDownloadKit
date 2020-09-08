//
//  MD5Tool.m
//  DownloadDemo
//
//  Created by carsmart on 2017/8/11.
//  Copyright © 2017年 carsmart. All rights reserved.
//

#import "MD5Tool.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MD5Tool
#pragma mark - 32位 小写
+(NSString *)MD5ForLower32Bit:(NSString *)str{
    return [MD5Tool MD5ForLower32Bit:str is32Bit:true];
}

+(NSString *)MD5ForLower32Bit:(NSString *)str is32Bit:(BOOL)is32Bit{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSInteger factor = is32Bit ? 2 : 1;
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * factor];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        if (is32Bit) {
            [digest appendFormat:@"%02x", result[i]];
        }else{
            [digest appendFormat:@"%2x", result[i]];
        }
    }
    
    return digest;
}

#pragma mark - 32位 大写
+(NSString *)MD5ForUpper32Bit:(NSString *)str{
    return [MD5Tool MD5ForUpper32Bit:str is32Bit:true];
}

+(NSString *)MD5ForUpper32Bit:(NSString *)str is32Bit:(BOOL)is32Bit{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSInteger factor = is32Bit ? 2 : 1;
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * factor];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        if (is32Bit) {
            [digest appendFormat:@"%02X", result[i]];
        }else{
            [digest appendFormat:@"%2X", result[i]];
        }
    }
    
    return digest;
}

#pragma mark - 16位 大写
+(NSString *)MD5ForUpper16Bit:(NSString *)str{
    return [MD5Tool MD5ForUpper32Bit:str is32Bit:false];
}


#pragma mark - 16位 小写
+(NSString *)MD5ForLower16Bit:(NSString *)str{
    return [MD5Tool MD5ForLower32Bit:str is32Bit:false];
}

@end
