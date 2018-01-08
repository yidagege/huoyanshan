//
//  VideoMergePlayView.m
//  SalesSecretary
//
//  Created by 张毅 on 2018/1/7.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "VideoMergePlayView.h"

@implementation VideoMergePlayView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (AVPlayer *)player {
    return [[self playerLayer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [[self playerLayer] setVideoGravity:AVLayerVideoGravityResizeAspect];
    [[self playerLayer] setPlayer:player];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)[self layer];
}



@end
