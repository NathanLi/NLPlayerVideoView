//
//  NLPlayerFileCache.m
//  NLPlayerDemo
//
//  Created by NathanLi on 15/10/18.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import "NLPlayerFileCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "DFCache.h"
#import "NLAssetResourceLoaderDelegate.h"
#import "DFDiskCache+nl_pathExtension.h"

@interface NLPlayerFileCache ()

@property (nonatomic, strong) DFDiskCache *dfCache;

@end

@implementation NLPlayerFileCache

+ (instancetype)shareFileCache {
  static NLPlayerFileCache *sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
    [sharedInstance regisiterNotification];
  });
  return sharedInstance;
}

- (instancetype)init {
  if (self = [super init]) {
    _dfCache = [[DFDiskCache alloc] initWithName:@"NLVideoCache"];
    _dfCache.nl_filenameContainPathExtension = YES;
  }
  return self;
}

- (void)storeData:(NSData *)data forURLString:(NSString *)url {
  [self.dfCache setData:data forKey:[self cachedFileNameForKey:url]];
}

- (NSData *)loadDataForURL:(NSString *)url {
  return [self.dfCache dataForKey:[self cachedFileNameForKey:url]];
}

- (NSURL *)fileURLForOriginURLString:(NSString *)url {
  NSURL *diskUrl = [self.dfCache URLForKey:[self cachedFileNameForKey:url]];
  return diskUrl;
}

- (BOOL)containsDataForURL:(NSString *)url {
  return [self.dfCache containsDataForKey:[self cachedFileNameForKey:url]];
}

- (void)removeAllData {
  [self.dfCache removeAllData];
}

#pragma mark Notification
- (void)regisiterNotification {
  [[NSNotificationCenter defaultCenter] addObserverForName:NLNotificationAssetRsourceLoadCompletion object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
    NSDictionary *userInfo = [note userInfo];
    NSData *data = [userInfo objectForKey:@"data"];
    NSString *url = [userInfo objectForKey:@"url"];
    if (data && url) {
      [self storeData:data forURLString:url];
    }
  }];
}

#pragma mark (private)

- (NSString *)cachedFileNameForKey:(NSString *)key {
  const char *str = [key UTF8String];
  if (str == NULL) {
    str = "";
  }
  unsigned char r[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, (CC_LONG)strlen(str), r);
  NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
  NSString *extenion = [key pathExtension];
  if ([extenion length] > 0) {
    filename = [filename stringByAppendingPathExtension:extenion];
  }
  
  return filename;
}



@end
