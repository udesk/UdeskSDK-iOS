//
//  UdeskSpeechRecognizerViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/8.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskSpeechRecognizerViewController.h"
#import "UIViewController+UdeskSDK.h"
#import "UdeskSpeechRecognizerView.h"
#import "UIView+UdeskSDK.h"

@interface UdeskSpeechRecognizerViewController ()<UIApplicationDelegate, UIGestureRecognizerDelegate>

@end

@implementation UdeskSpeechRecognizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //适配ios15
    if (@available(iOS 15.0, *)) {
        if(self.navigationController){
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            // 背景色
            appearance.backgroundColor = [UIColor whiteColor];
            // 去掉半透明效果
            appearance.backgroundEffect = nil;
            // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
            //        appearance.shadowColor = [UIColor clearColor];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
            self.navigationController.navigationBar.standardAppearance = appearance;
        }
    }
}

#pragma mark - 监听键盘通知做出相应的操作
- (void)subscribeToKeyboard {
    
    [self udSubscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        
        CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:self.view].origin.y;
        if (self.recognizerView) {
            
            if (keyboardY == self.view.udHeight) {
                
                self.recognizerView.editable = NO;
                [self.recognizerView stopEditContent];
            }
            else {
                
                self.recognizerView.editable = YES;
                [self.recognizerView startEditContent];
            }
        }
        
    } completion:nil];
}

- (void)loadView {
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self dismissWithCompletion:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint([self.recognizerView.contentView bounds], [touch locationInView:self.recognizerView.contentView])){
        return NO;
    }
    
    if (CGRectContainsPoint([self.recognizerView.navView bounds], [touch locationInView:self.recognizerView.navView])){
        return NO;
    }
    
    return YES;
}

- (void)showRecognizerView:(UdeskSpeechRecognizerView *)recognizerView completion:(void (^)(void))completion {
    _recognizerView = recognizerView;
    
    //监听键盘
    [self subscribeToKeyboard];
    
    UIViewController *topController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    while ([topController presentedViewController])    topController = [topController presentedViewController];
    
    [topController.view endEditing:YES];
    
    __block CGRect recognizerViewFrame = recognizerView.frame;
    {
        recognizerViewFrame.origin.y = self.view.bounds.size.height;
        recognizerView.frame = recognizerViewFrame;
        [self.view addSubview:recognizerView];
    }
    
    {
        self.view.frame = CGRectMake(0, 0, topController.view.bounds.size.width, topController.view.bounds.size.height);
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [topController addChildViewController:self];
        [topController.view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        recognizerViewFrame.origin.y = self.view.bounds.size.height-recognizerViewFrame.size.height;
        recognizerView.frame = recognizerViewFrame;
        
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    
    // remove键盘通知或者手势
    [self udUnsubscribeKeyboard];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:^{
        
        self.view.backgroundColor = [UIColor clearColor];
        CGRect surveyViewFrame = _recognizerView.frame;
        surveyViewFrame.origin.y = self.view.bounds.size.height;
        if (self.recognizerView) {
            self.recognizerView.frame = surveyViewFrame;
        }
        
    } completion:^(BOOL finished) {
        
        if (self.recognizerView) {
            [self.recognizerView removeFromSuperview];
        }
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (completion) completion();
    }];
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
