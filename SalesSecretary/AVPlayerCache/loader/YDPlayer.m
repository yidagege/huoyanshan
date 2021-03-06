//
//  YDPlayer.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "YDPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "YDFileHandle.h"
#import "YDLoaderCategory.h"
@interface YDPlayer ()

@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * currentItem;
@property (nonatomic, strong) YDResourceLoader * resourceLoader;

@property (nonatomic, strong) id timeObserve;

@end

@implementation YDPlayer

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player removeObserver:self forKeyPath:@"rate"];
}

- (instancetype)initWithURL:(NSURL *)url{
    if (self == [super init]) {
        self.url = url;
        [self reloadCurrentItem];
    }
    return self;
}

- (void)reloadCurrentItem {
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        //是否有播放缓存文件
        NSString *cacheFilePath = [YDFileHandle cacheFilePathExistWithURL:self.url];
        if (cacheFilePath) {
            NSURL *url = [NSURL fileURLWithPath:cacheFilePath];
            self.currentItem = [AVPlayerItem playerItemWithURL:url];
            NSLog(@"有缓存，播放缓存文件");
        }else{
            //没有
            self.resourceLoader = [[YDResourceLoader alloc]init];
            self.resourceLoader.delegate = self;
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self.url customSchemeURL] options:nil];//AVAssetResourceLoader通过你提供的委托对象去调节AVURLAsset所需要的加载资源。而很重要的一点是，AVAssetResourceLoader仅在AVURLAsset不知道如何去加载这个URL资源时才会被调用，就是说你提供的委托对象在AVURLAsset不知道如何加载资源时才会得到调用。所以我们又要通过一些方法来曲线解决这个问题，把我们目标视频URL地址的scheme替换为系统不能识别的scheme，然后在我们调用网络请求去处理这个URL时把scheme切换为原来的scheme。
/*
 但由于AVPlayer是没有提供方法给我们直接获取它下载下来的数据，所以我们只能在视频下载完之后自己去寻找缓存视频数据的办法，AVFoundation框架中有一种从多媒体信息类AVAsset中提取视频数据的类AVMutableComposition和AVAssetExportSession。
 其中AVMutableComposition的作用是能够从现有的asset实例中创建出一个新的AVComposition(它也是AVAsset的字类)，使用者能够从别的asset中提取他们的音频轨道或视频轨道，并且把它们添加到新建的Composition中。
 AVAssetExportSession的作用是把现有的自己创建的asset输出到本地文件中。
 为什么需要把原先的AVAsset(AVURLAsset)实现的数据提取出来后拼接成另一个AVAsset(AVComposition)的数据后输出呢，由于通过网络url下载下来的视频没有保存视频的原始数据（或者苹果没有暴露接口给我们获取），下载后播放的avasset不能使用AVAssetExportSession输出到本地文件，要曲线地把下载下来的视频通过重构成另外一个AVAsset实例才能输出。
*/
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
            self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
            NSLog(@"无缓存，播放网络文件");

        }
    }else{
        self.currentItem = [AVPlayerItem playerItemWithURL:self.url];
        NSLog(@"播放本地文件，有缓存文件");
    }
    //player
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    //observer
    [self addObserver];
    _state = YDPlayerStateWaiting;
}

- (void)replaceItemWithURL:(NSURL *)url{
    self.url = url;
    [self reloadCurrentItem];
}

- (void)play{
    if (self.state == YDPlayerStateWaiting || self.state == YDPlayerStatePaused) {
        [self.player play];
    }
}

- (void)pause{
    if (self.state == YDPlayerStatePlaying) {
        [self.player pause];
    }
}
- (BOOL)isPlaying{
    if (self.state == YDPlayerStatePlaying) {
        return YES;
    }
    return NO;
}

- (void)stop{
    if (self.state == YDPlayerStateStopped) {
        return;
    }
    [self.player pause];
    [self.resourceLoader stopLoading];
    [self removeObserver];
    self.resourceLoader = nil;
    self.currentItem = nil;
    self.player= nil;
    self.progress = 0.0;
    self.duration = 0.0;
    self.state = YDPlayerStateStopped;
}

- (void)seekToTime:(CGFloat)seconds{
    if (self.state==YDPlayerStatePlaying || self.state == YDPlayerStatePaused) {
        // 暂停后滑动slider后    暂停播放状态
        // 播放中后滑动slider后   自动播放状态
        self.resourceLoader.seekRequired = YES;
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            if ([self isPlaying]) {
                [self.player play];
            }
        }];
    }
}


#pragma mark - NSNotification 监听播放器打断处理
- (void)audioSessionInterrupted:(NSNotification *)notification{
    //通知类型
    NSDictionary * info = notification.userInfo;
    // AVAudioSessionInterruptionTypeBegan ==
    if ([[info objectForKey:AVAudioSessionInterruptionTypeKey] integerValue] == 1) {
        [self.player pause];
    }else{
        [self.player play];
    }
}

#pragma mark - KVO
- (void)addObserver {
    AVPlayerItem *songItem = self.currentItem;
    //监听播放完成
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
    //播放进度
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current = CMTimeGetSeconds(time);
        CGFloat total = CMTimeGetSeconds(songItem.duration);
        weakSelf.duration = total;
        weakSelf.progress = current / total;
    }];
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver{
    AVPlayerItem *songItem = self.currentItem;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    
    [songItem removeObserver:self forKeyPath:@"status"];
    [songItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [songItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [songItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

/**
 *  通过KVO监控播放器状态
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *songItem = object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        NSLog(@"共缓冲%.2f",totalBuffer);
    }
    if ([keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0.0) {
            _state = YDPlayerStatePaused;
        }else{
            _state = YDPlayerStatePlaying;
        }
    }
}

- (void)playbackFinished {
    NSLog(@"播放完成");
    [self stop];
}

#pragma mark - YDLoaderDelegate
- (void)loader:(YDResourceLoader *)loader cacheProgress:(CGFloat)progress {
    self.cacheProgress = progress;
}

#pragma mark - Property Set
- (void)setProgress:(CGFloat)progress{
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (void)setState:(YDPlayerState)state{
    [self willChangeValueForKey:@"progress"];
    _state = state;
    [self didChangeValueForKey:@"progress"];
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    [self willChangeValueForKey:@"progress"];
    _cacheProgress = cacheProgress;
    [self didChangeValueForKey:@"progress"];
}

- (void)setDuration:(CGFloat)duration{
    if (duration != _duration && !isnan(duration)) {
        [self willChangeValueForKey:@"duration"];
        NSLog(@"duration %f",duration);
        _duration = duration;
        [self didChangeValueForKey:@"duration"];
    }
}


- (BOOL)currentItemCacheState{
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        if (self.resourceLoader) {
            return self.resourceLoader.cacheFinished;
        }
        return YES;
    }
    return NO;
}

- (NSString *)currentItemCacheFilePath{
    if ([self currentItemCacheState]==NO) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:self.url]];;
}
+ (BOOL)clearCache {
    [YDFileHandle clearCache];
    return YES;
}

@end
