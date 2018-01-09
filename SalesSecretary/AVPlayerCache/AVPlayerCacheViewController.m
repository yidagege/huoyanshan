//
//  AVPlayerCacheViewController.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/8.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "AVPlayerCacheViewController.h"
#import "Masonry.h"

@interface AVPlayerCacheViewController ()

//@property (nonatomic, strong) SUPlayer * player;
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
    
    
}

- (void)addSubviews{
    
    self.bgIv = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.bgIv];
    
    self.coverIv = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 100, 200, 200)];
    [self.view addSubview:self.coverIv];
    self.songName = [[UILabel alloc]initWithFrame:CGRectMake(0, 340, self.view.frame.size.width, 40)];
    [self.view addSubview:self.songName];
    
    self.currentTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 400, 45, 20)];
    [self.view addSubview:self.currentTime];
    self.duration = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 45, 400, 45, 20)];
    [self.view addSubview:self.duration];
    
    self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(60, 400, self.view.frame.size.width - 120, 30)];
    [self.view addSubview:self.progressSlider];
    
    self.pauseplay  = [[UIButton alloc]initWithFrame:CGRectMake(30, 480, 50, 30)];
    [self.pauseplay setTitle:@"暂停" forState:UIControlStateNormal];
    [self.pauseplay setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:self.pauseplay];
    
    self.skip  = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 480, 50, 30)];
    [self.skip setTitle:@"切集" forState:UIControlStateNormal];
    [self.skip setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:self.skip];
    
}




@end
