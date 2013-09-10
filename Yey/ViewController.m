//
//  ViewController.m
//  Yey
//
//  Created by Yuta Teshigawara on 2013/09/04.
//  Copyright (c) 2013年 Yuta Teshigawara. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController () {
    BOOL filterFlag;
    UIScrollView *filterScrollView;
    GPUImageStillCamera *stillCamera;
    GPUImageFilter *filter;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filterFlag = TRUE;
    
    filterScrollView = [[UIScrollView alloc] init];
    filterScrollView.frame = CGRectMake(0, 0, 320, 60);
    filterScrollView.backgroundColor = [UIColor blackColor];
    //filterScrollView.alpha = 0.7;
    filterScrollView.bounces = NO;
    // ボタン生成
    int number;
    for (int i = 0; i < 26; i++) {
        UIButton *effectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        effectBtn.frame = CGRectMake(20 + (i * 60), 7, 45, 45);
        effectBtn.tag = i;
        NSString *buttonName = [NSString stringWithFormat:@"filter%@.jpg", [NSString stringWithFormat:@"%d", i]];
        // 枠線の色
        [[effectBtn layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        // 枠線の太さ
        [[effectBtn layer] setBorderWidth:1.5];
        [effectBtn setImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
        [effectBtn setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [effectBtn addTarget:self action:@selector(setEffect:)forControlEvents:UIControlEventTouchDown];
        [filterScrollView addSubview:effectBtn];
        number = i;
    }
    // scrollviewのコンテンツサイズ決定
    filterScrollView.contentSize = CGSizeMake(20 + (number * 60), 45);
    [self.filterSelectView addSubview:filterScrollView];
    filterScrollView.hidden = YES;
    
    // toolbarの作成
    [self setDefaultToolbar];
    // cameraの設定
    [self createDefaultCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ツールバー作成
- (void)setDefaultToolbar
{
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                  target:self
                                                                                  action:@selector(cameraAction:)
                                     ];
    UIBarButtonItem *effectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(effectAction:)
                                     ];
    // 固定間隔のスペーサーを作成する
    UIBarButtonItem * fixedSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpacer.width = 100;
    // 可変間隔のスペーサーを作成する
    UIBarButtonItem * flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // ボタンとスペーサーをツールバーに設定する
    self.toolBar.items = [NSArray arrayWithObjects:effectButton, fixedSpacer, cameraButton, flexibleSpacer, nil];
}

// カメラボタンを押したときの処理
- (void)savePhoto:(id)sender
{
    [stillCamera capturePhotoAsImageProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        // 保存
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:processedImage.CGImage
                                     metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  if (!error) {
                                      NSLog(@"success");
                                  } else {
                                      NSLog(@"failed");
                                  }
                              }
         ];
    }];
}

// cameraボタン押したとき
- (void)cameraAction:(id)sender
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.7;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cameraIris";
    [self.imageView.layer addAnimation:animation forKey:nil];
    
    filterScrollView.hidden = YES;
    [stillCamera capturePhotoAsImageProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        // 保存
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:processedImage.CGImage
                                     metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  if (!error) {
                                      NSLog(@"success");
                                  } else {
                                      NSLog(@"failed");
                                  }
                              }
         ];
    }];
}

// エフェクトメニュータッチ時
- (void)effectAction:(id)sender
{
    if(filterFlag) {
        NSLog(@"TRUE");
        filterScrollView.hidden = NO;
        filterFlag = FALSE;
    } else {
        NSLog(@"FALSE");
        filterScrollView.hidden = YES;
        filterFlag = TRUE;
    }
}

// カメラ＋フィルターを作成
-(void)setEffect:(UIButton *)button{
    filterScrollView.hidden = YES;
    filterFlag = TRUE;
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    filter = [[GPUImageFilter alloc] init];
    
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    // 向きの設定
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    [self setCameraFilter:button.tag];
    
    // cameraにフィルターをのせる
    [stillCamera addTarget:filter];
    // imageViewにのせる
    [filter addTarget:self.imageView];
    [stillCamera startCameraCapture];
}

// filter指定
- (void)setCameraFilter:(int)buttonTag
{
    switch (buttonTag) {
        case 0:
            filter = [[GPUImageBrightnessFilter alloc] init];
            break;
        case 1:
            filter = [[GPUImageLuminanceThresholdFilter alloc] init];
            break;
        case 2:
            filter = [[GPUImagePolarPixellateFilter alloc] init];
            break;
        case 3:
            filter = [[GPUImageSketchFilter alloc] init];
            break;
        case 4:
            filter = [[GPUImagePolkaDotFilter alloc] init];
            break;
        case 5:
            filter = [[GPUImageToonFilter alloc] init];
            break;
        case 6:
            filter = [[GPUImageSepiaFilter alloc] init];
            break;
        case 7:
            filter = [[GPUImageThresholdSketchFilter alloc] init];
            break;
        case 8:
            filter = [[GPUImageCrosshatchFilter alloc] init];
            break;
        case 9:
            filter = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
            break;
        case 10:
            filter = [[GPUImageHalftoneFilter alloc] init];
            break;
        case 11:
            filter = [[GPUImagePixellateFilter alloc] init];
            break;
        case 12:
            filter = [[GPUImageHistogramGenerator alloc] init];
            break;
        case 13:
            filter = [[GPUImageEmbossFilter alloc] init];
            break;
        case 14:
            filter = [[GPUImagePosterizeFilter alloc] init];
            break;
        case 15:
            filter = [[GPUImageBulgeDistortionFilter alloc] init];
            break;
        case 16:
            filter = [[GPUImagePinchDistortionFilter alloc] init];
            break;
        case 17:
            filter = [[GPUImageSphereRefractionFilter alloc] init];
            break;
        case 18:
            filter = [[GPUImageSwirlFilter alloc] init];
            break;
        case 19:
            filter = [[GPUImageVignetteFilter alloc] init];
            break;
        case 20:
            filter = [[GPUImageGlassSphereFilter alloc] init];
            break;
        case 21:
            filter = [[GPUImageFalseColorFilter alloc] init];
            break;
        case 22:
            filter = [[GPUImageHueFilter alloc] init];
            break;
        case 23:
            filter = [[GPUImageColorInvertFilter alloc] init];
            break;
        case 24:
            filter = [[GPUImageErosionFilter alloc] init];
            break;
        default:
            break;
    }
}

// 初期カメラ設定
- (void)createDefaultCamera
{
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    // 向きの設定
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // ここでフィルターの指定
    filter = [[GPUImageBrightnessFilter alloc] init];
    // cameraにフィルターをのせる
    [stillCamera addTarget:filter];
    // imageViewにのせる
    [filter addTarget:self.imageView];
    [stillCamera startCameraCapture];
}

@end
