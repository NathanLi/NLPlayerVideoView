//
//  NLPlayerViewDemo.m
//  NLPlayerDemo
//
//  Created by NathanLi on 15/10/18.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import "NLPlayerViewDemo.h"



@implementation NLPlayerViewDemo

+ (Class)layerClass
{
  return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
  return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
  [(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
  AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
  playerLayer.videoGravity = fillMode;
}


@end
