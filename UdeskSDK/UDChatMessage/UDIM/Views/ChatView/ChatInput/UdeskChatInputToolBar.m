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
#import "UdeskCustomToolBar.h"
#import "UdeskMessageTableView.h"
#import "UdeskSDKMacro.h"

/** 按钮大小 */
static CGFloat const kInputToolBarIconDiameter = 28.0;
/** 输入框距垂直距离 */
static CGFloat const kChatTextViewToVerticalEdgeSpacing = 8.0;
/** 输入框距的横行距离 */
static CGFloat const kChatTextViewToHorizontalEdgeSpacing = 8.0;
/** 输入框功能按钮横行的间距 */
static CGFloat const kInputToolBarIconToHorizontalEdgeSpacing = 10.0;
/** 输入框按钮距离顶部的垂直距离 */
static CGFloat const kInputToolBarIconToVerticalEdgeSpacing = 12.0;

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
    self.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.inputViewColor;
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    
    //默认toolbar
    _defaultToolBar = [[UIView alloc] init];
    _defaultToolBar.backgroundColor = [UIColor whiteColor];
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
    _chatTextView.font = [UIFont systemFontOfSize:16];
    _chatTextView.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.textViewColor;
    [_defaultToolBar addSubview:_chatTextView];
    UDViewBorderRadius(_chatTextView, 5, 0.5, [UIColor colorWithRed:0.831f  green:0.835f  blue:0.843f alpha:1]);
    
    _recordButton = [[UdeskButton alloc] init];
    _recordButton.alpha = _voiceButton.selected;
    _recordButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_recordButton setTitleColor:[UIColor colorWithRed:0.392f  green:0.392f  blue:0.396f alpha:1] forState:UIControlStateNormal];
    [_recordButton setTitle:getUDLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(holdDownDragOutside:) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(holdDownDragInside:) forControlEvents:UIControlEventTouchDragEnter];
    [_defaultToolBar addSubview:_recordButton];
    UDViewBorderRadius(_recordButton, 5, 0.5, [UIColor colorWithRed:0.831f  green:0.835f  blue:0.843f alpha:1]);
    
    //表情
    _emotionButton = [[UdeskButton alloc] init];
    _emotionButton.hidden = !sdkConfig.isShowEmotionEntry;
    [_emotionButton setImage:[UIImage udDefaultSmileImage] forState:UIControlStateNormal];
    [_emotionButton setImage:[UIImage udDefaultKeyboardImage] forState:UIControlStateSelected];
    [_emotionButton addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
    if (sdkConfig.isShowEmotionEntry) {
        [_defaultToolBar addSubview:_emotionButton];
    }
    
    //更多
    _moreButton = [[UdeskButton alloc] init];
    [_moreButton setImage:[UIImage udDefaultMoreImage] forState:UIControlStateNormal];
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
    
    if (sdkConfig.isShowEmotionEntry && !_emotionButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    if (!_moreButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    //当textview height发生改变时button位置不改变
    if (_defaultToolBar.udHeight <= 52) {
     
        if (sdkConfig.isShowVoiceEntry && !_voiceButton.hidden) {
            _voiceButton.frame = CGRectMake(kInputToolBarIconToHorizontalEdgeSpacing, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
        
        if (!_moreButton.hidden) {
            _moreButton.frame = CGRectMake(_defaultToolBar.udRight-kInputToolBarIconToHorizontalEdgeSpacing-kInputToolBarIconDiameter, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
        
        if (sdkConfig.isShowEmotionEntry && !_emotionButton.hidden) {
            _emotionButton.frame = CGRectMake(_moreButton.udLeft - kInputToolBarIconToHorizontalEdgeSpacing - kInputToolBarIconDiameter, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
    }
    
    _chatTextView.frame = CGRectMake((_voiceButton.hidden?0:_voiceButton.udRight) + kChatTextViewToHorizontalEdgeSpacing, kChatTextViewToVerticalEdgeSpacing, textViewWidth, _defaultToolBar.udHeight - kChatTextViewToVerticalEdgeSpacing - kChatTextViewToHorizontalEdgeSpacing);
    _recordButton.frame = _chatTextView.frame;
}

//点击语音
- (void)voiceClick:(UdeskButton *)button {
    
    [UdeskPrivacyUtil checkPermissionsOfMicrophone:^{
        if ([self checkAgentStatusValid]) {
            button.selected = !button.selected;
            self.chatInputType = UdeskChatInputTypeVoice;
            self.emotionButton.selected = NO;
            self.moreButton.selected = NO;
            self.recordButton.alpha = button.selected;
            self.chatTextView.alpha = !button.selected;
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
        self.emotionButton.selected = NO;
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
    
    //输入预知
    NSDate *nowDate = [NSDate date];
    NSTimeInterval time = [nowDate timeIntervalSinceDate:self.sendDate];
    if (time>0.5 && self.agent.code == UDAgentStatusResultOnline && ![UdeskSDKUtil isBlankString:growingTextView.text]) {
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
    
    self.emotionButton.selected = NO;
    self.voiceButton.selected = NO;
    
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
    
    if (agent.code == UDAgentStatusResultOnline) {
        [self resetAllButton];
    }
    else if(agent.code == UDAgentStatusResultLeaveMessage) {
        [self updateInputBarForLeaveMessage];
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
    
    if (self.customToolBar) {
        self.customToolBar.hidden = YES;
        self.frame = CGRectMake(0, self.frame.origin.y + 44, self.frame.size.width, self.frame.size.height - 44);
        [self.messageTableView setTableViewInsetsWithBottomValue:self.udHeight];
    }
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
    
    if (self.customToolBar && self.customToolBar.hidden) {
        self.customToolBar.hidden = NO;
        self.frame = CGRectMake(0, self.frame.origin.y - 44, self.frame.size.width, self.frame.size.height + 44);
        [self.messageTableView setTableViewInsetsWithBottomValue:self.udHeight];
    }
}

- (BOOL)checkAgentStatusValid {
    
    //无消息对话过滤
    if (self.isPreSessionMessage) {
        return YES;
    }
    
    if (self.agent.code == UDAgentStatusResultQueue) {
        return YES;
    }
    
    if (!self.agent || self.agent == (id)kCFNull) return YES;
    
    if (self.agent.code != UDAgentStatusResultOnline &&
        self.agent.code != UDAgentStatusResultLeaveMessage) {
        
        if ([self.delegate respondsToSelector:@selector(didClickChatInputToolBar)]) {
            [self.delegate didClickChatInputToolBar];
        }
        return NO;
    }
    
    return YES;
}

- (void)setCustomButtonConfigs:(NSArray<UdeskCustomButtonConfig *> *)customButtonConfigs {
    if (!customButtonConfigs || customButtonConfigs == (id)kCFNull) return ;
    if (![customButtonConfigs isKindOfClass:[NSArray class]]) return ;
    if (![customButtonConfigs.firstObject isKindOfClass:[UdeskCustomButtonConfig class]]) return ;
    
    //没有在输入框上方的自定义按钮
    NSArray *types = [customButtonConfigs valueForKey:@"type"];
    if (![types containsObject:@0]) return;
    
    _customButtonConfigs = customButtonConfigs;
    
    _customToolBar = [[UdeskCustomToolBar alloc] initWithFrame:CGRectZero customButtonConfigs:customButtonConfigs enableSurvey:self.enableSurvey];
    _customToolBar.delegate = self;
    [self addSubview:_customToolBar];
    
    self.frame = CGRectMake(0, self.frame.origin.y - 44, self.frame.size.width, self.frame.size.height + 44);
    [self.messageTableView setTableViewInsetsWithBottomValue:self.udHeight];
}

- (void)setIsPreSessionMessage:(BOOL)isPreSessionMessage {
    _isPreSessionMessage = isPreSessionMessage;
    
    if (isPreSessionMessage) {
        if (self.customToolBar) {
            [self.customToolBar removeFromSuperview];
            self.customToolBar = nil;
            self.frame = CGRectMake(0, self.frame.origin.y + 44, self.frame.size.width, self.frame.size.height - 44);
            [self.messageTableView setTableViewInsetsWithBottomValue:self.udHeight];
        }
    }
    else {
        if (!self.customToolBar) {
            self.customButtonConfigs = self.customButtonConfigs;
        }
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
