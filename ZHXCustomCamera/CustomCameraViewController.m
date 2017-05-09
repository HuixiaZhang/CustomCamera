//
//  CustomCameraViewController.m
//  ZHXCustomCamera
//
//  Created by apple on 17/5/4.
//  Copyright © 2017年 com. All rights reserved.
//

#import "CustomCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoHandleViewController.h"

@interface CustomCameraViewController ()<AVCaptureMetadataOutputObjectsDelegate,AVCapturePhotoCaptureDelegate>

// 捕获设备,前置,后置摄像头,麦克风
@property (nonatomic,strong) AVCaptureDevice *device;

@property (nonatomic,strong) AVCapturePhotoSettings *settings;

// 输入设备
@property (nonatomic,strong) AVCaptureDeviceInput *input;

@property (nonatomic,strong) AVCaptureMetadataOutput *output;
// 输出图片
@property (nonatomic,strong) AVCapturePhotoOutput *photoOutput;

// 摄像头
@property (nonatomic,strong) AVCaptureSession *session;

// 实时显示捕获的图像
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *layer;

// 聚焦点
@property (nonatomic,strong) UIView *focusView;

@end

@implementation CustomCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"自定义相机";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self customCamera];
    
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, self.view.frame.size.height / 2 + 100, 100, 30)];
    [saveBtn addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    
    saveBtn.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:saveBtn];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];

    
    // Do any additional setup after loading the view.
}

- (UIView *)focusView {
    if (!_focusView) {
        
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderWidth = 1.0;
        _focusView.layer.borderColor =[UIColor greenColor].CGColor;
        _focusView.backgroundColor = [UIColor clearColor];
    
    }
    return _focusView;
}

- (void)customCamera {
    
    
    // AVMediaTypeVideo 代表视频 (默认使用后置);
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 设备输入
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    // 输出对象
    self.output = [[AVCaptureMetadataOutput alloc] init];
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    
    // 会话 结合输入输出
    self.session = [[AVCaptureSession alloc] init];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    
    if ([self.session canAddInput:self.input]) {
        
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.photoOutput]) {
        
        [self.session addOutput:self.photoOutput];
    }
    
    // 预览
    
    self.layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.layer.frame = CGRectMake(20, 70, self.view.frame.size.width - 40, self.view.frame.size.height / 2);
    self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:self.layer];
    
    // 开始启动
    [self.session startRunning];
    
    if ([self.device lockForConfiguration:nil]) {
        
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        
        // 自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        
        [self.device unlockForConfiguration];
        
//        self.device.
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.settings = [[AVCapturePhotoSettings alloc] init];
    self.settings.flashMode = AVCaptureFlashModeAuto;
}

// 聚焦点

- (void)focusGesture:(UITapGestureRecognizer *)recognizer {
    
    CGPoint point = [recognizer locationInView:recognizer.view];
    
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point {
    
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake(point.y / size.height, 1 - point.x / size.width);
    NSError *error;
    
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
            
        }
        
        [self.device unlockForConfiguration];
        
    }
    _focusView.center = point;
    _focusView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
           
            _focusView.hidden = YES;
        }];
    }];
}

// 截取图片
- (void)shutterCamera {
    
    AVCaptureConnection *videoConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        
        NSLog(@"拍照失败");
        return;
    }
    
    [self.photoOutput capturePhotoWithSettings:self.settings delegate:self];
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    
    if (photoSampleBuffer == NULL) {
        
        return;
    }
    
    NSData *imgData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    
    PhotoHandleViewController *photoVC = [[PhotoHandleViewController alloc] init];
    photoVC.img = [UIImage imageWithData:imgData];
    [self.navigationController pushViewController:photoVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
