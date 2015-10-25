//
//  ViewController.m
//  NLPlayerDemo
//
//  Created by nathan@hoomic.com on 15/10/16.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import "ViewController.h"
#import "NLPlayerVideoView.h"
#import "NLPlayerViewDemo.h"

static NSString *const kVideoMP4Url = @"http://qiubai-video.qiushibaike.com/T8EC50NJ7MJJGHA2.mp4";

@interface ViewController ()

@property (nonatomic, strong) NLPlayerVideoView *videoView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  NSURL *url = [NSURL URLWithString:kVideoMP4Url];
  self.videoView = [[NLPlayerVideoView alloc] initWithUrl:url];
  self.videoView.backgroundColor = [UIColor yellowColor];
  [self.videoView setPlayCompletionHandler:^(BOOL finished) {
    [self.videoView play];
  }];
  [self.view addSubview:self.videoView];
  
  self.videoView.frame = self.view.bounds;
//  [self.videoView play];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.videoView setURL:[NSURL URLWithString:@"http://qiubai-video.qiushibaike.com/R3TKL61VDI6HHP7D.mp4"]];
    [self.videoView play];
  });
  
//  NLPlayerViewDemo *demo = [[NLPlayerViewDemo alloc] init];
//  NSURL *url = [NSURL URLWithString:kVideoMP4Url];
//  AVURLAsset *asset = [AVURLAsset assetWithURL:url];
//  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
//  AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
//  demo.frame = self.view.bounds;
//  [demo setPlayer:player];
//  [self.view addSubview:demo];
//  [player play];

}


@end
