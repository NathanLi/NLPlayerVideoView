//
//  NLPlayerVideoView.h
//  NLPlayerDemo
//
//  Created by nathan@hoomic.com on 15/10/16.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLAssetResourceLoaderDelegate.h"

@import AVFoundation;

@interface NLPlayerVideoView : UIView

@property (nonatomic, copy, readonly) NSURL *url;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;  // support KVO
@property (nonatomic, strong, readonly) NLAssetResourceLoaderDelegate *resourceLoaderDelegate; // support KVO

@property (nonatomic, copy) void (^playCompletionHandler)(BOOL finsihed);

- (instancetype)initWithUrl:(NSURL *)url;

- (void)setURL:(NSURL *)url;

- (AVPlayerLayer *)playerLayer;

- (void)play;

- (void)stop;

- (void)pause;

- (void)resume;

- (BOOL)isPlaying;

- (void)jumpToTime:(NSTimeInterval)time;

- (Float64)currentSecond;

- (void)setPlayCompletionHandler:(void(^)(BOOL finished))completionHandler;

@end
