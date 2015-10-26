//
//  NLPlayerVideoView.m
//  NLPlayerDemo
//
//  Created by nathan@hoomic.com on 15/10/16.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import "NLPlayerVideoView.h"
#import "NLAssetResourceLoaderDelegate.h"
#import "NLPlayerFileCache.h"

@import AVFoundation;

/* Asset keys */
NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";

/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";

static void *NLPlayerVideoViewRateObservationContext = &NLPlayerVideoViewRateObservationContext;
static void *NLPlayerVideoViewStatusObservationContext = &NLPlayerVideoViewStatusObservationContext;
static void *NLPlayerVideoViewCurrentItemObservationContext = &NLPlayerVideoViewCurrentItemObservationContext;

@interface NLPlayerVideoView ()

@property (nonatomic, assign) float lastPlaybackRate;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) NLAssetResourceLoaderDelegate *resourceLoaderDelegate;

/**
 *  @brief  结束播放时的通知
 */
@property (nonatomic, weak) id observerItemPlayEnd;

@property (nonatomic, copy) NSURL *url;

@end

@implementation NLPlayerVideoView


- (void)play {
  @try {
    [self.player play];
  }
  @catch (NSException *exception) {
    NSLog(@"player video exception: %@", exception);
  }
  @finally {
    
  }

}

- (void)pause {
  self.lastPlaybackRate = self.playerLayer.player.rate;
  [self.player pause];
}

- (void)resume {
  if (self.lastPlaybackRate > .0f) {
    [self.player play];
  }
}

- (void)stop {
  [self.player setRate:.0f];
  self.lastPlaybackRate = .0f;
}

- (BOOL)isPlaying {
  return self.player.rate != .0f;
}

- (void)jumpToTime:(NSTimeInterval)time {
  [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

- (Float64)currentSecond {
  return CMTimeGetSeconds([self.player currentTime]);
}

- (AVPlayerLayer *)playerLayer {
  return (AVPlayerLayer *)self.layer;
}

#pragma mark - getter / setter
- (void)setPlayer:(AVPlayer *)player {
  [[self playerLayer] setPlayer:player];
}

- (AVPlayer *)player {
  return [[self playerLayer] player];
}

#pragma mark - KVO
- (void)registerItemPlayEndNotification {
  __weak typeof(self) weakSelf = self;
  void (^playEndCallBack)(NSNotification *note) = ^(NSNotification * _Nonnull note) {
    __strong typeof(weakSelf) self = weakSelf;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
      if (self.playCompletionHandler) {
        self.playCompletionHandler(finished);
      }
    }];
  };
  
  if (self.observerItemPlayEnd) {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerItemPlayEnd];
  }
  self.observerItemPlayEnd = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                                               object:self.playerItem
                                                                                queue:[NSOperationQueue mainQueue]
                                                                           usingBlock:playEndCallBack];
}

#pragma mark - Life cycle
- (instancetype)initWithUrl:(NSURL *) url {
  if (self = [super init]) {
    [self setURL:url];
    [[self playerLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  }
  return self;
}

- (void)setURL:(NSURL *)url {
  self.url = url;
  
  if ([self isPlaying]) {
    [self stop];
  }
  
  if (url == nil) {
    self.asset = nil;
    self.playerItem = nil;
    return;
  }
  
  [self prepareToPlay];
}

- (void)prepareToPlay {
  [self preparePlayerAsset];
  [self preparePlayerItem];
  
  self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
  [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
}

- (void)preparePlayerAsset {
  if ([[NLPlayerFileCache shareFileCache] containsDataForURL:[self.url absoluteString]]) {
    NSURL *fileURL = [[NLPlayerFileCache shareFileCache] fileURLForOriginURLString:[self.url absoluteString]];
    self.asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
  } else {
    NSURL *url = [NLAssetResourceLoaderDelegate customSchemeWithUrl:self.url];
    self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.resourceLoaderDelegate = [[NLAssetResourceLoaderDelegate alloc] init];
    [self.asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
  }
}

- (void)preparePlayerItem {
  NSArray *keys = @[@"tracks", @"duration", @"commonMetadata"];
  self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
  [self registerItemPlayEndNotification];
}

- (void)dealloc {
#ifdef DEBUG
  NSLog(@"[%@ %s]", NSStringFromClass(self.class), sel_getName(_cmd));
#endif
  
  if ([self isPlaying]) {
    [self stop];
  }
  
  if (self.observerItemPlayEnd) {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerItemPlayEnd];
    self.observerItemPlayEnd = nil;
  }
}


+ (Class)layerClass {
  return [AVPlayerLayer class];
}

#pragma mark - Life cycle

@end
