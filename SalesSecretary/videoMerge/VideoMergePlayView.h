//
//  VideoMergePlayView.h
//  SalesSecretary
//
//  Created by 张毅 on 2018/1/7.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoMergePlayView : UIView
@property (nonatomic, weak) AVPlayer *player;

- (AVPlayerLayer *)playerLayer;

@end
