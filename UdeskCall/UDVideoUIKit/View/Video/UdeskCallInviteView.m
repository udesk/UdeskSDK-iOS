//
//  UdeskCallInviteView.m
//  UdeskSDK
//
//  Created by xuchen on 2017/12/12.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskCallInviteView.h"
#import "UdeskVideoBundleHelper.h"
#import "UdeskCallingView.h"
#import <UdeskCall/UdeskCall.h>

@interface UdeskCallInviteView()<UdeskCallSessionManagerDelegate> {
    
    NSTimer *_disconnectTimer;
    NSInteger _disconnectTime;
}

@property (nonatomic, strong) UdeskCallingView *callingView;

@end

@implementation UdeskCallInviteView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupUI];
    
    [[UdeskCallSessionManager sharedManager] addDelegate:self];
}

- (void)setupUI {
    
    self.detailLabel.text = UVCLocalizedString(@"uvc_invite_detail");
    self.avatarView.image = [UIImage imageWithContentsOfFile:UVCBundlePath(@"udAgentAvatar")];
    
    [self.declineButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoHangUp.png")] forState:UIControlStateNormal];
    self.declineLabel.text = UVCLocalizedString(@"uvc_rejept");
    
    [self.answerButton setImage:[UIImage imageWithContentsOfFile:UVCBundlePath(@"udVideoAccept.png")] forState:UIControlStateNormal];
    self.answerLabel.text = UVCLocalizedString(@"uvc_answer");
    
    //屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)setNickName:(NSString *)nickName {
    _nickName = nickName;
    
    self.nickNameLabel.text = [NSString stringWithFormat:@"%@%@",UVCLocalizedString(@"uvc_agent"),nickName];
}

- (void)setAvatarURL:(NSString *)avatarURL {
    _avatarURL = avatarURL;
    
    if (self.avatarURL) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *newURL = [self.avatarURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newURL]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.avatarView.image = image;
                }
            });
        });
    }
}

- (IBAction)declineAction:(id)sender {
    
    [[UdeskCallSessionManager sharedManager] rejeptCall];
    [self hiddenInviteView];
}

- (IBAction)answerAction:(id)sender {
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect newframe = self.frame;
        newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.frame = newframe;
    } completion:^(BOOL finished) {
        
        //拒绝
        [self callEnded];
        [self callingView];
        [UIView animateWithDuration:0.35 animations:^{
            CGRect newframe = self.callingView.frame;
            newframe.origin.y = 0;
            self.callingView.frame = newframe;
            [[UdeskCallSessionManager sharedManager] acceptCall];
        }];
    }];
}

//通话结束
- (void)callEnded {
    
    if (self.callEndedBlock) {
        self.callEndedBlock();
    }
}

#pragma mark - UdeskCallSessionManagerDelegate
//取消
- (void)remoteUserDidCancel:(NSString *)userId {
 
    [self hiddenInviteView];
}

//无应答
- (void)remoteUserDidNotAnswered:(NSString *)userId {
    
    [self hiddenInviteView];
}

//网络连接正常
- (void)connectionDidNormal {
    
    _disconnectTime = 0;
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
}

//网络连接丢失回调
- (void)connectionDidLost {
    
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(disconnectTimeAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_disconnectTimer forMode:NSRunLoopCommonModes];
}

- (void)disconnectTimeAction {
    
    _disconnectTime++;
    if (_disconnectTime == 30) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:UVCLocalizedString(@"uvc_disconnected_network")
                                   delegate:nil
                          cancelButtonTitle:UVCLocalizedString(@"uvc_close")
                          otherButtonTitles:nil] show];
#pragma clang diagnostic pop
        
        [_disconnectTimer invalidate];
        _disconnectTimer = nil;
        [self hiddenInviteView];
    }
}

//隐藏
- (void)hiddenInviteView {
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect newframe = self.frame;
        newframe.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.frame = newframe;
    } completion:^(BOOL finished) {
        [self callEnded];
    }];
}

- (UdeskCallingView *)callingView {
    if (!_callingView) {
        _callingView = [UdeskCallingView instanceCallingView];
        _callingView.waitAcceptLabel.hidden = YES;
        _callingView.frame = CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        [[UIApplication sharedApplication].delegate.window addSubview:_callingView];
    }
    return _callingView;
}

+ (UdeskCallInviteView *)instanceCallInviteView {
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"UdeskCallInviteView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

- (void)dealloc {
    
    //屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UdeskCallSessionManager sharedManager] removeDelegate:self];
}

@end
