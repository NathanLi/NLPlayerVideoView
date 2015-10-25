//
//  NLPlayerFileCache.h
//  NLPlayerDemo
//
//  Created by NathanLi on 15/10/18.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLPlayerFileCache : NSObject

+ (instancetype)shareFileCache;

- (void)storeData:(NSData *)data forURL:(NSString *)url;
- (NSData *)loadDataForURL:(NSString *)url;

- (NSURL *)pathForURL:(NSString *)url;

- (BOOL)containsDataForURL:(NSString *)url;

- (void)removeAllData;

@end
