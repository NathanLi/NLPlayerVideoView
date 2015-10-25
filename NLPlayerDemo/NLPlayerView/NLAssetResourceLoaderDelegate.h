//
//  NLAssetResourceLoader.h
//  NLPlayerDemo
//
//  Created by nathan@hoomic.com on 15/10/16.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const NLCustomScheme;

/**
 *  在读取内容完成后会发出的通知
 */
extern NSString *const NLNotificationAssetRsourceLoadCompletion;

@import AVFoundation;

@interface NLAssetResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic, copy) void (^completionBlock)(NSError *error);
@property (nonatomic, copy) void (^downloadProgressBlock)(float progress, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);


- (void)setDownloadProgressBlock:(void (^)(float progress, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))block;
- (void)setCompletionBlock:(void (^)(NSError *error))completionBlock;

+ (NSURL *)customSchemeWithUrl:(NSURL *)url;

@end
