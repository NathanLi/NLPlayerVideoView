//
//  NLPlayerViewDemo.h
//  NLPlayerDemo
//
//  Created by NathanLi on 15/10/18.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@interface NLPlayerViewDemo : UIView

@property (nonatomic, retain) AVPlayer* player;

- (void) setPlayer:(AVPlayer*)player;

/*! Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default)
 @param NSString fillMode
 */
- (void) setVideoFillMode:(NSString *)fillMode;

@end
