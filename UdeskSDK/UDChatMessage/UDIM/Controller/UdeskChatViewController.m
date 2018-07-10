
//
//  UdeskChatViewController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskChatViewController.h"
#import "UdeskTopAlertView.h"
#import "UdeskMessageTableView.h"
#import "UdeskTicketViewController.h"
#import "UdeskImagePicker.h"
#import "UIViewController+UdeskSDK.h"
#import "UIView+UdeskSDK.h"
#import "UdeskImageUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskAudioPlayer.h"
#import "UdeskManager.h"
#import "UdeskBaseCell.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskVoiceRecordView.h"
#import "UdeskBaseMessage.h"
#import "UdeskVideoCell.h"
#import "UdeskImageCell.h"
#import "UdeskChatTitleView.h"
#import "UdeskLocationViewController.h"

#import "UdeskImagePickerController.h"
#import "UdeskSmallVideoViewController.h"
#import "UdeskChatInputToolBar.h"
#import "UdeskChatToolBarMoreView.h"
#import "UdeskCustomToolBar.h"
#import "UdeskPrivacyUtil.h"
#import "UdeskVoiceRecord.h"
#import "UdeskEmojiKeyboardControl.h"
#import "UdeskSurveyView.h"
#import "UdeskSDKUtil.h"
#import "UdeskSmallVideoNavigationController.h"
#import "UdeskMessageUtil.h"

//video call
#if __has_include(<UdeskCall/UdeskCall.h>)
#import <UdeskCall/UdeskCall.h>
#import "UdeskCallInviteView.h"
#import "UdeskCallingView.h"
#endif

@interface UdeskChatViewController ()<UITableViewDelegate,UITableViewDataSource,UdeskChatViewModelDelegate,UdeskCellDelegate,UdeskImagePickerControllerDelegate,UdeskSmallVideoViewControllerDelegate,UdeskChatInputToolBarDelegate,UdeskChatToolBarMoreViewDelegate,UdeskEmojiKeyboardControlDelegate>

@property (nonatomic, strong) UdeskMessageTableView     *messageTableView;//用于显示消息的TableView
@property (nonatomic, strong) UdeskEmojiKeyboardControl *emojiKeyboard;
@property (nonatomic, strong) UdeskChatToolBarMoreView  *moreView;
@property (nonatomic, strong) UdeskChatInputToolBar     *chatInputToolBar;
@property (nonatomic, strong) UdeskChatTitleView        *titleView;//标题
@property (nonatomic, strong) UdeskVoiceRecordView      *voiceRecordView;//

@property (nonatomic, strong) UdeskImagePicker    *photographyHelper;//
@property (nonatomic, strong) UdeskVoiceRecord    *voiceRecordHelper;//

@property (nonatomic, assign) BOOL                      isMaxTimeStop;//判断是不是超出了录音最大时长
@property (nonatomic, assign) BOOL                      backAlreadyDisplayedSurvey;//返回展示满意度
@property (nonatomic, strong, readwrite) UdeskChatViewModel  *chatViewModel;

//video call
#if __has_include(<UdeskCall/UdeskCall.h>)
@property (nonatomic, strong) UdeskCallingView *callingView;
@property (nonatomic, strong) UdeskCallInviteView *callInviteView;
#endif

@end

@implementation UdeskChatViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    //初始化viewModel
    [self initViewModel];
    //初始化消息页面布局
    [self initilzer];
}

#pragma mark - 初始化viewModel
- (void)initViewModel {
    
    self.chatViewModel = [[UdeskChatViewModel alloc] initWithSDKSetting:self.sdkSetting];
    self.chatViewModel.delegate = self;
    
    @udWeakify(self);
    self.chatViewModel.updateInputBarBlock = ^{
        @udStrongify(self);
        if (self.chatInputToolBar) {
            [self.chatInputToolBar updateInputBarForLeaveMessage];
        }
    };
}

#pragma mark - UdeskChatViewModelDelegate
//刷新表
- (void)reloadChatTableView {
    
    @udWeakify(self);
    //更新消息内容
    dispatch_async(dispatch_get_main_queue(), ^{
        @udStrongify(self);
        //是否需要下拉刷新
        [self.messageTableView finishLoadingMoreMessages:self.chatViewModel.isShowRefresh];
        [self.messageTableView reloadData];
    });
}

- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self safeCellUpdate:indexPath.section row:indexPath.row];
    });
}

- (void)safeCellUpdate:(NSUInteger)section row: (NSUInteger) row {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger lastSection = [self.messageTableView numberOfSections];
        if (lastSection == 0) {
            return;
        }
        lastSection -= 1;
        if (section > lastSection) {
            return;
        }
        NSUInteger lastRowNumber = [self.messageTableView numberOfRowsInSection:section];
        if (lastRowNumber == 0) {
            return;
        }
        lastRowNumber -= 1;
        if (row > lastRowNumber) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        @try {
            if ([[self.messageTableView indexPathsForVisibleRows] indexOfObject:indexPath] == NSNotFound) {
                return;
            }
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
            return;
        }
    });
}

//接受客服状态，弹出下拉动画
- (void)didReceiveAgentPresence:(UdeskAgent *)agent {
    
    if (!agent) return;
    if (agent.code) {
        //显示top AlertView
        [UdeskTopAlertView showWithCode:agent.code withMessage:agent.message parentView:self.view];
        [self updateAgent:agent];
        if (agent.code == UDAgentConversationOver) {
            [self setupPreSessionMessageUI:NO];
            [self layoutOtherMenuViewHiden:YES];
            [self.chatInputToolBar resetAllButtonSelectedStatus];
        }
    }
}

//更新客服信息
- (void)didFetchAgentModel:(UdeskAgent *)agent {
    
    if (!agent) return;
    [self updateAgent:agent];
    //客服在线
    if (agent.code == UDAgentStatusResultOnline) {
        //自动消息
        [self sendPreMessage];
    }
}

//收到客服发送的满意度调查
- (void)didReceiveSurveyWithAgentId:(NSString *)agentId {

    [self servicesFeedbackSurveyWithAgentId:agentId];
}

//无消息会话标题
- (void)showPreSessionWithTitle:(NSString *)title {
    self.titleView.titleLabel.text = title;
    [self setupPreSessionMessageUI:YES];
}

//收到视频邀请
- (void)didReceiveInviteWithAgentModel:(UdeskAgent *)agent {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.chatInputToolBar.chatTextView resignFirstResponder];
        self.callInviteView.avatarURL = agent.avatar;
        self.callInviteView.nickName = agent.nick;
        [UIView animateWithDuration:0.35 animations:^{
            self.callInviteView.udTop = 0;
        }];
    });
#endif
    
}

- (void)updateAgent:(UdeskAgent *)agent {

    [self setupPreSessionMessageUI:NO];
    self.chatInputToolBar.agent = agent;
    [self.titleView updateTitle:agent];
}

//点击发送留言
- (void)didSelectSendTicket {

    self.chatViewModel.isNotShowAlert = YES;
    
    //如果用户实现了自定义留言界面
    if (self.sdkConfig.actionConfig.leaveMessageClickBlock) {
        self.sdkConfig.actionConfig.leaveMessageClickBlock(self);
        return;
    }
    
    UdeskTicketViewController *offLineTicket = [[UdeskTicketViewController alloc] initWithSDKConfig:self.sdkConfig setting:self.sdkSetting];
    [self presentViewController:offLineTicket animated:YES completion:nil];
}

//点击黑名单弹窗提示的确定
- (void)didSelectBlacklistedAlertViewOkButton {

    self.chatViewModel.isNotShowAlert = YES;
    [self dismissChatViewController];
}

//配置无消息对话过滤的UI
- (void)setupPreSessionMessageUI:(BOOL)isPreSessionMessage {
    
    self.chatInputToolBar.isPreSessionMessage = isPreSessionMessage;
    self.moreView.isPreSessionMessage = isPreSessionMessage;
}

//发送预知消息
- (void)sendPreMessage {
    
    //自动消息
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        for (id messageContent in self.sdkConfig.preSendMessages) {
            if ([messageContent isKindOfClass:[NSString class]]) {
                [self sendTextMessageWithContent:messageContent];
            }
            else if ([messageContent isKindOfClass:[UIImage class]]) {
                [self sendImageMessageWithImage:messageContent];
            }
        }
        self.sdkConfig.preSendMessages = nil;
    });
}

#pragma mark - 初始化视图
- (void)initilzer {
    
    //用户自己设置了标题
    if (self.sdkConfig.imTitle) {
        self.title = self.sdkConfig.imTitle;
    }
    else {
        self.navigationItem.titleView = self.titleView;
    }
    
    // 初始化message tableView
	_messageTableView = [[UdeskMessageTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    //是否需要下拉刷新
    [_messageTableView finishLoadingMoreMessages:self.chatViewModel.isShowRefresh];
    
    [self.view addSubview:_messageTableView];
    
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChatTableView:)];
    tap.cancelsTouchesInView = false;
    [_messageTableView addGestureRecognizer:tap];
    
    // 设置Message TableView 的bottom
    CGFloat inputViewHeight = 52.0f;
    // 输入工具条
    _chatInputToolBar = [[UdeskChatInputToolBar alloc] initWithFrame:CGRectMake(0.0f,self.view.udHeight - inputViewHeight - (ud_is_iPhoneX?34:0),self.view.udWidth,inputViewHeight+(ud_is_iPhoneX?34:0)) tableView:_messageTableView];
    _chatInputToolBar.delegate = self;
    [self.view addSubview:_chatInputToolBar];
    
    //配置自定义按钮
    if (self.sdkConfig.isShowCustomButtons) {
        _chatInputToolBar.enableSurvey = self.sdkSetting.enableImSurvey.boolValue;
        _chatInputToolBar.customButtonConfigs = self.sdkConfig.customButtons;
    }
    else {
        
        _messageTableView.udHeight -= ud_is_iPhoneX?34:0;
        [_messageTableView setTableViewInsetsWithBottomValue:self.view.udHeight - _chatInputToolBar.udY];
    }
    
    // 设置整体背景颜色
    [self setBackgroundColor];
}

#pragma mark - @protocol UdeskChatInputToolBarDelegate
/** 发送文本消息，包括系统的表情 */
- (void)didSendText:(NSString *)text {
    
    [self sendTextMessageWithContent:text];
}

/** 点击语音 */
- (void)didSelectVoice:(UdeskButton *)voiceButton {
    
    if (voiceButton.selected) {
        [self layoutOtherMenuViewHiden:YES];
    } else {
        [self.chatInputToolBar.chatTextView becomeFirstResponder];
    }
}
/** 点击表情 */
- (void)didSelectEmotion:(UdeskButton *)emotionButton {
    
    if (emotionButton.selected) {
        [self emojiKeyboard];
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.chatInputToolBar.chatTextView becomeFirstResponder];
    }
}
/** 点击更多 */
- (void)didSelectMore:(UdeskButton *)moreButton {
    
    if (moreButton.selected) {
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.chatInputToolBar.chatTextView becomeFirstResponder];
    }
}
/** 点击UdeskChatInputToolBar */
- (void)didClickChatInputToolBar {
    
    //根据客服code 实现相应的点击事件
    [self.chatViewModel clickInputViewShowAlertView];
}

/** 点击自定义按钮 */
- (void)didSelectCustomToolBar:(UdeskCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    [self callbackCustomButtonActionWithIndex:index];
}

/** 点击自定义评价 */
- (void)didSelectCustomToolBarSurvey:(UdeskCustomToolBar *)toolBar {
    
    [self servicesFeedbackSurveyWithAgentId:self.chatInputToolBar.agent.agentId];
}

/** 准备录音 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    
    [self.voiceRecordHelper prepareRecordingCompletion:completion];
}
/** 开始录音 */
- (void)didStartRecordingVoiceAction {
    
    [self.voiceRecordView startRecordingAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:nil];
}
/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction {
    
    @udWeakify(self);
    [self.voiceRecordView cancelRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordView = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
}
/** 松开手指完成录音 */
- (void)didFinishRecoingVoiceAction {
    
    if (self.isMaxTimeStop == NO) {
        [self finishRecorded];
    } else {
        self.isMaxTimeStop = NO;
    }
}
/** 当手指离开按钮的范围内时 */
- (void)didDragOutsideAction {
    
    [self.voiceRecordView resaueRecord];
}
/** 当手指再次进入按钮的范围内时 */
- (void)didDragInsideAction {
    
    [self.voiceRecordView pauseRecord];
}

//录音完成
- (void)finishRecorded {
    @udWeakify(self);
    [self.voiceRecordView stopRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordView = nil;
    }];
    
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        @udStrongify(self);
        [self sendVoiceMessageWithVoicePath:self.voiceRecordHelper.recordPath voiceDuration:self.voiceRecordHelper.recordDuration];
    }];
}

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatViewModel.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.chatViewModel.messagesArray.count) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ErrorMessagesArray"];
        return cell;
    }
    
    id message = self.chatViewModel.messagesArray[indexPath.row];

    NSString *messageModelName = NSStringFromClass([message class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageModelName];
    
    if (!cell) {
        
        if ([message isKindOfClass:[UdeskBaseMessage class]]) {
            cell = [(UdeskBaseMessage *)message getCellWithReuseIdentifier:messageModelName];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ErrorMessagesArray"];
        }
        
        if ([cell isKindOfClass:[UdeskBaseCell class]]) {
            UdeskBaseCell *chatCell = (UdeskBaseCell *)cell;
            chatCell.delegate = self;
        }
    }
    
    if (![cell isKindOfClass:[UdeskBaseCell class]]) {
        return cell;
    }
    
    [(UdeskBaseCell*)cell updateCellWithMessage:message];
    
    return cell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.chatViewModel.messagesArray.count) {
        return 44;
    }
    
    UdeskBaseMessage *message = self.chatViewModel.messagesArray[indexPath.row];
    if ([message isKindOfClass:[UdeskBaseMessage class]]) {
        if (message.cellHeight) {
            return message.cellHeight;
        }
        else {
            return 44;
        }
    }
    else {
        return 44;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //滑动表隐藏Menu
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }

    if (self.chatInputToolBar.chatInputType != UdeskChatInputTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
    [self.chatInputToolBar resetAllButtonSelectedStatus];
}

#pragma mark - UdeskCellDelegate
- (void)didTapChatImageView {
    [self.view endEditing:YES];
}

//发送咨询对象URL
- (void)didSendProductURL:(NSString *)url {
    if (self.sdkConfig.actionConfig.productMessageSendLinkClickBlock) {
        self.sdkConfig.actionConfig.productMessageSendLinkClickBlock(self,self.sdkConfig.productDictionary);
        return;
    }
    
    [self sendTextMessageWithContent:url];
}

//再次呼叫
- (void)didTapUdeskVideoCallMessage:(UdeskMessage *)message {
    [self startUdeskVideoCall];
}

//结构化消息
- (void)didTapStructMessageButton {

    if (self.sdkConfig.actionConfig.structMessageClickBlock) {
        self.sdkConfig.actionConfig.structMessageClickBlock();
    }
}

//点击商品消息
- (void)didTapGoodsMessageWithURL:(NSString *)goodsURL goodsId:(NSString *)goodsId {
    if (!goodsURL || goodsURL == (id)kCFNull) return ;
    if (![goodsURL isKindOfClass:[NSString class]]) return ;
    
    if (self.sdkConfig.actionConfig.goodsMessageClickBlock) {
        self.sdkConfig.actionConfig.goodsMessageClickBlock(self,goodsURL,goodsId);
    }
}

//查看地理位置
- (void)didTapLocationMessage:(UdeskMessage *)message {

    UdeskLocationModel *model = [UdeskMessageUtil locationModelWithMessage:message];
    //用户自己选择回调方式定位
    if (self.sdkConfig.actionConfig.locationMessageClickBlock) {
        self.sdkConfig.actionConfig.locationMessageClickBlock(self,model);
        return;
    }
    
    UdeskLocationViewController *location = [[UdeskLocationViewController alloc] initWithSDKConfig:self.sdkConfig hasSend:YES];
    location.locationModel = model;
    [self presentViewController:location animated:YES completion:nil];
}

//重发消息
- (void)didResendMessage:(UdeskMessage *)resendMessage {

    @udWeakify(self);
    if (self.chatInputToolBar.agent.code != UDAgentStatusResultOnline &&
        self.chatInputToolBar.agent.code != UDAgentStatusResultLeaveMessage) {
        [self.chatViewModel showAgentStatusAlert];
    }
    else {
        
        //重发
        [UdeskManager sendMessage:resendMessage progress:^(NSString *key, float percent) {
            
            //更新进度
            @udStrongify(self);
            [self updateVideoPercentButtonTitle:resendMessage.messageId progress:percent sendStatus:UDMessageSendStatusSending];
            
        } completion:^(UdeskMessage *message) {
            
            //处理发送结果UI
            @udStrongify(self);
            [self updateMessageStatus:message];
        }];
    }
}

#pragma mark - UDChatTableViewDelegate
//点击空白处隐藏键盘
- (void)didTapChatTableView:(UITableView *)tableView {
    
    [self layoutOtherMenuViewHiden:YES];
    [self.chatInputToolBar resetAllButtonSelectedStatus];
}

#pragma mark - 下拉加载更多数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    @try {
        
        if (scrollView.contentOffset.y<0 && self.messageTableView.isRefresh) {
            //开始刷新
            [self.messageTableView startLoadingMoreMessages];
            //获取更多数据
            [self.chatViewModel fetchNextPageDatebaseMessage];
            //延迟0.8，提高用户体验
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //关闭刷新、刷新数据
                [self.messageTableView finishLoadingMoreMessages:self.chatViewModel.isShowRefresh];
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - video
#if __has_include(<UdeskCall/UdeskCall.h>)
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
            [self.chatViewModel stopPlayVideoCallRing];
        };
    }
    return _callInviteView;
}
#endif

#pragma mark - title
- (UdeskChatTitleView *)titleView {

    if (!_titleView) {
        CGFloat titleViewWidth = UD_SCREEN_WIDTH>320?210:175;
        _titleView = [[UdeskChatTitleView alloc] initWithFrame:CGRectMake(0, 0, titleViewWidth, 44)];
    }
    return _titleView;
}

#pragma mark - 表情view
- (UdeskEmojiKeyboardControl *)emojiKeyboard {
    if (!_emojiKeyboard) {
        _emojiKeyboard = [[UdeskEmojiKeyboardControl alloc] init];
        _emojiKeyboard.delegate = self;
        _emojiKeyboard.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        _emojiKeyboard.alpha = 0.0;
        [self.view addSubview:_emojiKeyboard];
    }
    return _emojiKeyboard;
}

#pragma mark - 更多
- (UdeskChatToolBarMoreView *)moreView {
    
    if (!_moreView) {
        _moreView = [[UdeskChatToolBarMoreView alloc] initWithEnableSurvey:self.sdkSetting.enableImSurvey.boolValue enableVideoCall:self.sdkSetting.sdkVCall.boolValue];
        _moreView.customMenuItems = self.sdkConfig.customButtons;
        _moreView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        _moreView.alpha = 0.0;
        _moreView.delegate = self;
        [self.view addSubview:_moreView];
    }
    return _moreView;
}

#pragma mark - 图片选择器
- (UdeskImagePicker *)photographyHelper {
    
    if (!_photographyHelper) {
        _photographyHelper = [[UdeskImagePicker alloc] init];
    }
    return _photographyHelper;
}

#pragma mark - 录音动画view
- (UdeskVoiceRecordView *)voiceRecordView {
    if (!_voiceRecordView) {
        _voiceRecordView = [[UdeskVoiceRecordView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    }
    return _voiceRecordView;
}

- (UdeskVoiceRecord *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        @udWeakify(self);
        _voiceRecordHelper = [[UdeskVoiceRecord alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            @udStrongify(self);
            self.isMaxTimeStop = YES;
            [self.chatInputToolBar resetRecordButton];
            [self finishRecorded];
        };
        
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            @udStrongify(self);
            self.voiceRecordView.peakPower = peakPowerForChannel;
        };
        
        _voiceRecordHelper.tooShortRecorderFailue = ^{
            @udStrongify(self);
            [self.voiceRecordView speakDurationTooShort];
        };
        
        _voiceRecordHelper.maxRecordTime = kUdeskVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

#pragma mark - 显示功能面板
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    //根据textViewInputViewType切换功能面板
    [self.chatInputToolBar.chatTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.chatInputToolBar.frame;
        __block CGRect otherMenuViewFrame = CGRectMake(0, 0, 0, 0);
        
        CGFloat spacing = 0;
        if (ud_is_iPhoneX) {
            spacing = 34;
        }
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)) + spacing);
            self.chatInputToolBar.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emojiKeyboard.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.emojiKeyboard.alpha = !hide;
            self.emojiKeyboard.frame = otherMenuViewFrame;
        };
        
        void (^MoreViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.moreView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.moreView.alpha = !hide;
            self.moreView.frame = otherMenuViewFrame;
        };
        
        if (hide) {
            switch (self.chatInputToolBar.chatInputType) {
                case UdeskChatInputTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UdeskChatInputTypeText: {
                    EmotionManagerViewAnimation(hide);
                    MoreViewAnimation(hide);
                    break;
                }
                case UdeskChatInputTypeMore: {
                    MoreViewAnimation(hide);
                    break;
                }
                case UdeskChatInputTypeVoice: {
                    EmotionManagerViewAnimation(hide);
                    MoreViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            

            switch (self.chatInputToolBar.chatInputType) {
                case UdeskChatInputTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    MoreViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UdeskChatInputTypeVoice: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    MoreViewAnimation(!hide);
                    break;
                }
                case UdeskChatInputTypeText: {
                    EmotionManagerViewAnimation(!hide);
                    MoreViewAnimation(!hide);
                    break;
                }
                case UdeskChatInputTypeMore: {
                    EmotionManagerViewAnimation(!hide);
                    MoreViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [self.messageTableView setTableViewInsetsWithBottomValue:self.view.frame.size.height
         - self.chatInputToolBar.frame.origin.y];
        [self.messageTableView scrollToBottomAnimated:NO];
        
    } completion:^(BOOL finished) {
        
        if (hide) {
            self.chatInputToolBar.chatInputType = UdeskChatInputTypeNormal;
        }
    }];

}

#pragma mark - 发送文字
- (void)sendTextMessageWithContent:(NSString *)content {
    if (!content || content == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendTextMessage:content completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
    
    [self.chatInputToolBar.chatTextView setText:nil];
}

#pragma mark - 发送图片
- (void)sendImageMessageWithImage:(UIImage *)image {
    if (!image || image == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendImageMessage:image progress:^(NSString *key,float progress){
        
        //更新进度
        @udStrongify(self);
        [self updateImageUploadProgress:progress messageId:key sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
        //更新进度
        [self updateImageUploadProgress:message.messageStatus == UDMessageSendStatusSuccess?1:0
                              messageId:message.messageId
                             sendStatus:message.messageStatus];
    }];
}

//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData {
    if (!gifData || gifData == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendGIFImageMessage:gifData progress:^(NSString *key,float progress){
        
        //更新进度
        @udStrongify(self);
        [self updateImageUploadProgress:progress messageId:key sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
        //更新进度
        [self updateImageUploadProgress:message.messageStatus == UDMessageSendStatusSuccess?1:0
                              messageId:message.messageId
                             sendStatus:message.messageStatus];
    }];
}

//更新视频上传进度
- (void)updateImageUploadProgress:(float)progress
                        messageId:(NSString *)messageId
                       sendStatus:(UDMessageSendStatus)sendStatus {
    
    @try {
        
        NSArray *array = [self.chatViewModel.messagesArray valueForKey:@"messageId"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[array indexOfObject:messageId] inSection:0];
        UdeskImageCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[UdeskImageCell class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (progress == 1.0f || sendStatus == UDMessageSendStatusSuccess) {
                    [cell uploadImageSuccess];
                }
                else {
                    [cell imageUploading];
                    cell.progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                }
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 发送视频
- (void)sendVideoMessageWithVideoFile:(NSString *)videoFile {
    if (!videoFile || videoFile == (id)kCFNull) return ;
    if (![videoFile isKindOfClass:[NSString class]]) return ;
    
    NSData *videoData = [NSData dataWithContentsOfFile:videoFile];
    if (!videoData || videoData == (id)kCFNull) {
        videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoFile]];
    }

    if (!videoData || videoData == (id)kCFNull) return ;
    if (![videoData isKindOfClass:[NSData class]]) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendVideoMessage:videoData progress:^(NSString *key,float progress){
    
        //更新进度
        @udStrongify(self);
        [self updateVideoPercentButtonTitle:key progress:progress sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
        //更新进度
        [self updateVideoPercentButtonTitle:message.messageId
                                   progress:message.messageStatus == UDMessageSendStatusSuccess?1:0
                                 sendStatus:message.messageStatus];
    }];
}

//更新视频上传进度
- (void)updateVideoPercentButtonTitle:(NSString *)messageId
                             progress:(float)progress
                           sendStatus:(UDMessageSendStatus)sendStatus {

    @try {
        
        NSArray *array = [self.chatViewModel.messagesArray valueForKey:@"messageId"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[array indexOfObject:messageId] inSection:0];
        UdeskVideoCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
        [cell updateMessageSendStatus:UDMessageSendStatusSending];
        
        if ([cell isKindOfClass:[UdeskVideoCell class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (progress == 1.0f || sendStatus == UDMessageSendStatusSuccess) {
                    cell.uploadProgressLabel.hidden = YES;
                    cell.playButton.hidden = NO;
                    [cell updateMessageSendStatus:UDMessageSendStatusSuccess];
                }
                else {
                    cell.uploadProgressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                }
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 发送语音
- (void)sendVoiceMessageWithVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration {
    if (!voicePath || voicePath == (id)kCFNull) return ;
    if (!voiceDuration || voiceDuration == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendVoiceMessage:voicePath voiceDuration:voiceDuration completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
}

#pragma mark - 发送位置信息
- (void)sendLoactionMessageWithModel:(UdeskLocationModel *)locationModel {
    if (!locationModel || locationModel == (id)kCFNull) return ;
    
    [self.chatViewModel sendLocationMessage:locationModel completion:^(UdeskMessage *message) {
        //处理发送结果UI
        [self updateMessageStatus:message];
    }];
}

#pragma mark - 发送商品信息
- (void)sendGoodsMessageWithModel:(UdeskGoodsModel *)goodsModel {
    if (!goodsModel || goodsModel == (id)kCFNull) return ;
    
    [self.chatViewModel sendGoodsMessage:goodsModel completion:^(UdeskMessage *message) {
        //处理发送结果UI
        [self updateMessageStatus:message];
    }];
}

//根据发送状态更新UI
- (void)updateMessageStatus:(UdeskMessage *)message {
    if (!message || message == (id)kCFNull) return ;
    
    switch (message.messageStatus) {
        case UDMessageSendStatusSuccess:
            
            //更新UI
            [self updateChatMessageUI:message];
            break;
        case UDMessageSendStatusFailed:
        case UDMessageSendStatusOffSending:
            
            if (self.chatInputToolBar.agent.code == UDAgentStatusResultLeaveMessage) {
                [self updateChatMessageUI:message];
                break;
            }
            
            //开启重发
            [self beginResendMessage:message];
            
            break;
            
        default:
            break;
    }
}

//根据发送状态更新UI
- (void)updateChatMessageUI:(UdeskMessage *)message {
    
    @try {
        
        NSArray *messageArray = self.chatViewModel.messagesArray;
        
        for (UdeskBaseMessage *baseMessage in messageArray) {
            if (![baseMessage isKindOfClass:[UdeskBaseMessage class]]) return ;
            
            if ([baseMessage.message.messageId isEqualToString:message.messageId]) {
                
                baseMessage.message.messageStatus = message.messageStatus;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.chatViewModel.messagesArray indexOfObject:baseMessage] inSection:0];
                
                UdeskBaseCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
                [cell updateMessageSendStatus:baseMessage.message.messageStatus];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//开始重发
- (void)beginResendMessage:(UdeskMessage *)message {
    
    [self.chatViewModel addResendMessageToArray:message];
    //开启重发
    @udWeakify(self);
    [self.chatViewModel resendFailedMessageWithProgress:^(NSString *key, float percent) {
        
        //更新进度
        @udStrongify(self);
        [self updateVideoPercentButtonTitle:key progress:percent sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *failedMessage) {
        
        //发送成功删除失败消息数组里的消息
        @udStrongify(self);
        if (failedMessage.messageStatus == UDMessageSendStatusSuccess) {
            [self.chatViewModel removeResendMessageInArray:failedMessage];
        }
        //根据发送状态更新UI
        [self updateChatMessageUI:message];
        if (failedMessage.messageType == UDMessageContentTypeVideo) {
            //更新进度
            [self updateVideoPercentButtonTitle:message.messageId
                                       progress:failedMessage.messageStatus == UDMessageSendStatusSuccess?1:0
                                     sendStatus:failedMessage.messageStatus];
        }
    }];
}

#pragma mark - @protocol UdeskEmojiKeyboardControlDelegate
- (void)emojiViewDidPressEmojiWithResource:(NSString *)resource {
    if (!resource || resource == (id)kCFNull) return ;
    
    if ([self.chatInputToolBar.chatTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.chatInputToolBar.chatTextView.text isEqualToString:getUDLocalizedString(@"udesk_typing")]) {
        self.chatInputToolBar.chatTextView.text = nil;
        self.chatInputToolBar.chatTextView.textColor = [UIColor blackColor];
    }
    self.chatInputToolBar.chatTextView.text = [self.chatInputToolBar.chatTextView.text stringByAppendingString:resource];
}

- (void)emojiViewDidPressStickerWithResource:(NSString *)resource {
    if (!resource || resource == (id)kCFNull) return ;
    
    [self sendGIFMessageWithGIFData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:resource]]];
}

- (void)emojiViewDidPressDelete {
    
    if (self.chatInputToolBar.chatTextView.text.length > 0) {
        NSRange lastRange = [self.chatInputToolBar.chatTextView.text rangeOfComposedCharacterSequenceAtIndex:self.chatInputToolBar.chatTextView.text.length-1];
        self.chatInputToolBar.chatTextView.text = [self.chatInputToolBar.chatTextView.text substringToIndex:lastRange.location];
    }
}

- (void)emojiViewDidPressSend {
    
    [self sendTextMessageWithContent:self.chatInputToolBar.chatTextView.text];
}

#pragma mark - UdeskChatToolBarMoreViewDelegate
//点击默认的按钮
- (void)didSelectMoreMenuItem:(UdeskChatToolBarMoreView *)moreMenuItem itemType:(UdeskChatToolBarMoreType)itemType {
    
    switch (itemType) {
        case UdeskChatToolBarMoreTypeAlubm:
            
            //打开相册
            [self openCustomerAlubm];
            break;
        case UdeskChatToolBarMoreTypeCamera:
            
            //打开相机
            [self openCustomerCamera];
            break;
        case UdeskChatToolBarMoreTypeSurvey:
            
            //评价
            [self servicesFeedbackSurveyWithAgentId:self.chatInputToolBar.agent.agentId];
            break;
        case UdeskChatToolBarMoreTypeLocation:
            
            //开始定位
            [self startUdeskLocation];
            break;
        case UdeskChatToolBarMoreTypeVideoCall:
            
            //开始视频
            [self startUdeskVideoCall];
            break;
            
        default:
            break;
    }
}

//点击自定义的按钮
- (void)didSelectCustomMoreMenuItem:(UdeskChatToolBarMoreView *)moreMenuItem atIndex:(NSInteger)index {
    
    [self callbackCustomButtonActionWithIndex:index];
}

//回调
- (void)callbackCustomButtonActionWithIndex:(NSInteger)index {
    
    NSArray *customButtons = self.sdkConfig.customButtons;
    if (index >= customButtons.count) return;
    
    UdeskCustomButtonConfig *customButton = customButtons[index];
    if (customButton.clickBlock) {
        customButton.clickBlock(customButton,self);
    }
}

//开始视频
- (void)startUdeskVideoCall {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self.chatInputToolBar.chatTextView resignFirstResponder];
    [self callingView];
    //邀请
    [[UdeskCallSessionManager sharedManager] inviteVideo];
    [UIView animateWithDuration:0.35 animations:^{
        self.callingView.udTop = 0;
    }];
#endif
}

//开始定位
- (void)startUdeskLocation {
    
    //用户自己选择回调方式定位
    if (self.sdkConfig.actionConfig.locationButtonClickBlock) {
        self.sdkConfig.actionConfig.locationButtonClickBlock(self);
        return;
    }
    
    UdeskLocationViewController *location = [[UdeskLocationViewController alloc] initWithSDKConfig:self.sdkConfig hasSend:NO];
    [self presentViewController:location animated:YES completion:nil];
    @udWeakify(self);
    location.sendLocationBlock = ^(UdeskLocationModel *model) {
        
        @udStrongify(self);
        [self sendLoactionMessageWithModel:model];
    };
}

//评价客服
- (void)servicesFeedbackSurveyWithAgentId:(NSString *)agentId {
    
    [UdeskManager checkHasSurveyWithAgentId:agentId completion:^(NSString *hasSurvey, NSError *error) {
        if ([hasSurvey boolValue]) {
            [UdeskTopAlertView showAlertType:UDAlertTypeOrange withMessage:getUDLocalizedString(@"udesk_has_survey") parentView:self.view];
        }
        else {
            UdeskSurveyView *surveyView = [[UdeskSurveyView alloc] initWithAgentId:agentId imSubSessionId:[NSString stringWithFormat:@"%ld",self.chatInputToolBar.agent.imSubSessionId]];
            [surveyView show];
        }
    }];
}

//开启用户相册
- (void)openCustomerAlubm {
    
    [UdeskPrivacyUtil checkPermissionsOfAlbum:^{
        
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        if (ud_isIOS8 && sdkConfig.isImagePickerEnabled) {
            
            UdeskImagePickerController *imagePicker = [[UdeskImagePickerController alloc] init];
            imagePicker.maxImagesCount = sdkConfig.maxImagesCount;
            imagePicker.allowPickingVideo = sdkConfig.allowPickingVideo;
            imagePicker.quality = sdkConfig.quality;
            imagePicker.pickerDelegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            return;
        }
        
        [self sendImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
}

#pragma mark - @protocol UdeskImagePickerControllerDelegate
// 如果选择发送了图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos {
    
    for (UIImage *image in photos) {
        [self sendImageMessageWithImage:image];
    }
}

// 如果选择发送了视频，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingVideos:(NSArray<NSString *> *)videoPaths {
    
    for (NSString *path in videoPaths) {
        [self sendVideoMessageWithVideoFile:path];
    }
}

// 如果选择发送了gif图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingGIFImages:(NSArray<NSData *> *)gifImages {
    
    for (NSData *data in gifImages) {
        [self sendGIFMessageWithGIFData:data];
    }
}

//开启用户相机
- (void)openCustomerCamera {
    
    //检查权限
    [UdeskPrivacyUtil checkPermissionsOfCamera:^{
        
        if ([UdeskSDKConfig customConfig].smallVideoEnabled && ud_isIOS8) {
            
            if ([[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskSmallVideoViewController class]]) {
                return ;
            }
            
            [UdeskPrivacyUtil checkPermissionsOfAudio:^{
                
                UdeskSmallVideoViewController *smallVideoVC = [[UdeskSmallVideoViewController alloc] init];
                smallVideoVC.delegate = self;
                
                UdeskSmallVideoNavigationController *nav = [[UdeskSmallVideoNavigationController alloc] initWithRootViewController:smallVideoVC];
                [self presentViewController:nav animated:YES completion:nil];
            }];
            
            return;
        }
        
        [self sendImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
}

#pragma mark - @protocol UdeskSmallVideoViewControllerDelegate
//拍摄视频
- (void)didFinishRecordSmallVideo:(NSDictionary *)videoInfo {
    
    if (![videoInfo.allKeys containsObject:@"videoURL"]) {
        return;
    }
    NSString *url = videoInfo[@"videoURL"];
    [self sendVideoMessageWithVideoFile:url];
}

//拍摄图片
- (void)didFinishCaptureImage:(UIImage *)image {
    
    [self sendImageMessageWithImage:image];
}

//ios8以下的选择图片和拍照方式
- (void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    //打开图片选择器
    void (^PickerMediaBlock)(UIImage *image) = ^(UIImage *image) {
        if (image) {
            [self sendImageMessageWithImage:[UdeskImageUtil fixOrientation:image]];
        }
    };
    
    //打开图片选择器(gif)
    void (^PickerMediaGIFBlock)(NSData *gifData) = ^(NSData *gifData) {
        if (gifData) {
            [self sendGIFMessageWithGIFData:gifData];
        }
    };
    
    //打开视频选择器
    void (^PickerMediaVideoBlock)(NSString *filePath,NSString *videoName) = ^(NSString *filePath,NSString *videoName) {
        if (filePath) {
            [self sendVideoMessageWithVideoFile:filePath];
        }
    };
    
    [self.photographyHelper showImagePickerControllerSourceType:sourceType
                                               onViewController:self
                                                        compled:PickerMediaBlock
                                                     compledGif:PickerMediaGIFBlock
                                                   compledVideo:PickerMediaVideoBlock];
}

//点击返回
- (void)dismissChatViewController {
    
    //隐藏键盘
    [self.chatInputToolBar.chatTextView resignFirstResponder];
    if (self.sdkSetting) {
        [self checkInvestigationWhenLeave];
    }
    else {
        [self dismissViewController];
    }
}

//检查是否设置返回弹出满意度评价
- (void)checkInvestigationWhenLeave {
    
    //无消息对话过滤不显示满意度评价
    if (self.chatViewModel.preSessionId) {
        [self dismissViewController];
        return;
    }
    
    //后台开启了满意度调查
    if (!self.sdkSetting.enableImSurvey.boolValue) {
        [self dismissViewController];
        return;
    }
    
    //是否开启返回弹出满意度调查
    if (!self.sdkSetting.investigationWhenLeave.boolValue) {
        [self dismissViewController];
        return;
    }
    
    //有客服ID才弹出评价
    if (!self.chatInputToolBar.agent.agentId) {
        [self dismissViewController];
        return;
    }
    
    //已提示过满意度调查
    if (self.backAlreadyDisplayedSurvey) {
        [self dismissViewController];
        return;
    }
    
    //检查是否已经评价
    [UdeskManager checkHasSurveyWithAgentId:self.chatInputToolBar.agent.agentId completion:^(NSString *hasSurvey, NSError *error) {
        
        //失败
        if (error) {
            [self dismissViewController];
            return ;
        }
        //还未评价
        if (![hasSurvey boolValue]) {
            //标记满意度只显示一次
            self.backAlreadyDisplayedSurvey = YES;
            [self servicesFeedbackSurveyWithAgentId:self.chatInputToolBar.agent.agentId];
        }
        else {
            [self dismissViewController];
        }
    }];
}

- (void)dismissViewController {
    
    //离开页面
    [self leaveChatViewController];
    if (self.sdkConfig.presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:self.sdkConfig.presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)leaveChatViewController {
    
    if (self.sdkConfig) {
        if (self.sdkConfig.actionConfig.leaveChatViewControllerBlock) {
            self.sdkConfig.actionConfig.leaveChatViewControllerBlock();
        }
    }
}

#pragma mark - 设置背景颜色
- (void)setBackgroundColor {
    
    self.view.backgroundColor = self.sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
    self.messageTableView.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
}

#pragma mark - 监听键盘通知做出相应的操作
- (void)subscribeToKeyboard {

    @udWeakify(self);
    [self udSubscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {

        @try {
            
            @udStrongify(self);
            if (self.chatInputToolBar.chatInputType == UdeskChatInputTypeText) {
                //计算键盘的Y
                CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                CGRect inputViewFrame = self.chatInputToolBar.frame;
                //底部功能栏需要的Y
                CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height + (ud_is_iPhoneX?34:0);
                //tableview的bottom
                CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
                if (inputViewFrameY > messageViewFrameBottom)
                    inputViewFrameY = messageViewFrameBottom;
                //改变底部功能栏frame
                self.chatInputToolBar.frame = CGRectMake(inputViewFrame.origin.x,
                                                 inputViewFrameY,
                                                 inputViewFrame.size.width,
                                                 inputViewFrame.size.height);
                
                //改变tableview frame
                [self.messageTableView setTableViewInsetsWithBottomValue:self.view.frame.size.height
                 - self.chatInputToolBar.frame.origin.y];
                
                if (isShowing) {
                    [self.messageTableView scrollToBottomAnimated:NO];
                    self.emojiKeyboard.alpha = 0.0;
                    self.moreView.alpha = 0.0;
                } else {
                    
                    [self.chatInputToolBar.chatTextView resignFirstResponder];
                }
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }

    } completion:nil];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat spacing = ud_is_iPhoneX?34:0;
    
    CGFloat moreViewY = CGRectGetHeight(self.view.bounds);
    if (self.chatInputToolBar.chatInputType == UdeskChatInputTypeMore) {
        moreViewY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.moreView.frame);
    }
    self.moreView.frame = CGRectMake(0, moreViewY, CGRectGetWidth(self.view.bounds), 230 + spacing);
    
    CGFloat emotionViewY = CGRectGetHeight(self.view.bounds);
    if (self.chatInputToolBar.chatInputType == UdeskChatInputTypeEmotion) {
        emotionViewY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.emojiKeyboard.frame);
    }
    self.emojiKeyboard.frame = CGRectMake(0, emotionViewY, CGRectGetWidth(self.view.bounds), 230 + spacing);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //监听键盘
    [self subscribeToKeyboard];
    //设置客户在线
    [UdeskManager enterTheSDKPage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // remove键盘通知或者手势
    [self udUnsubscribeKeyboard];
    // 停止播放语音
    [[UdeskAudioPlayer shared] stopAudio];
    
    self.chatViewModel.isNotShowAlert = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //离开页面放弃排队
    if (self.chatInputToolBar.agent.code == UDAgentStatusResultQueue) {
        [UdeskManager quitQueueWithType:[self.sdkConfig quitQueueString]];
    }
    //取消所有请求
    [UdeskManager cancelAllOperations];
}

- (void)dealloc {
    
    NSLog(@"UdeskSDK：%@释放了",[self class]);
    _messageTableView.delegate = nil;
    _messageTableView.dataSource = nil;
}

@end
