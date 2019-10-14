//
//  UdeskChatInputToolBar.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/20.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskChatInputToolBar.h"
#import "UIImage+UdeskSDK.h"
#import "UIView+UdeskSDK.h"
#import "UdeskSDKConfig.h"
#import "UdeskManager.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskPrivacyUtil.h"
#import "UdeskMessageTableView.h"

/** 按钮大小 */
static CGFloat const kInputToolBarIconDiameter = 32.0;
/** 表情按钮大小 */
static CGFloat const kInputToolBarEmojiIconDiameter = 22.0;
/** 输入框距垂直距离 */
static CGFloat const kChatTextViewToVerticalEdgeSpacing = 8.0;
/** 输入框距的横行距离 */
static CGFloat const kChatTextViewToHorizontalEdgeSpacing = 8.0;
/** 输入框功能按钮横行的间距 */
static CGFloat const kInputToolBarIconToHorizontalEdgeSpacing = 10.0;
/** 输入框按钮距离顶部的垂直距离 */
static CGFloat const kInputToolBarIconToVerticalEdgeSpacing = 11.0;
/** 表情顶部的垂直距离 */
static CGFloat const kInputToolBarEmojiIconToVerticalEdgeSpacing = 16.0;

@interface UdeskChatInputToolBar()<UITextViewDelegate,UdeskCustomToolBarDelegate>

@property (nonatomic, strong) UdeskButton *voiceButton;
@property (nonatomic, strong) UdeskButton *emotionButton;
@property (nonatomic, strong) UdeskButton *moreButton;
@property (nonatomic, strong) UdeskButton *recordButton;

@property (nonatomic, strong) UIView             *defaultToolBar;
@property (nonatomic, strong) UdeskCustomToolBar *customToolBar;

@property (nonatomic, strong) UdeskMessageTableView *messageTableView;
@property (nonatomic, strong) NSDate *sendDate;
@property (nonatomic, assign) CGRect  originalChatViewFrame;
@property (nonatomic, assign) CGFloat textViewHeight;

@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation UdeskChatInputToolBar

- (instancetype)initWithFrame:(CGRect)frame tableView:(UdeskMessageTableView *)tabelView {
    self = [super initWithFrame:frame];
    if (self) {
        
        _messageTableView = tabelView;
        _originalChatViewFrame = tabelView.frame;
        _sendDate = [NSDate date];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    
    self.backgroundColor = sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
    
    //默认toolbar
    _defaultToolBar = [[UIView alloc] init];
    _defaultToolBar.backgroundColor = sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
    [self addSubview:_defaultToolBar];
    
    //语音
    _voiceButton = [[UdeskButton alloc] init];
    _voiceButton.hidden = !sdkConfig.isShowVoiceEntry;
    [_voiceButton setImage:[UIImage udDefaultVoiceImage] forState:UIControlStateNormal];
    [_voiceButton setImage:[UIImage udDefaultKeyboardImage] forState:UIControlStateSelected];
    [_voiceButton addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    if (sdkConfig.isShowVoiceEntry) {
        [_defaultToolBar addSubview:_voiceButton];
    }
    
    //初始化输入框
    _chatTextView = [[UdeskHPGrowingTextView alloc] initWithFrame:CGRectZero];
    _chatTextView.placeholder = getUDLocalizedString(@"udesk_typing");
    _chatTextView.delegate = (id)self;
    _chatTextView.returnKeyType = UIReturnKeySend;
    _chatTextView.internalTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, kInputToolBarEmojiIconDiameter+kInputToolBarIconToHorizontalEdgeSpacing);
    _chatTextView.font = [UIFont systemFontOfSize:15];
    _chatTextView.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.textViewColor;
    [_defaultToolBar addSubview:_chatTextView];
    UDViewRadius(_chatTextView, 19);
    
    _recordButton = [[UdeskButton alloc] init];
    _recordButton.alpha = _voiceButton.selected;
    _recordButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _recordButton.backgroundColor = [UIColor whiteColor];
    [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordButton setTitle:getUDLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(holdDownDragOutside:) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(holdDownDragInside:) forControlEvents:UIControlEventTouchDragEnter];
    [_defaultToolBar addSubview:_recordButton];
    UDViewRadius(_recordButton, 19);
    
    //表情
    _emotionButton = [[UdeskButton alloc] init];
    _emotionButton.hidden = !sdkConfig.isShowEmotionEntry;
    [_emotionButton setImage:[UIImage udDefaultSmileImage] forState:UIControlStateNormal];
    [_emotionButton setImage:[UIImage udDefaultKeyboardSmallImage] forState:UIControlStateSelected];
    [_emotionButton addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
    if (sdkConfig.isShowEmotionEntry) {
        [_defaultToolBar addSubview:_emotionButton];
    }
    
    //更多
    _moreButton = [[UdeskButton alloc] init];
    [_moreButton setImage:[UIImage udDefaultMoreImage] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage udDefaultMoreCloseImage] forState:UIControlStateSelected];
    [_moreButton addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_moreButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    
    //用户自定义按钮
    CGFloat customToolBarHeight = 0;
    if (_customToolBar) {
        if (!_customToolBar.hidden) {
            _customToolBar.frame = CGRectMake(0, 0, self.udWidth, 44);
            customToolBarHeight = 44;
        }
    }
    
    _defaultToolBar.frame = CGRectMake(0, customToolBarHeight, self.udWidth, self.udHeight - customToolBarHeight - (udIsIPhoneXSeries?34:0));
    
    //计算textview的width
    CGFloat textViewWidth = self.udWidth - (kInputToolBarIconToHorizontalEdgeSpacing*2);
    
    if (sdkConfig.isShowVoiceEntry && !_voiceButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    if (!_moreButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    //当textview height发生改变时button位置不改变
    if (_defaultToolBar.udHeight <= 55) {
     
        if (sdkConfig.isShowVoiceEntry && !_voiceButton.hidden) {
            _voiceButton.frame = CGRectMake(kInputToolBarIconToHorizontalEdgeSpacing, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
        
        if (!_moreButton.hidden) {
            _moreButton.frame = CGRectMake(_defaultToolBar.udRight-kInputToolBarIconToHorizontalEdgeSpacing-kInputToolBarIconDiameter, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
        
        if (sdkConfig.isShowEmotionEntry && !_emotionButton.hidden) {
            _emotionButton.frame = CGRectMake(_moreButton.udLeft - (kInputToolBarIconToHorizontalEdgeSpacing*2) - kInputToolBarEmojiIconDiameter, kInputToolBarEmojiIconToVerticalEdgeSpacing, kInputToolBarEmojiIconDiameter, kInputToolBarEmojiIconDiameter);
        }
    }
    
    _chatTextView.frame = CGRectMake((_voiceButton.hidden?0:_voiceButton.udRight) + kChatTextViewToHorizontalEdgeSpacing, kChatTextViewToVerticalEdgeSpacing, textViewWidth, _defaultToolBar.udHeight - (kChatTextViewToVerticalEdgeSpacing*2));
    _recordButton.frame = _chatTextView.frame;
}

//点击语音
- (void)voiceClick:(UdeskButton *)button {
    
    [UdeskPrivacyUtil checkPermissionsOfMicrophone:^{
        if ([self checkAgentStatusValid]) {
            if (!self.isRobotSession) {
                button.selected = !button.selected;
                self.recordButton.alpha = button.selected;
                self.chatTextView.alpha = !button.selected;
                self.emotionButton.selected = NO;
                self.emotionButton.hidden = button.selected;
            }
            self.chatInputType = UdeskChatInputTypeVoice;
            self.moreButton.selected = NO;
            if ([self.delegate respondsToSelector:@selector(didSelectVoice:)]) {
                [self.delegate didSelectVoice:button];
            }
        }
        else {
            self.chatInputType = UdeskChatInputTypeNormal;
        }
    }];
}

//点击表情按钮
- (void)emotionClick:(UdeskButton *)button {
    
    //检查客服状态
    if ([self checkAgentStatusValid]) {
        button.selected = !button.selected;
        self.chatInputType = UdeskChatInputTypeEmotion;
        self.voiceButton.selected = NO;
        self.moreButton.selected = NO;
        if (button.selected) {
            self.recordButton.alpha = 0;
            self.chatTextView.alpha = 1;
        }
        if ([self.delegate respondsToSelector:@selector(didSelectEmotion:)]) {
            [self.delegate didSelectEmotion:button];
        }
    }
    else {
        self.chatInputType = UdeskChatInputTypeNormal;
    }
}

//点击更多
- (void)moreClick:(UdeskButton *)button {
    
    //检查客服状态
    if ([self checkAgentStatusValid]) {
        button.selected = !button.selected;
        self.chatInputType = UdeskChatInputTypeMore;
        self.voiceButton.selected = NO;
        if (!self.isRobotSession) {
            self.emotionButton.selected = NO;
            self.emotionButton.hidden = NO;
        }
        if (button.selected) {
            self.recordButton.alpha = 0;
            self.chatTextView.alpha = 1;
        }
        if ([self.delegate respondsToSelector:@selector(didSelectMore:)]) {
            [self.delegate didSelectMore:button];
        }
    }
    else {
        self.chatInputType = UdeskChatInputTypeNormal;
    }
}

//按下
- (void)holdDownButtonTouchDown:(UdeskButton *)button {
    
    [button setTitle:getUDLocalizedString(@"udesk_release_to_send") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.776f  green:0.78f  blue:0.792f alpha:1];
    
    self.isCancelled = NO;
    self.isRecording = NO;
    if ([self.delegate respondsToSelector:@selector(prepareRecordingVoiceActionWithCompletion:)]) {
        @udWeakify(self);
        [self.delegate prepareRecordingVoiceActionWithCompletion:^BOOL{
            @udStrongify(self);
            if (self && !self.isCancelled) {
                self.isRecording = YES;
                [self.delegate didStartRecordingVoiceAction];
                return YES;
            } else {
                return NO;
            }
        }];
    }
}

//在按钮边界外松开
- (void)holdDownButtonTouchUpOutside:(UdeskButton *)button {
    
    [button setTitle:getUDLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];

    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
            [self.delegate didCancelRecordingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

//松开
- (void)holdDownButtonTouchUpInside:(UdeskButton *)button {
    
    [button setTitle:getUDLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];

    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
            [self.delegate didFinishRecoingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

//离开按钮边界
- (void)holdDownDragOutside:(UdeskButton *)button {
    
    [button setTitle:getUDLocalizedString(@"udesk_release_to_cancel") forState:UIControlStateNormal];
    
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
            [self.delegate didDragOutsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

//进入按钮区域
- (void)holdDownDragInside:(UdeskButton *)button {
    
    [button setTitle:getUDLocalizedString(@"udesk_release_to_send") forState:UIControlStateNormal];
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
            [self.delegate didDragInsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

#pragma mark - Text view delegate
- (void)growingTextViewDidChange:(UdeskHPGrowingTextView *)growingTextView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatTextViewShouldChangeText:)]) {
        [self.delegate chatTextViewShouldChangeText:growingTextView.text];
    }
    
    //机器人会话
    if (self.isRobotSession) {
        return;
    }
    
    //输入预知
    NSDate *nowDate = [NSDate date];
    NSTimeInterval time = [nowDate timeIntervalSinceDate:self.sendDate];
    if (time>0.5 && self.agent.statusType == UDAgentStatusResultOnline && ![UdeskSDKUtil isBlankString:growingTextView.text]) {
        self.sendDate = nowDate;
        [UdeskManager sendClientInputtingWithContent:growingTextView.text];
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    
    self.chatInputType = UdeskChatInputTypeText;
    
    if ([self.chatTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.chatTextView.text isEqualToString:getUDLocalizedString(@"udesk_typing")]) {
        self.chatTextView.text = @"";
        self.chatTextView.textColor = [UIColor blackColor];
    }
    
    [self resetAllButtonSelectedStatus];
    
    return YES;
}

- (void)growingTextViewDidBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView becomeFirstResponder];
}

- (void)growingTextViewDidEndEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView resignFirstResponder];
}

- (BOOL)growingTextView:(UdeskHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    self.chatInputType = UdeskChatInputTypeText;
    if ([text isEqualToString:@"\n"]) {
        //发送出去以后置空输入预知
        if ([self checkAgentStatusValid]) {
            [UdeskManager sendClientInputtingWithContent:@""];
            if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
                [self.delegate didSendText:growingTextView.text];
            }
            return NO;
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (void)growingTextView:(UdeskHPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    float diff = (self.chatTextView.frame.size.height - height);
    //确保tableView的y不大于原始的y
    CGFloat tableViewOriginY = self.messageTableView.frame.origin.y + diff;
    if (tableViewOriginY > self.originalChatViewFrame.origin.y) {
        tableViewOriginY = self.originalChatViewFrame.origin.y;
    }
    
    self.messageTableView.frame = CGRectMake(self.messageTableView.frame.origin.x, tableViewOriginY, self.messageTableView.frame.size.width, self.messageTableView.frame.size.height);
    self.frame = CGRectMake(0, self.frame.origin.y + diff, self.frame.size.width, self.frame.size.height - diff);
    //按钮靠下
    [self updateButtonBottom:-diff];
}

- (void)updateButtonBottom:(CGFloat)diff {
    
    self.emotionButton.udTop += diff;
    self.voiceButton.udTop += diff;
    self.moreButton.udTop += diff;
}

- (void)setAgent:(UdeskAgent *)agent {
    _agent = agent;
    
    if (agent.statusType == UDAgentStatusResultOnline) {
        [self resetAllButton];
    }
    else if (agent.statusType == UDAgentStatusResultOffline) {
        if (agent.sessionType == UDAgentSessionTypeNotCreate) {
            [self updateInputBarForLeaveMessage];
        }
    }
    
    [self setNeedsLayout];
}

//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage {

    self.voiceButton.hidden = YES;
    self.emotionButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.recordButton.alpha = 0;
    self.chatTextView.alpha = 1;
    self.chatInputType = UdeskChatInputTypeText;
    [self removeCustomToolbar];
}

//重置录音按钮
- (void)resetRecordButton {
    [self.recordButton setTitle:getUDLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    self.recordButton.backgroundColor = [UIColor whiteColor];
}

- (void)resetAllButtonSelectedStatus {
    self.voiceButton.selected = NO;
    self.emotionButton.selected = NO;
    self.moreButton.selected = NO;
}

//重制所有按钮
- (void)resetAllButton {
    
    UdeskSDKConfig *config = [UdeskSDKConfig customConfig];
    
    self.voiceButton.hidden = !config.isShowVoiceEntry;
    self.emotionButton.hidden = (self.voiceButton.selected == YES)?YES:(!config.isShowEmotionEntry);
    self.moreButton.hidden = NO;
    self.customButtonConfigs = [UdeskSDKConfig customConfig].customButtons;
    
    [self resetAllButtonSelectedStatus];
}

- (BOOL)checkAgentStatusValid {
    
    //网络断开
    if (self.networkDisconnect) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickChatInputToolBar)]) {
            [self.delegate didClickChatInputToolBar];
        }
        return NO;
    }
    
    //无消息对话过滤
    if (self.isPreSession) {
        return YES;
    }
    
    //机器人
    if (self.isRobotSession) {
        return YES;
    }
    
    if (!self.agent || self.agent == (id)kCFNull) return YES;
    
    //会话中可以发送 消息/离线消息/留言消息
    if (self.agent.sessionType == UDAgentSessionTypeInSession) {
        return YES;
    }
    //会话未创建
    else if (self.agent.sessionType == UDAgentSessionTypeNotCreate) {
        
        //客服离线
        if (self.agent.statusType == UDAgentStatusResultOffline) {
            //表单留言
            if (self.agent.leaveMessageType == UDAgentLeaveMessageTypeForm) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didClickChatInputToolBar)]) {
                    [self.delegate didClickChatInputToolBar];
                }
                return NO;
            }
            else {
                return YES;
            }
        }
        else {
            return YES;
        }
    }
    //会话已关闭
    else if (self.agent.sessionType == UDAgentSessionTypeHasOver) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickChatInputToolBar)]) {
            [self.delegate didClickChatInputToolBar];
        }
        return NO;
    }
    
    return YES;
}

- (void)setCustomButtonConfigs:(NSArray<UdeskCustomButtonConfig *> *)customButtonConfigs {
    if (![UdeskSDKConfig customConfig].showCustomButtons) return ;
    if (!customButtonConfigs || customButtonConfigs == (id)kCFNull) return ;
    if (![customButtonConfigs isKindOfClass:[NSArray class]]) return ;
    if (![customButtonConfigs.firstObject isKindOfClass:[UdeskCustomButtonConfig class]]) return ;
    
    //没有在输入框上方的自定义按钮
    NSArray *types = [customButtonConfigs valueForKey:@"type"];
    if (![types containsObject:@0]) return;
    
    _customButtonConfigs = customButtonConfigs;
    
    //先移除
    [self removeCustomToolbar];

    NSMutableArray *agentCustomButton = [NSMutableArray array];
    NSMutableArray *robotCustomButton = [NSMutableArray array];
    for (UdeskCustomButtonConfig *customButton in customButtonConfigs) {
        switch (customButton.scenesType) {
            case UdeskCustomButtonConfigScenesAgent:
                [agentCustomButton addObject:customButton];
                break;
            case UdeskCustomButtonConfigScenesRobot:
                [robotCustomButton addObject:customButton];
                break;
                
            default:
                break;
        }
    }
    
    NSArray *customeButtonArray = self.isRobotSession?robotCustomButton:agentCustomButton;
    if (!customeButtonArray || customeButtonArray == (id)kCFNull || !customeButtonArray.count) return ;
    
    _customToolBar = [[UdeskCustomToolBar alloc] initWithFrame:CGRectZero customButtonConfigs:customeButtonArray enableSurvey:self.enableSurvey];
    _customToolBar.delegate = self;
    [self addSubview:_customToolBar];
    
    self.frame = CGRectMake(0, self.frame.origin.y - 44, self.frame.size.width, self.frame.size.height + 44);
    [self.messageTableView setTableViewInsetsWithBottomValue:self.udHeight];
}

- (void)setIsAgentSession:(BOOL)isAgentSession {
    _isAgentSession = isAgentSession;
    
    [self resetAllButton];
    [self setNeedsLayout];
}

- (void)setIsPreSession:(BOOL)isPreSession {
    _isPreSession = isPreSession;
    
    if (isPreSession) {
        [self resetAllButton];
        [self setNeedsLayout];
    }
}

- (void)setIsRobotSession:(BOOL)isRobotSession {
    _isRobotSession = isRobotSession;
    
    if (isRobotSession) {
        [self resetAllButton];
        
        self.voiceButton.hidden = YES;
        self.emotionButton.hidden = YES;
        
#if __has_include("BDSEventManager.h")
        self.voiceButton.hidden = NO;
#endif
        
        [self setNeedsLayout];
    }
}

- (void)removeCustomToolbar {
    
    if (self.customToolBar) {
        [self.customToolBar removeFromSuperview];
        self.customToolBar = nil;
        self.frame = CGRectMake(0, self.frame.origin.y + 44, self.frame.size.width, self.frame.size.height - 44);
        [self.messageTableView setTableViewInsetsWithBottomValue:self.udHeight];
    }
}

#pragma mark - @protocol UdeskCustomToolBarDelegate
- (void)didSelectCustomToolBar:(UdeskCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    if ([self checkAgentStatusValid]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomToolBar:atIndex:)]) {
            [self.delegate didSelectCustomToolBar:toolBar atIndex:index];
        }
    }
}

- (void)didTapSurveyAction:(UdeskCustomToolBar *)toolBar {
    if ([self checkAgentStatusValid]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomToolBarSurvey:)]) {
            [self.delegate didSelectCustomToolBarSurvey:toolBar];
        }
    }
}

@end
