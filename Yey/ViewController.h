//
//  ViewController.h
//  Yey
//
//  Created by Yuta Teshigawara on 2013/09/04.
//  Copyright (c) 2013年 Yuta Teshigawara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPUImageView;

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIView *filterSelectView;

@end
