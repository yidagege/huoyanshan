//
//  YDRequestTask.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/23.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "YDRequestTask.h"

@interface YDRequestTask ()
@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSURLSessionDataTask *task;

@end

@implementation YDRequestTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        [YDFileHandle createTempFile];
    }
    return self;
}

- (void)start{
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
//    if (self.requestOffset > 0) {
//        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",self.requestOffset,self.fileLength -1] forHTTPHeaderField:@"Range"];
//    }
//    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    self.task = [self.session dataTaskWithRequest:request];
//    [self.task resume];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    if (self.requestOffset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", self.requestOffset, self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)setCancel:(BOOL)cancel{
    _cancel = cancel;
    [self.task cancel];
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDataDelegate
//服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    if (self.cancel) {
        return;
    }
    NSLog(@"response: %@",response);
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)response;
    NSString *contentrange = [[httpresponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *filelength = [[contentrange componentsSeparatedByString:@"/"] lastObject];
    self.fileLength = filelength.integerValue > 0 ? filelength.integerValue : response.expectedContentLength;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
    
}
//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    if (self.cancel) {
        return;
    }
    [YDFileHandle writeTempFileData:data];
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache)]) {
        [self.delegate requestTaskDidUpdateCache];
    }
}
//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (self.cancel) {
        NSLog(@"下载取消");
    }else{
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }else{
            //可以缓存则保存文件，请求完成
            if (self.cache) {
                [YDFileHandle cacheTempFileWithFileName:[NSString fileNameWithURL:self.requestURL]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFinishLoadingWithCache:)]) {
                [self.delegate requestTaskDidFinishLoadingWithCache:self.cache];
            }
        }
    }
}


@end
