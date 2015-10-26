//
//  NLAssetResourceLoader.m
//  NLPlayerDemo
//
//  Created by nathan@hoomic.com on 15/10/16.
//  Copyright © 2015年 Hoomic. All rights reserved.
//


#import "NLAssetResourceLoaderDelegate.h"

@import MobileCoreServices;

NSString *const NLNotificationAssetRsourceLoadCompletion = @"NLNotificationAssetRsourceLoadCompletion";

NSString *const NLCustomScheme = @"nlscheme";
NSString *const HTTPScheme = @"http";

@interface NLAssetResourceLoaderDelegate ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, strong) NSMutableArray *pendingRequests;

@property (nonatomic, strong) NSMutableData *onlineMovieData;

- (NSData *)movieData;

@end

@implementation NLAssetResourceLoaderDelegate

#pragma mark - schemes
+ (NSURL *)customSchemeWithUrl:(NSURL *)url {
  return [self changeSchemeWithUrl:url scheme:NLCustomScheme];
}

+ (NSURL *)httpSchemeWithUrl:(NSURL *)url {
  return [self changeSchemeWithUrl:url scheme:HTTPScheme];
}

+ (NSURL *)changeSchemeWithUrl:(NSURL *)url scheme:(NSString *)scheme {
  NSParameterAssert([scheme length] > 0);
  
  NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
  components.scheme = scheme;
  
  return [components URL];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  self.onlineMovieData = [NSMutableData data];
  self.response = (NSHTTPURLResponse *)response;
  [self processPendingRequests];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.onlineMovieData appendData:data];
  [self processPendingRequests];
  
  if (self.downloadProgressBlock) {
    long long totalBytesExpectedToRead = [self.response expectedContentLength];
    long long totalBytesRead = [self.onlineMovieData length];
    NSUInteger bytesRead = [data length];
    float progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
    self.downloadProgressBlock(progress, bytesRead, totalBytesRead, totalBytesExpectedToRead);
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self processPendingRequests];
  
  NSDictionary *userInfo = @{@"data": self.onlineMovieData,
                             @"url": [self.response.URL absoluteString]};
  [[NSNotificationCenter defaultCenter] postNotificationName:NLNotificationAssetRsourceLoadCompletion object:self userInfo:userInfo];
  
  if (self.completionBlock) {
    self.completionBlock(nil);
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[self.pendingRequests firstObject] finishLoadingWithError:error];
  
  if (self.completionBlock) {
    self.completionBlock(error);
  }
}

#pragma mark - loading data
- (void)loadResource:(AVAssetResourceLoader *)resourceLoader loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  [self.pendingRequests addObject:loadingRequest];
  
  NSURL *url = [self.class httpSchemeWithUrl:[loadingRequest.request URL]];
  [self loadMoiveDataByConnectionWithURL:url];
  
  [self processPendingRequests];
}

- (void)loadMoiveDataByConnectionWithURL:(NSURL *)url {
  if (self.connection == nil) {
#ifdef DEBUG
    NSLog(@"读取网络视频数据：%@", url);
#endif
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
  }
}

#pragma mark process request
- (void)processPendingRequests {
  NSMutableArray *requestsCompleted = [NSMutableArray array];
  
  for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests){
    [self fillInContentInformation:loadingRequest.contentInformationRequest response:self.response];
    
    BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
    
    if (didRespondCompletely){
      [requestsCompleted addObject:loadingRequest];
      
      [loadingRequest finishLoading];
    }
  }
  
  [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest response:(NSURLResponse *)response {
  if (contentInformationRequest == nil || response == nil){
    return;
  }
  
  NSString *mimeType = [response MIMEType];
  CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
  
  contentInformationRequest.byteRangeAccessSupported = YES;
  contentInformationRequest.contentType = CFBridgingRelease(contentType);
  contentInformationRequest.contentLength = [response expectedContentLength];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
  long long startOffset = dataRequest.requestedOffset;
  if (dataRequest.currentOffset != 0){
    startOffset = dataRequest.currentOffset;
  }
  
  // Don't have any data at all for this request
  NSData *moiveData = [self movieData];
  if (moiveData.length < startOffset){
    return NO;
  }
  
  // This is the total data we have from startOffset to whatever has been downloaded so far
  NSUInteger unreadBytes = moiveData.length - (NSUInteger)startOffset;
  // Respond with whatever is available if we can't satisfy the request fully yet
  NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
  
  NSData *data = [moiveData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)];
  [dataRequest respondWithData:data];
  
  long long endOffset = startOffset + dataRequest.requestedLength;
  BOOL didRespondFully = moiveData.length >= endOffset;
  
  return didRespondFully;
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
#ifdef DEBUG
  NSLog(@"开始读取视频数据：%@", loadingRequest.request.URL);
#endif
  
  NSURL *url = [loadingRequest.request URL];
  BOOL shouldWait = [url.scheme isEqualToString:NLCustomScheme];
  
  if (shouldWait) {
    [self loadResource:resourceLoader loadingRequest:loadingRequest];
  }
  
  return shouldWait;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
  [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - Life cycle
- (instancetype)init {
  if (self = [super init]) {
    _pendingRequests = [NSMutableArray array];
    _onlineMovieData = [NSMutableData data];
  }
  return self;
}

- (void)dealloc {
  
}

#pragma mark extension
- (NSData *)movieData {
  return self.onlineMovieData;
}

@end
