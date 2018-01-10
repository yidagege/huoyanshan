//
//  YDPlayer.h
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YDResourceLoader.h"

typedef NS_ENUM(NSInteger, YDPlayerState) {
    YDPlayerStateWaiting,
    YDPlayerStatePlaying,
    YDPlayerStatePaused,
    YDPlayerStateStopped,
    YDPlayerStateBuffering,
    YDPlayerStateError,
};

@interface YDPlayer : NSObject<YDLoaderDelegate>

@property (nonatomic, assign) YDPlayerState state;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat cacheProgress;

/**
 *  初始化方法，url：歌曲的网络地址或者本地地址
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 *  播放下一首歌曲，url：歌曲的网络地址或者本地地址
 *  逻辑：stop -> replace -> play
 */
- (void)replaceItemWithURL:(NSURL *)url;

- (void)play;

- (void)pause;

-(void)stop;
/**
 *  正在播放
 */
- (BOOL)isPlaying;
//seek
- (void)seekToTime:(CGFloat)seconds;
/**
 *  当前歌曲缓存情况 YES：已缓存  NO：未缓存（seek过的歌曲都不会缓存）
 */
- (BOOL)currentItemCacheState;
/**
 *  当前歌曲缓存文件完整路径
 */
- (NSString *)currentItemCacheFilePath;
/**
 *  清除缓存
 */
+ (BOOL)clearCache;

@end
