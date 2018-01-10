//
//  YDResourceLoader.h
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define MimeType @"video/mp4"
// http://www.cnblogs.com/machao/p/5667867.html  blog说明
@class YDResourceLoader;
@protocol YDLoaderDelegate <NSObject>
@required
- (void)loader:(YDResourceLoader *)loader cacheProgress:(CGFloat)progress;
@optional
- (void)loader:(YDResourceLoader *)loader failLoadingWithError:(NSError *)error;

@end

@interface YDResourceLoader : NSObject<AVAssetResourceLoaderDelegate>
@property (nonatomic, weak) id<YDLoaderDelegate> delegate;
@property (atomic, assign) BOOL seekRequired;//seek标志
@property (nonatomic, assign)BOOL cacheFinished;

- (void)stopLoading;

@end
