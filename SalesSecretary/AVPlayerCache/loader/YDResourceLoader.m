//
//  YDResourceLoader.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "YDResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface YDResourceLoader()
@property (nonatomic, strong)NSMutableArray *requestList;
@property (nonatomic, strong)YDRequestTask *requestTask;

@end

@implementation YDResourceLoader

- (instancetype)init{
    if (self = [super init]) {
        self.requestList = [NSMutableArray array];
    }
    return self;
}

- (void)stopLoading{
    self.requestTask.cancel = YES;
}

#pragma mark -- AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self removeLoadingRequest:loadingRequest];
}

#pragma mark -YDRequestTaskDelegate
- (void)requestTaskDidUpdateCache{
    [self processRequestList];
    if (_delegate && [_delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheprogress = (CGFloat)self.requestTask.cacheLength / (self.requestTask.fileLength - self.requestTask.requestOffset);
        [_delegate loader:self cacheProgress:cacheprogress];
    }
}

- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache{
    self.cacheFinished = cache;
}

- (void)requestTaskDidFailWithError:(NSError *)error{
    
}

#pragma mark --处理loadingrequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.requestList addObject:loadingRequest];
    @synchronized(self) {
        if (self.requestTask) {
            if (loadingRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset && loadingRequest.dataRequest.requestedOffset <= self.requestTask.requestOffset + self.requestTask.cacheLength) {
                //数据已经缓存，则直接完成
                NSLog(@"数据已经缓存，则直接完成");
                [self processRequestList];
            }else{
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
                if (self.seekRequired) {
                    NSLog(@"seek操作，重新请求");
                    [self newTaskWithLoadingRequest:loadingRequest cache:NO];
                }
            }
        }else{
            [self newTaskWithLoadingRequest:loadingRequest cache:YES];
        }
    }
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cache:(BOOL)cache {
    NSUInteger filelength = 0;
    if (self.requestTask) {
        filelength = self.requestTask.fileLength;
        self.requestTask.cancel = YES;
    }
    self.requestTask = [[YDRequestTask alloc] init];
    self.requestTask.requestURL = loadingRequest.request.URL;
    self.requestTask.requestOffset = loadingRequest.dataRequest.requestedOffset;
    self.requestTask.cache = cache;
    if (filelength > 0) {
        self.requestTask.fileLength = filelength;
    }
    self.requestTask.delegate = self;
    [self.requestTask start];
    self.seekRequired = NO;
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.requestList removeObject:loadingRequest];
}

- (void)processRequestList{
    NSMutableArray *finishRequestList = [[NSMutableArray alloc]init];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.requestList) {
        if ([self finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (BOOL)finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(MimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    //读文件，填充数据
    NSUInteger cachelength = self.requestTask.cacheLength;
    NSUInteger requestdOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestdOffset = loadingRequest.dataRequest.currentOffset;
    }
    NSUInteger canReadLength = cachelength - (requestdOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    [loadingRequest.dataRequest respondWithData:[YDFileHandle readTempFileDataWithOffset:requestdOffset - self.requestTask.requestOffset length:respondLength]];
    //如果完全响应了所需要的数据，则完成
    NSUInteger nowendoffset = requestdOffset + canReadLength;
    NSUInteger reqendoffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
    if (nowendoffset >= reqendoffset) {
        return YES;
    }
    return NO;
}


@end
