//
//  YDRequestTask.h
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/23.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDFileHandle.h"
#import "NSURL+YDLoader.h"
#import "NSString+YDLoader.h"

#define RequestTimeout 10.0

@protocol YDRequestTaskDelegate <NSObject>
@required
- (void)requestTaskDidUpdateCache;//更新缓冲进度代理
@optional
- (void)requestTaskDidReceiveResponse;
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache;
- (void)requestTaskDidFailWithError:(NSError *)error;

@end
//test  test 111
@interface YDRequestTask : NSObject<NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (nonatomic, weak) id<YDRequestTaskDelegate>delegate;
@property (nonatomic, strong) NSURL *requestURL;//请求地址
@property (nonatomic, assign) NSUInteger requestOffset; //请求起始位置
@property (nonatomic, assign) NSUInteger fileLength; //文件长度
@property (nonatomic, assign) NSUInteger cacheLength; //缓冲长度
@property (nonatomic, assign) BOOL cache; //是否缓存文件
@property (nonatomic, assign) BOOL cancel; //是否取消请求

/*开始请求*/
- (void)start;

@end
