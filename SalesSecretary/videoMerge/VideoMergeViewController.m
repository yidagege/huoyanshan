//
//  VideoMergeViewController.m
//  SalesSecretary
//
//  Created by 张毅 on 2018/1/7.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "VideoMergeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoMergePlayView.h"

@interface VideoMergeViewController ()
@property (nonatomic, strong) UIButton  *buttonMerge;
@property (nonatomic, strong) UIButton  *buttonClip;
@property (nonatomic, strong) AVPlayer  *mergePlayer;
@property (nonatomic, strong) AVPlayer  *clipPlayer;
@property (nonatomic, strong) VideoMergePlayView  *mergeVideoView;
@property (nonatomic, strong) VideoMergePlayView  *clipVideoView;

@end

@implementation VideoMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadUI];
    
    self.clipPlayer = [AVPlayer new];
    self.clipVideoView.player = _clipPlayer;
    
    self.mergePlayer = [AVPlayer new];
    self.mergeVideoView.player = _mergePlayer;

}

- (void)loadUI{
    _buttonMerge = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, 50, 30)];
    [_buttonMerge setTitle:@"合并" forState:UIControlStateNormal];
    [_buttonMerge setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:_buttonMerge];
    [_buttonMerge addTarget:self action:@selector(merge) forControlEvents:UIControlEventTouchUpInside];
    
    _buttonClip = [[UIButton alloc]initWithFrame:CGRectMake(10, 300, 50, 30)];
    [_buttonClip setTitle:@"裁剪" forState:UIControlStateNormal];
    [_buttonClip setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:_buttonClip];
    [_buttonClip addTarget:self action:@selector(clip) forControlEvents:UIControlEventTouchUpInside];

    
    _mergeVideoView = [[VideoMergePlayView alloc]initWithFrame:CGRectMake(100, 100, 180, 130)];
    [self.view addSubview:_mergeVideoView];

    _clipVideoView = [[VideoMergePlayView alloc]initWithFrame:CGRectMake(100, 300, 180, 130)];
    [self.view addSubview:_clipVideoView];
}

- (void)merge{
    [_buttonMerge setEnabled:NO];
    
    [_mergePlayer pause];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[self mergeUrl] path]]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:[self mergeUrl] error:&error];
    }
    
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"录屏1" ofType:@"mov"];
    NSString *bPath = [[NSBundle mainBundle] pathForResource:@"录屏2" ofType:@"mov"];
    
    NSArray *videoPaths = @[aPath,bPath];
    AVMutableComposition *mainComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *soundtrackTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime duration = kCMTimeZero;
    for (NSString *videop in videoPaths) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videop]];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[asset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:duration error:nil];//视频轨
        
        [soundtrackTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:duration error:nil];//音轨
        
        duration = CMTimeAdd(duration, asset.duration);
    }
    
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mainComposition presetName:AVAssetExportPreset1280x720];
    exporter.outputURL = [self mergeUrl];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    __weak typeof(self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusWaiting:
                break;
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporting completed");
                // 想做什么事情在这个做
                [weakSelf _mergeFinished];
                break;
            default:
                [weakSelf _mergeFinished];
                NSLog(@"exporting failed %@",[exporter error]);
                break;
        }

    }];

}

- (void)clip{
    [_buttonClip setEnabled:NO];
    
    [_clipPlayer pause];
    if ([[NSFileManager defaultManager]fileExistsAtPath:[[self clipUrl] path]]) {
        [[NSFileManager defaultManager]removeItemAtURL:[self clipUrl] error:nil];
    }
    
    NSString *clippath = [[self mergeUrl]path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:clippath]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your clip file is not found. please click merge. then click clip." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [_buttonClip setEnabled:YES];
        return;
    }
    AVMutableComposition *mainComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videotrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audiotrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime duration = kCMTimeZero;
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:clippath]];
    float videoSeconds = [self _videoSecondes:asset];
    
    CMTimeRange rangeTime = CMTimeRangeMake(CMTimeMakeWithSeconds(videoSeconds * 0.3, asset.duration.timescale), CMTimeMakeWithSeconds(videoSeconds * 0.5, asset.duration.timescale));
    [videotrack insertTimeRange:rangeTime ofTrack:[asset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:duration error:nil];
    [audiotrack insertTimeRange:rangeTime ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:duration error:nil];

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mainComposition presetName:AVAssetExportPreset1280x720];
    exporter.outputURL = [self clipUrl];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    __weak typeof(self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusWaiting:
                break;
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporting completed");
                // 想做什么事情在这个做
                [weakSelf _clipFinished];
                break;
            default:
                [weakSelf _clipFinished];
                NSLog(@"exporting failed %@",[exporter error]);
                break;
            }
    }];

}

- (CGFloat)_videoSecondes:(AVAsset *)asset{
    return asset.duration.value * 1.0f / asset.duration.timescale;
}

- (NSURL *)mergeUrl{
    NSArray *docpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentspath = [docpath objectAtIndex:0];
    return [NSURL fileURLWithPath:[documentspath stringByAppendingPathComponent:@"merge.mov"]];
}
- (NSURL*)clipUrl {
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    return [NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:@"clip.mov"]];
}


- (void)_mergeFinished {
 dispatch_async(dispatch_get_main_queue(), ^{
     [_buttonMerge setEnabled:YES];
     [self _playMergeVideo];
 });
}

- (void)_clipFinished {
 dispatch_async(dispatch_get_main_queue(), ^{
     [_buttonClip setEnabled:YES];
     [self _playClipVideo];
 });
}
- (void)_playMergeVideo{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self mergeUrl] options:nil];
    [_mergePlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
    [_mergePlayer play];
}

- (void)_playClipVideo{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self clipUrl] options:nil];
    [_clipPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
    [_clipPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
