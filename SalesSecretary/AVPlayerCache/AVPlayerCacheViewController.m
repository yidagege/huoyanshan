//
//  AVPlayerCacheViewController.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/8.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "AVPlayerCacheViewController.h"
#import "Masonry.h"
#import "YDPlayer.h"

@interface AVPlayerCacheViewController ()

@property (nonatomic, strong) YDPlayer * player;
@property (strong, nonatomic) UISlider *progressSlider;
@property (strong, nonatomic) UIImageView *coverIv;
@property (strong, nonatomic) UILabel *songName;
@property (strong, nonatomic) UILabel *currentTime;
@property (strong, nonatomic) UILabel *duration;
@property (strong, nonatomic) UIImageView *bgIv;
@property (nonatomic, assign) NSInteger songIndex;

@property (strong, nonatomic) UIButton *pauseplay;
@property (strong, nonatomic) UIButton *skip;

@end

@implementation AVPlayerCacheViewController

- (void)dealloc{
    [self.player removeObserver:self forKeyPath:@"progress"];
    [self.player removeObserver:self forKeyPath:@"duration"];
    [self.player removeObserver:self forKeyPath:@"cacheProgress"];


}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"AVPlayer的缓存实现";

    [self addSubviews];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.alpha = 0.9;
    effe.frame = self.view.bounds;
    [self.view insertSubview:effe aboveSubview:self.bgIv];
    
    NSURL *url = [NSURL URLWithString:[self songURLList][self.songIndex]];
    self.player = [[YDPlayer alloc]initWithURL:url];
    [self.player addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"cacheProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.player play];
    [self updateSongInfoShow];
    [self.progressSlider addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)changeProgress:(UISlider *)slider {
    float seekTime = self.player.duration * slider.value;
    [self.player seekToTime:seekTime];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"progress"]) {
        if (self.progressSlider.state != UIControlStateHighlighted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressSlider.value = self.player.progress;
                self.currentTime.text = [self convertStringWithTime:self.player.duration * self.player.progress];
            });
        }
    }else if ([keyPath isEqualToString:@"duration"]){
        if (self.player.duration > 0) {
            self.duration.text = [self convertStringWithTime:self.player.duration];
            self.duration.hidden = NO;
            self.currentTime.hidden = NO;
        }else{
            self.duration.hidden = YES;
            self.currentTime.hidden = YES;
        }
    }else if ([keyPath isEqualToString:@"cacheProgress"]) {
    //        NSLog(@"缓存进度：%f", self.player.cacheProgress);
    }
}

- (NSString *)convertStringWithTime:(float)time {
    if ((isnan(time))) {
        time = 0.f;
    }
    
    int min = time / 60.0;
    int sec = time - min * 60;
//    NSString *minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d,min"];
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];

    NSString *secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@",minStr,secStr];
    return timeStr;
}

- (void)addSubviews{
    
    self.bgIv = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.bgIv];
    
    self.coverIv = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 80, 200, 200)];
    [self.view addSubview:self.coverIv];
    self.songName = [[UILabel alloc]initWithFrame:CGRectMake(0, 320, self.view.frame.size.width, 40)];
    self.songName.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.songName];
    
    self.currentTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 380, 50, 20)];
    self.currentTime.textColor = [UIColor redColor];
    [self.view addSubview:self.currentTime];
    self.duration = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 45, 380, 50, 20)];
    self.duration.textColor = [UIColor redColor];
    [self.view addSubview:self.duration];
    
    self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(60, 380, self.view.frame.size.width - 120, 30)];
    [self.view addSubview:self.progressSlider];
    
    self.pauseplay  = [[UIButton alloc]initWithFrame:CGRectMake(30, 430, 50, 30)];
    [self.pauseplay setTitle:@"暂停" forState:UIControlStateNormal];
    [self.pauseplay setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:self.pauseplay];
    [self.pauseplay addTarget:self action:@selector(pauseplay:) forControlEvents:UIControlEventTouchUpInside];
    
    self.skip  = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 430, 50, 30)];
    [self.skip setTitle:@"切集" forState:UIControlStateNormal];
    [self.skip setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:self.skip];
    [self.skip addTarget:self action:@selector(skipSong:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pauseplay:(UIButton*)sender{
    if (sender.selected) {
        [self.player pause];
    }else{
        [self.player play];
    }
    sender.selected = !sender.selected;
}

- (void)skipSong:(UIButton*)sender{
    self.songIndex ++;
    if (self.songIndex >= [self songNameList].count) {
        self.songIndex = 0;
    }
    [self.player stop];
    NSURL *url = [NSURL URLWithString:[self songURLList][self.songIndex]];
    [self.player replaceItemWithURL:url];
    [self.player play];
    [self updateSongInfoShow];
}

- (void)updateSongInfoShow{
    self.songName.text = [self songNameList][self.songIndex];
    [UIView transitionWithView:self.bgIv duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.bgIv.image = [UIImage imageNamed:[self songCoverList][self.songIndex]];
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView transitionWithView:self.coverIv duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.coverIv.image = [UIImage imageNamed:[self songCoverList][self.songIndex]];

    } completion:nil];
    
}

- (NSArray *)songNameList {
    return @[@"夏天的味道", @"没那种命", @"不得不爱", @"海阔天空"];
}

- (NSArray *)songURLList {
    return @[@"http://download.lingyongqian.cn/music/AdagioSostenuto.mp3",
             @"http://download.lingyongqian.cn/music/ForElise.mp3",
             @"http://mr7.doubanio.com/39ec9c9b5bbac0af7b373d1c62c294a3/1/fm/song/p1393354_128k.mp4",
             @"http://mr7.doubanio.com/16c59061a6a82bbb92bdd21e626db152/0/fm/song/p966452_128k.mp4"];
}

- (NSArray *)songCoverList {
    return @[@"p190415_128k.jpg", @"p1458183_128k.jpg", @"p1393354_128k.jpg", @"p966452_128k.jpg"];
}

@end
