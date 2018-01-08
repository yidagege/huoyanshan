//  Created by zhangyi on 16/8/25.
//  Copyright © 2016年 iqiyi.com. All rights reserved.

#import "BeautifyFilterViewController.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define BSCollectionName @"美颜"
@interface BeautifyFilterViewController (){
    NSURL * movieURL;
    GPUImageMovieWriter *movieWriter;
}
@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *captureVideoPreview;
@property (nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;
@end

@implementation BeautifyFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Beautify美颜";
    
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(140, 80, 70, 30)];
    [switcher addTarget:self action:@selector(changeBeautyFilter:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:switcher];
    
    UIButton *captureBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 120, 60, 30)];
    [captureBtn setTitle:@"点击拍照" forState:UIControlStateNormal];
    [captureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    captureBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [captureBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captureBtn];
    
    UIButton *rotateBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 120, 60, 30)];
    [rotateBtn setTitle:@"切换" forState:UIControlStateNormal];
    [rotateBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    rotateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [rotateBtn addTarget:self action:@selector(rotateBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rotateBtn];
    
    UIButton *recordBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 120, 60, 30)];
    [recordBtn setTitle:@"录片" forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [recordBtn addTarget:self action:@selector(recordBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordBtn];
    
    //  1. 创建视频摄像头
    // SessionPreset:屏幕分辨率，AVCaptureSessionPresetHigh会自适应高分辨率
    // cameraPosition:摄像头方向
    // 最好使用AVCaptureSessionPresetHigh，会自动识别，如果用太高分辨率，当前设备不支持会直接报错
    GPUImageStillCamera *videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    
    //  2. 设置摄像头输出视频的方向
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera = videoCamera;
    
    
    //  3. 创建用于展示视频的GPUImageView
    GPUImageView *captureVideoPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:captureVideoPreview atIndex:0];
    _captureVideoPreview = captureVideoPreview;
    
    //  4.设置处理链
    [_videoCamera addTarget:_captureVideoPreview];
    
    //  5.调用startCameraCapture采集视频,底层会把采集到的视频源，渲染到GPUImageView上，接着界面显示
    [videoCamera startCameraCapture];

    // 创建美颜滤镜
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    _beautifyFilter = beautifyFilter;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LiveMovied2.m4v"];
    movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    //设置为liveVideo
    movieWriter.encodingLiveVideo = YES;
    [_beautifyFilter addTarget:movieWriter];
    //设置声音
    _videoCamera.audioEncodingTarget = movieWriter;
}

- (void)recordBtn:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        
        [self starWrite];
    }else{
        [self stopWrite];
    }
}


- (void)starWrite{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [movieWriter startRecording];
    });
    
}
- (void)stopWrite{
    dispatch_async(dispatch_get_main_queue(), ^{
        [movieWriter finishRecording];
        _videoCamera.audioEncodingTarget = nil;
        [_beautifyFilter removeTarget:movieWriter];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }
                 });
             }];
        }
        
        
        
    });
    
}

- (void)rotateBtn{
    [_videoCamera rotateCamera];
}

- (void)click{
    [_videoCamera capturePhotoAsJPEGProcessedUpToFilter:_beautifyFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        
        [self saveIMG:processedJPEG];
    }];
}

- (void)saveIMG:(NSData *)data{
    NSData *imageData = data;
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    __block NSString *assetId = nil;
    // 1. 存储图片到"相机胶卷"
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            return;
        }
        
        // 2. 获得相册对象
        PHAssetCollection *collection = [self collection];
        // 3. 将“相机胶卷”中的图片添加到新的相册
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            // 根据唯一标示获得相片对象
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            // 添加图片到相册中
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                return;
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            }];
        }];
    }];
}

- (PHAssetCollection *)collection{
    // 先获得之前创建过的相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:BSCollectionName]) {
            return collection;
        }
    }
    
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil;
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:BSCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}


- (void)changeBeautyFilter:(UISwitch *)sender
{
    if (sender.on) {
        
        // 移除之前所有的处理链
        [_videoCamera removeAllTargets];
        
        // 创建美颜滤镜
//        GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        
        // 设置GPUImage处理链，从数据->滤镜->界面展示
        [_videoCamera addTarget:_beautifyFilter];
//        _beautifyFilter = beautifyFilter;
        [_beautifyFilter addTarget:_captureVideoPreview];

    } else {
        
        // 移除之前所有的处理链
        [_videoCamera removeAllTargets];
        [_videoCamera addTarget:_captureVideoPreview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
