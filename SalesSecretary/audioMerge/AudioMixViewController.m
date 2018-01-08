//
//  AudioMixViewController.m
//  SalesSecretary
//
//  Created by 张毅 on 2018/1/7.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "AudioMixViewController.h"
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>
#define kFileManager [NSFileManager defaultManager]

@interface AudioMixViewController ()
@property(nonatomic,copy)NSString *filePath;
@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation AudioMixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
/*
 <li>AVURLAsset
 
 AVURLAsset是AVAsset的子类，是一个具体类，用URL来进行初始化。
 
 <li>AVMutableComposition
 
 AVMutableComposition结合了媒体数据，可以看成是track(音频轨道)的集合，用来合成音视频。
 
 <li>AVMutableCompositionTrack
 
 AVMutableCompositionTrack用来表示一个track，包含了媒体类型、音轨标识符等信息，可以插入、删除、缩放track片段。
 
 <li>AVAssetTrack
 
 AVAssetTrack表示素材轨道。
 
 <li>AVAssetExportSession
 
 AVAssetExportSession用来对一个AVAsset源对象进行转码，并导出为事先设置好的格式。
*/
    
    self.title = @"音频混合与拼接";
    
    NSString *audioPath1 = [[NSBundle mainBundle]pathForResource:@"五环之歌" ofType:@"mp3"];
    NSString *audioPath2 = [[NSBundle mainBundle]pathForResource:@"陈奕迅" ofType:@"mp3"];
    NSString *audioPath3 = [[NSBundle mainBundle]pathForResource:@"我的滑板鞋" ofType:@"mp3"];

    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath1]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath2]];
    AVURLAsset *audioAsset3 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath3]];
    
    //2、接下来就是创建两个音频轨道，并获取工程中两个音频素材的轨道：
    AVMutableComposition *composition = [AVMutableComposition composition];
    //音频通道
    AVMutableCompositionTrack *audiotrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audiotrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audiotrack3 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];

    // 音频采集通道
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio]firstObject];
    AVAssetTrack *audioAssetTrack3 = [[audioAsset3 tracksWithMediaType:AVMediaTypeAudio]firstObject];

    //3、将两段音频插入音轨文件进行合并：
    [audiotrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:kCMTimeZero error:nil];

    [audiotrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration) ofTrack:audioAssetTrack2 atTime:audioAsset1.duration error:nil];
    [audiotrack3 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset3.duration) ofTrack:audioAssetTrack3 atTime:kCMTimeZero error:nil];
//这个插入音轨文件的顺序决定了拼接还是混合以及播放顺序。
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"kyida.m4a"];

    if ([[NSFileManager defaultManager]fileExistsAtPath:outPutFilePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:outPutFilePath error:nil];
    }
    
    //查看当前session支持的filetype类型
    NSLog(@"----%@",[session supportedFileTypes]);
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = AVFileTypeAppleM4A;
    session.shouldOptimizeForNetworkUse = YES;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"合并成功----%@",outPutFilePath);
            _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:outPutFilePath] error:nil];
            [_player play];
        }
    }];
    
    
}


- (NSString *)filePath {
    if (!_filePath) {
        _filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *folderName = [_filePath stringByAppendingPathComponent:@"MergeAudio"];
        BOOL isCreateSuccess = [kFileManager createDirectoryAtPath:folderName withIntermediateDirectories:YES attributes:nil error:nil];
        if (isCreateSuccess) _filePath = [folderName stringByAppendingPathComponent:@"kyida.m4a"];
    }
    return _filePath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
