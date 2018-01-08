//  Created by zhangyi on 16/8/25.
//  Copyright © 2016年 iqiyi.com. All rights reserved.

#import "GPUImageFilterViewController.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface GPUImageFilterViewController ()
@property (nonatomic, weak)GPUImageBilateralFilter  *bilateralFilter;
@property (nonatomic, weak)GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong)GPUImageStillCamera      *videoCamera;
@property (nonatomic, strong)GPUImageFilterGroup *groupFliter;
@end

@implementation GPUImageFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"GPUImage美颜";
    
    [self initBottomView];
    
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

    
    //  4.创建磨皮、美白组合滤镜
    GPUImageFilterGroup *groupFliter = [[GPUImageFilterGroup alloc] init];
    
    //  5.磨皮滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [groupFliter addFilter:bilateralFilter];
    _bilateralFilter = bilateralFilter;
    
    //  6.美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [groupFliter addFilter:brightnessFilter];
    _brightnessFilter = brightnessFilter;
    
    
    //  7.设置滤镜组链
    [bilateralFilter addTarget:brightnessFilter];
    [groupFliter setInitialFilters:@[bilateralFilter]];
    groupFliter.terminalFilter = brightnessFilter;
    
    //  8.设置GPUImage处理链 从数据源->滤镜->界面展示
    [videoCamera addTarget:groupFliter];
    [groupFliter addTarget:captureVideoPreview];
    _groupFliter = groupFliter;
    //  9.调用startCameraCapture采集视频,底层会把采集到的视频源，渲染到GPUImageView上，接着界面显示
    [videoCamera startCameraCapture];
}

- (void)initBottomView
{
    UIView *bottomControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 118)];
    CGRect tempRect = bottomControlView.frame;
    
    tempRect.origin.y = self.view.frame.size.height - bottomControlView.frame.size.height ;
    bottomControlView.frame = tempRect;
    [self.view addSubview:bottomControlView];
    

    //磨皮
    UILabel *bilateralL = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 40, 25)];
    bilateralL.text = @"磨皮";
    bilateralL.textColor = [UIColor redColor];
    bilateralL.font = [UIFont systemFontOfSize:12];
    [bottomControlView addSubview:bilateralL];
    
    UISlider *bilateralSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 10, 250, 30)
                                ];
//    bilateralSld.minimumValue = -1;
    bilateralSld.maximumValue = 10;
//    bilateralSld.value = 0;
    [bilateralSld addTarget:self action:@selector(bilateralFilter:) forControlEvents:UIControlEventValueChanged];
    [bottomControlView addSubview:bilateralSld];
    
    
    //美白
    UILabel *brightnessL = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 25)];
    brightnessL.text = @"美白";
    brightnessL.textColor = [UIColor redColor];
    brightnessL.font = [UIFont systemFontOfSize:12];
    [bottomControlView addSubview:brightnessL];
    
    UISlider *brightnessSld  = [[UISlider alloc] initWithFrame:CGRectMake(50, 40, 250, 30)
                                ];
    brightnessSld.minimumValue = -1;
    brightnessSld.maximumValue = 1;
//    brightnessSld.value = 0;
    [brightnessSld addTarget:self action:@selector(brightnessFilter:) forControlEvents:UIControlEventValueChanged];
    [bottomControlView addSubview:brightnessSld];
    
    UIButton *captureBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 60, 60, 30)];
    [captureBtn setTitle:@"点击拍照" forState:UIControlStateNormal];
    [captureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    captureBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [captureBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [bottomControlView addSubview:captureBtn];
}

- (void)click{
    [_videoCamera capturePhotoAsJPEGProcessedUpToFilter:_groupFliter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        
        [self saveIMG:processedJPEG];
    }];
}

- (void)saveIMG:(NSData *)data{
    NSData *imageData = data;
    // 创建ALAssetsLibrary，用于将照片写入相册
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                              orientation:(ALAssetOrientation)[image imageOrientation]
                          completionBlock:nil];
}

#pragma mark - 调整亮度
- (void)brightnessFilter:(UISlider *)slider
{
    _brightnessFilter.brightness = slider.value;
}

#pragma mark - 调整磨皮
- (void)bilateralFilter:(UISlider *)slider
{
    //值越小，磨皮效果越好
    CGFloat maxValue = 10;
    [_bilateralFilter setDistanceNormalizationFactor:(maxValue - slider.value)];
}

//- (void)photoBtnDidClick
//{
//    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
//    if (!conntion) {
//        NSLog(@"拍照失败!");
//        return;
//    }
//    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//        if (imageDataSampleBuffer == nil) {
//            return ;
//        }
//        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//        self.image = [UIImage imageWithData:imageData];
//        [self.session stopRunning];
//        [self.view addSubview:self.cameraImageView];
//    }
//     
//   
// }




@end
