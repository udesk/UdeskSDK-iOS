//
//  UdeskSurveyViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSurveyViewController.h"
#import "UIViewController+UdeskSDK.h"
#import "UdeskSurveyView.h"
#import "UIView+UdeskSDK.h"

@interface UdeskSurveyViewController ()<UIApplicationDelegate, UIGestureRecognizerDelegate>

@end

@implementation UdeskSurveyViewController

#pragma mark - 监听键盘通知做出相应的操作
- (void)subscribeToKeyboard {
    
    [self udSubscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        
        CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:self.view].origin.y;
        if (self.surveyView) {
            self.surveyView.surveyContentView.keyboardHeight = self.view.udHeight-keyboardY;
            self.surveyView.udBottom = keyboardY;
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
    if (CGRectContainsPoint([self.surveyView.contentView bounds], [touch locationInView:self.surveyView.contentView])){
        return NO;
    }
    
    return YES;
}

- (void)showSurveyView:(UdeskSurveyView *)surveyView completion:(void (^)(void))completion {
    _surveyView = surveyView;
 
    //监听键盘
    [self subscribeToKeyboard];

    UIViewController *topController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    while ([topController presentedViewController])    topController = [topController presentedViewController];
    
    [topController.view endEditing:YES];
    
    __block CGRect surveyViewFrame = surveyView.frame;
    {
        surveyViewFrame.origin.y = self.view.bounds.size.height;
        surveyView.frame = surveyViewFrame;
        [self.view addSubview:surveyView];
    }
    
    {
        self.view.frame = CGRectMake(0, 0, topController.view.bounds.size.width, topController.view.bounds.size.height);
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [topController addChildViewController:self];
        [topController.view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        surveyViewFrame.origin.y = self.view.bounds.size.height-surveyViewFrame.size.height;
        surveyView.frame = surveyViewFrame;
        
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    
    // remove键盘通知或者手势
    [self udUnsubscribeKeyboard];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|7<<16 animations:^{
        
        self.view.backgroundColor = [UIColor clearColor];
        CGRect surveyViewFrame = _surveyView.frame;
        surveyViewFrame.origin.y = self.view.bounds.size.height;
        if (self.surveyView) {
            self.surveyView.frame = surveyViewFrame;
        }
        
    } completion:^(BOOL finished) {
        
        if (self.surveyView) {
            [self.surveyView removeFromSuperview];
        }
        
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (completion) completion();
    }];
}

@end
