//
//  UdeskCallManager.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskCallManager.h"

#if __has_include(<UdeskCall/UdeskCall.h>)

#import <UdeskCall/UdeskCall.h>
#import <AVFoundation/AVFoundation.h>
#import "UdeskAgoraRtcEngineManager.h"
#import "UdeskCallInviteView.h"
#import "UdeskCallingView.h"
#import "UdeskSDKMacro.h"
#import "UIView+UdeskSDK.h"
#import "UdeskSetting.h"
#import "UdeskManager.h"
#import "UdeskBundleUtils.h"
#import "UdeskMessage+UdeskSDK.h"
#import "UdeskAgent.h"
#import "UdeskSDKUtil.h"

@interface UdeskCallManager()<UdeskCallSessionManagerDelegate>

/** 用户ID */
@property (nonatomic, copy  ) NSString      *currentUserId;
/** 铃声播放 */
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
/** sdk配置 */
@property (nonatomic, strong) UdeskSetting  *sdkSetting;
/** 客服 */
@property (nonatomic, strong) UdeskAgent    *agentModel;
/** 通话view */
@property (nonatomic, strong) UdeskCallingView *callingView;
/** 邀请view */
@property (nonatomic, strong) UdeskCallInviteView *callInviteView;

@end
#endif

@implementation UdeskCallManager

#if __has_include(<UdeskCall/UdeskCall.h>)
- (instancetype)initWithSetting:(UdeskSetting *)sdkSetting
{
    self = [super init];
    if (self) {
        
        _sdkSetting = sdkSetting;
        [self registrationNotice];
    }
    return self;
}

#pragma mark - 视频通话
- (void)registrationNotice {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udeskCallApplicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(udeskCallApplicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
}

//进入后台
- (void)udeskCallApplicationEnterBackground {
    [[UdeskCallSessionManager sharedManager] disConnect];
}

//进入前台
- (void)udeskCallApplicationBecomeActive {
    [[UdeskCallSessionManager sharedManager] connect];
}

//初始化视频manager
- (void)configUdeskCallWithCustomerJID:(NSString *)customerJID agentModel:(UdeskAgent *)agentModel {
    if (!self.sdkSetting || self.sdkSetting == (id)kCFNull) return ;
    if (!agentModel || agentModel == (id)kCFNull) return ;
    if (!customerJID || customerJID == (id)kCFNull) return ;
    
    @try {
        
        //没有开启视频功能
        if (!self.sdkSetting.vCall.boolValue || !self.sdkSetting.sdkVCall.boolValue) {
            [[UdeskCallSessionManager sharedManager] disConnect];
            return;
        }
        
        self.currentUserId = customerJID;
        self.agentModel = agentModel;
        UdeskCallUserProfile *userProfile = [[UdeskCallUserProfile alloc] initWithAppId:self.sdkSetting.vcAppId
                                                                              subdomain:[UdeskManager domain]
                                                                           bizSessionId:agentModel.imSubSessionId];
        userProfile.agoraAppId = self.sdkSetting.agoraAppId;
        userProfile.serverURL = self.sdkSetting.serverURL;
        userProfile.vCallTokenURL = self.sdkSetting.vCallTokenURL;
        userProfile.userId = customerJID;
        userProfile.toUserId = agentModel.jid;
        userProfile.resId = customerJID;
        userProfile.toResId = agentModel.jid;
        
        [[UdeskCallSessionManager sharedManager] setUserProfile:userProfile];
        [[UdeskCallSessionManager sharedManager] removeDelegate:self];
        [[UdeskCallSessionManager sharedManager] addDelegate:self];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - @protocol UdeskSocketDelegate
//未登录
- (void)remoteUserDidNotLogedIn:(NSString *)userId {
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:getUDLocalizedString(@"udesk_video_call_agent_not_logged_in")];
}

//挂断
- (void)remoteUserDidHangup:(NSString *)userId {
    
    [self setVideoCallMessage:userId content:[NSString stringWithFormat:@"%@ %@",getUDLocalizedString(@"udesk_video_call_duration"),[UdeskAgoraRtcEngineManager shared].durationLabel.text]];
    //停止播放
    [self stopPlayVideoCallRing];
}
//邀请
- (void)remoteUserDidInvite:(NSString *)userId {
    
    [self didReceiveInviteWithAgentNick:self.agentModel.nick agentAvatar:self.agentModel.avatar];
    //开始播放
    [self startPlayRing:getUDBundlePath(@"udeskCall.mp3")];
}

//拒绝
- (void)remoteUserDidDecline:(NSString *)userId {
    
    NSString *content = getUDLocalizedString(@"udesk_video_call_agent_decline");
    if ([userId isEqualToString:self.currentUserId]) {
        content = getUDLocalizedString(@"udesk_video_call_customer_decline");
    }
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:content];
    //停止播放
    [self stopPlayVideoCallRing];
}

//取消
- (void)remoteUserDidCancel:(NSString *)userId {
    
    NSString *content = getUDLocalizedString(@"udesk_video_call_agent_cancel");
    if (![userId isEqualToString:self.currentUserId]) {
        content = getUDLocalizedString(@"udesk_video_call_customer_cancel");
    }
    [self setVideoCallMessage:userId content:content];
    
    //停止播放
    [self stopPlayVideoCallRing];
}

//忙线
- (void)remoteUserDidLineBusy:(NSString *)userId {
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:getUDLocalizedString(@"udesk_video_call_agent_busy")];
    
    //停止播放
    [self stopPlayVideoCallRing];
}

//无应答
- (void)remoteUserDidNotAnswered:(NSString *)userId {
    
    NSString *content = getUDLocalizedString(@"udesk_video_call_agent_not_answered");
    if ([userId isEqualToString:self.currentUserId]) {
        content = getUDLocalizedString(@"udesk_video_call_customer_cancel");
    }
    
    [self setNotAnsweredAndDeclineVideoCallMessage:userId content:content];
    //停止播放
    [self stopPlayVideoCallRing];
}

//加入
- (void)userJoinChannel:(NSString *)userId channelToken:(NSString *)channelToken channelId:(NSString *)channelId agoraUid:(NSUInteger)agoraUid {
    
    //停止播放
    [self stopPlayVideoCallRing];
}

- (void)setNotAnsweredAndDeclineVideoCallMessage:(NSString *)userId content:(NSString *)content {
    
    UdeskMessage *message = [[UdeskMessage alloc] initWithVideoCall:content];
    message.agentJid = self.agentModel.jid;
    message.imSubSessionId = [NSString stringWithFormat:@"%ld",self.agentModel.imSubSessionId];
    if ([userId isEqualToString:self.currentUserId]) {
        message.messageFrom = UDMessageTypeReceiving;
    }
    
    if (self.didSendMessageBlock) {
        self.didSendMessageBlock(message);
    }
    [UdeskManager sendMessage:message progress:nil completion:nil];
}

//设置视频消息
- (void)setVideoCallMessage:(NSString *)userId content:(NSString *)content {
    
    UdeskMessage *message = [[UdeskMessage alloc] initWithVideoCall:content];
    message.agentJid = self.agentModel.jid;
    message.imSubSessionId = [NSString stringWithFormat:@"%ld",self.agentModel.imSubSessionId];
    if (![userId isEqualToString:self.currentUserId]) {
        message.messageFrom = UDMessageTypeReceiving;
    }
    
    if (self.didSendMessageBlock) {
        self.didSendMessageBlock(message);
    }
    [UdeskManager sendMessage:message progress:nil completion:nil];
}

- (void)startPlayRing:(NSString *)ringPath {
    if (ringPath) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况按静音或者锁屏键会静音
        [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        [audioSession setActive:YES error:nil];
        
        if (self.audioPlayer) {
            [self stopPlayVideoCallRing];
        }
        
        NSURL *url = [NSURL URLWithString:ringPath];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
}

- (UdeskCallingView *)callingView {
    if (!_callingView) {
        _callingView = [UdeskCallingView instanceCallingView];
        _callingView.frame = [UIScreen mainScreen].bounds;
        _callingView.udTop = UD_SCREEN_HEIGHT;
        [[UIApplication sharedApplication].delegate.window addSubview:_callingView];
        @udWeakify(self);
        _callingView.callEndedBlock = ^{
            @udStrongify(self);
            [self.callingView removeFromSuperview];
            self.callingView = nil;
        };
    }
    return _callingView;
}

//邀请view
- (UdeskCallInviteView *)callInviteView {
    if (!_callInviteView) {
        _callInviteView = [UdeskCallInviteView instanceCallInviteView];
        _callInviteView.frame = [UIScreen mainScreen].bounds;
        _callInviteView.udTop = UD_SCREEN_HEIGHT;
        [[UIApplication sharedApplication].delegate.window addSubview:_callInviteView];
        @udWeakify(self);
        _callInviteView.callEndedBlock = ^{
            @udStrongify(self);
            [self.callInviteView removeFromSuperview];
            self.callInviteView = nil;
            [self stopPlayVideoCallRing];
        };
    }
    return _callInviteView;
}

//收到视频邀请
- (void)didReceiveInviteWithAgentNick:(NSString *)nick agentAvatar:(NSString *)agentAvatar {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UdeskSDKUtil currentViewController].view endEditing:YES];
        self.callInviteView.avatarURL = agentAvatar;
        self.callInviteView.nickName = nick;
        [UIView animateWithDuration:0.35 animations:^{
            self.callInviteView.udTop = 0;
        }];
    });
}

//开始视频
- (void)startUdeskVideoCall {
    
    [self callingView];
    //邀请
    [self inviteVideoCall];
    [UIView animateWithDuration:0.35 animations:^{
        self.callingView.udTop = 0;
    }];
}

- (void)stopPlayVideoCallRing {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        //设置铃声停止后恢复其他app的声音
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    }
}

//邀请视频
- (void)inviteVideoCall {
    
    [[UdeskCallSessionManager sharedManager] inviteVideo];
}


- (void)dealloc
{
    [[UdeskCallSessionManager sharedManager] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#endif

@end
