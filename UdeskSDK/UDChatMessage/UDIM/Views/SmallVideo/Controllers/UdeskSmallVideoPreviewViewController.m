//
//  UdeskSmallVideoPreviewViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallVideoPreviewViewController.h"
#import "UdeskVideoPlayerView.h"
#import "UdeskVideoUtil.h"
#import "UIImage+UdeskSDK.h"

@interface UdeskSmallVideoPreviewViewController ()<UdeskVideoPlayerViewDelegate>

@property (nonatomic, strong) UdeskVideoPlayerView *playerView;

@end

@implementation UdeskSmallVideoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    
    UIImageView *imgView ;
    if (self.url.length >0) {
        
        imgView = [[UIImageView alloc] initWithImage:[UdeskVideoUtil videoPreViewImageWithURL:self.url]];
        [self.view addSubview:imgView];
        imgView.frame = self.view.bounds;
        
        _playerView = [[UdeskVideoPlayerView alloc] initWithFrame:self.view.bounds videoUrl:self.url];
        _playerView.delegate = self;
        [self.view addSubview:_playerView];
    }
    else {
        
        imgView = [[UIImageView alloc] initWithImage:self.image];
        [self.view addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.frame = self.view.bounds;
    }
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setImage:[UIImage udDefaultSmallVideoDone] forState:UIControlStateNormal];
    confirmBtn.frame = CGRectMake(0, 0, 75, 75);
    confirmBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height - 75);
    confirmBtn.layer.cornerRadius = CGRectGetWidth(confirmBtn.frame) / 2;
    [confirmBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.tag = 662;
    [self.view addSubview:confirmBtn];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage udDefaultSmallVideoRetake] forState:UIControlStateNormal];
    backBtn.frame = confirmBtn.frame;
    backBtn.layer.cornerRadius = CGRectGetWidth(backBtn.frame) / 2;
    backBtn.tag = 661;
    [backBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [UIView animateWithDuration:0.1 animations:^{
        CGRect frame1 = backBtn.frame;
        frame1.origin.x = [UIScreen mainScreen].bounds.size.width * 0.093;
        backBtn.frame = frame1;
        
        CGRect frame2 = confirmBtn.frame;
        frame2.origin.x = ([UIScreen mainScreen].bounds.size.width - [UIScreen mainScreen].bounds.size.width *0.093) - frame2.size.width;
        confirmBtn.frame = frame2;
    }];
}

#pragma mark - ActionMethod
- (void)clickAction:(UIButton *)button {
    
    [self.view removeFromSuperview];
    [self.playerView pause];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
    if (button.tag == 661) {
        
        if (self.AbandonSmallVideoBlock) {
            self.AbandonSmallVideoBlock();
        }
    }
    else if (button.tag == 662){
        
        if (self.SubmitShootingBlock) {
            self.SubmitShootingBlock();
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self removeAllSubView];
}

- (void)removeAllSubView {
    while (self.view.subviews.count) {
        [self.view.subviews.lastObject removeFromSuperview];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
