
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
#import "UdeskEmotionManagerView.h"
#import "UdeskVoiceRecordHUD.h"
#import "UdeskPhotographyHelper.h"
#import "UIViewController+UdeskKeyboardAnimation.h"
#import "UdeskViewExt.h"
#import "UdeskUtils.h"
#import "UdeskAudioPlayerHelper.h"
#import "UdeskManager.h"
#import "UdeskBaseCell.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskInputBar.h"
#import "UdeskVoiceRecordView.h"
#import "UdeskSDKShow.h"
#import "UdeskBaseMessage.h"
#import "UdeskSDKManager.h"
#import "UdeskVideoCell.h"
#import "UdeskAgentSurvey.h"
#import "UdeskChatTitleView.h"
#import "UdeskLocationViewController.h"

//video call
#if __has_include(<UdeskCall/UdeskCall.h>)
#import <UdeskCall/UdeskCall.h>
#import "UdeskCallInviteView.h"
#import "UdeskCallingView.h"
#endif

@interface UdeskChatViewController ()<UIGestureRecognizerDelegate,UDEmotionManagerViewDelegate,UITableViewDelegate,UITableViewDataSource,UdeskChatViewModelDelegate,UdeskInputBarDelegate,UdeskVoiceRecordViewDelegate,UdeskCellDelegate>

@property (nonatomic, assign) UDInputViewType           textViewInputViewType;//输入消息类型
@property (nonatomic, assign) BOOL                      isMaxTimeStop;//判断是不是超出了录音最大时长
@property (nonatomic, strong) UdeskMessageTableView     *messageTableView;//用于显示消息的TableView
@property (nonatomic, strong) UdeskEmotionManagerView   *emotionManagerView;//管理表情的控件
@property (nonatomic, strong) UdeskVoiceRecordHUD       *voiceRecordHUD;//语音录制动画
@property (nonatomic, strong) UdeskPhotographyHelper    *photographyHelper;//管理本机的摄像和图片库的工具对象
@property (nonatomic, strong) UdeskVoiceRecordView      *voiceRecordView;//管理本机的摄像和图片库的工具对象
@property (nonatomic, strong) UdeskInputBar     *inputBar;//用于显示发送消息类型控制的工具条，在底部
@property (nonatomic, strong) UdeskChatTitleView *titleView;//标题
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
    
    self.chatViewModel = [[UdeskChatViewModel alloc] init];
    self.chatViewModel.delegate = self;
    [self.chatViewModel initCustomerWithSDKSetting:self.sdkSetting];
    
    @udWeakify(self);
    self.chatViewModel.updateInputBarBlock = ^{
        @udStrongify(self);
        if (self.inputBar) {
            [self.inputBar updateInputBarForLeaveMessage];
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
    }
}

//更新客服信息
- (void)didFetchAgentModel:(UdeskAgent *)agent {
    
    if (!agent) return;
    [self updateAgent:agent];
}

- (void)didSurveyCompletion:(NSString *)message {

    [UdeskTopAlertView showAlertType:UDAlertTypeGreen withMessage:message parentView:self.view];
}

//收到视频邀请
- (void)didReceiveInviteWithAgentModel:(UdeskAgent *)agent {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.inputBar.inputTextView resignFirstResponder];
        self.callInviteView.avatarURL = agent.avatar;
        self.callInviteView.nickName = agent.nick;
        [UIView animateWithDuration:0.35 animations:^{
            self.callInviteView.ud_top = 0;
        }];
    });
#endif
    
}

- (void)updateAgent:(UdeskAgent *)agent {

    self.inputBar.agent = agent;
    [self.titleView updateTitle:agent];
}

//点击发送留言
- (void)didSelectSendTicket {

    self.chatViewModel.isNotShowAlert = YES;
    
    //如果用户实现了自定义留言界面
    if (self.sdkConfig.leaveMessageAction) {
        self.sdkConfig.leaveMessageAction(self);
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
    CGFloat inputViewHeight = 80.0f;
    [_messageTableView setTableViewInsetsWithBottomValue:inputViewHeight];
    
    // 设置整体背景颜色
    [self setBackgroundColor];
    
    // 输入工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.ud_height - inputViewHeight,
                                   self.view.ud_width,
                                   inputViewHeight);
    
    _inputBar = [[UdeskInputBar alloc] initWithFrame:inputFrame tableView:_messageTableView];
    _inputBar.delegate = self;
    [self setInputBarButton];
    [self.view addSubview:_inputBar];
    
    //根据系统版本去掉自动调整
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //适配X
    if (ud_is_iPhoneX) {
        _inputBar.ud_bottom -= 34;
        _messageTableView.ud_height -= 34;
        [_messageTableView setTableViewInsetsWithBottomValue:self.view.ud_height - self.inputBar.ud_y];
    }
}

- (void)setInputBarButton {

    _inputBar.enableImSurvey = self.sdkSetting.enableImSurvey;
    _inputBar.enableImVideoCall = self.sdkSetting.sdkVCall;
    _inputBar.hiddenCameraButton = self.sdkConfig.hiddenCameraButton;
    _inputBar.hiddenAlbumButton = self.sdkConfig.hiddenAlbumButton;
    _inputBar.hiddenVoiceButton = self.sdkConfig.hiddenVoiceButton;
    _inputBar.hiddenEmotionButton = self.sdkConfig.hiddenEmotionButton;
    _inputBar.hiddenLocationButton = self.sdkConfig.hiddenLocationButton;
}

#pragma mark - UdeskInputBarDelegate
//点击表情按钮
- (void)didSelectEmotionButton:(BOOL)selected {
    
    if (selected) {
        self.textViewInputViewType = UDInputViewTypeEmotion;
        [self emotionManagerView];
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}
//点击语音按钮
- (void)didSelectVoiceButton:(BOOL)selected {

    if (selected) {
        self.textViewInputViewType = UDInputViewTypeVoice;
        [self voiceRecordView];
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}

//点击视频
- (void)didSelectVideoButton:(BOOL)selected {
    
#if __has_include(<UdeskCall/UdeskCall.h>)
    [self.inputBar.inputTextView resignFirstResponder];
    [self callingView];
    //邀请
    [[UdeskCallSessionManager sharedManager] inviteVideo];
    [UIView animateWithDuration:0.35 animations:^{
        self.callingView.ud_top = 0;
    }];
#endif
}

//点击地理位置
- (void)didSelectLocationButton:(BOOL)selected {

    //用户自己选择回调方式定位
    if (self.sdkConfig.locationButtonCallBack) {
        self.sdkConfig.locationButtonCallBack(self);
        return;
    }
    
    UdeskLocationViewController *location = [[UdeskLocationViewController alloc] initWithSDKConfig:self.sdkConfig hasSend:NO];
    [self presentViewController:location animated:YES completion:nil];
    @udWeakify(self);
    location.sendLocationBlock = ^(UdeskLocationModel *model) {
        
        @udStrongify(self);
        [self.chatViewModel sendLocationMessage:model completion:^(UdeskMessage *message) {
            //处理发送结果UI
            [self updateMessageStatus:message];
        }];
    };
}

//点击满意度按钮
- (void)didSurveyWithMessage:(NSString *)message hasSurvey:(BOOL)hasSurvey {

    self.textViewInputViewType = UDInputViewTypeNormal;
    [self layoutOtherMenuViewHiden:NO];
    // 已经评价了弹出橘色 没有弹出绿色
    [UdeskTopAlertView showAlertType:hasSurvey?UDAlertTypeOrange:UDAlertTypeGreen withMessage:message parentView:self.view];
}
//点击图片按钮
- (void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    self.textViewInputViewType = UDInputViewTypeNormal;
    //打开图片选择器
    void (^PickerMediaBlock)(UIImage *image) = ^(UIImage *image) {
        if (image) {
            [self didSendMessageWithPhoto:image];
        }
    };
    
    //打开图片选择器(gif)
    void (^PickerMediaGIFBlock)(NSData *gifData) = ^(NSData *gifData) {
        if (gifData) {
            [self didSendGIFImageMessage:gifData];
        }
    };
    
    //打开视频选择器
    void (^PickerMediaVideoBlock)(NSData *videoData,NSString *videoName) = ^(NSData *videoData,NSString *videoName) {
        if (videoData) {
            [self didSendVideoMessage:videoData videoName:videoName];
        }
    };
    
    [self layoutOtherMenuViewHiden:NO];
    [self.photographyHelper showImagePickerControllerSourceType:sourceType
                                               onViewController:self
                                                    hiddenVideo:self.sdkConfig.hiddenSendVideo
                                                        compled:PickerMediaBlock
                                                     compledGif:PickerMediaGIFBlock
                                                   compledVideo:PickerMediaVideoBlock];
}
//点击输入框
- (void)inputTextViewWillBeginEditing:(UdeskHPGrowingTextView *)messageInputTextView {
    self.textViewInputViewType = UDInputViewTypeText;
}
//点击inputBar
- (void)didUDMessageInputView {
    //根据客服code 实现相应的点击事件
    [self.chatViewModel clickInputViewShowAlertView];
}

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatViewModel numberOfItems];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id message = [self.chatViewModel objectAtIndexPath:indexPath.row];

    NSString *messageModelName = NSStringFromClass([message class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageModelName];
    
    if (!cell) {
        
        cell = [(UdeskBaseMessage *)message getCellWithReuseIdentifier:messageModelName];
        UdeskBaseCell *chatCell = (UdeskBaseCell*)cell;
        chatCell.delegate = self;
    }
    
    if (![cell isKindOfClass:[UdeskBaseCell class]]) {
        return cell;
    }
    
    [(UdeskBaseCell*)cell updateCellWithMessage:message];
    
    return cell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskBaseMessage *message = [self.chatViewModel objectAtIndexPath:indexPath.row];
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
    
    if (self.textViewInputViewType != UDInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
}

#pragma mark - UdeskCellDelegate
- (void)didSelectImageCell {

    [self.view endEditing:YES];
}

//发送咨询对象URL
- (void)sendProductURL:(NSString *)url {

    [self didSendTextAction:url];
}

//再次呼叫
- (void)callAgain {
    
    [self didSelectVideoButton:NO];
}

//结构化消息
- (void)didSelectStructButton {

    if (self.sdkConfig.structMessageCallBack) {
        self.sdkConfig.structMessageCallBack();
    }
}

//查看地理位置
- (void)didSelectLocationCell:(UdeskMessage *)message {

    UdeskLocationModel *model = [self.chatViewModel getLocationModel:message];
    //用户自己选择回调方式定位
    if (self.sdkConfig.locationMessageCallBack) {
        self.sdkConfig.locationMessageCallBack(self,model);
        return;
    }
    
    UdeskLocationViewController *location = [[UdeskLocationViewController alloc] initWithSDKConfig:self.sdkConfig hasSend:YES];
    location.locationModel = model;
    [self presentViewController:location animated:YES completion:nil];
}

//重发消息
- (void)resendMessageInCell:(UITableViewCell *)cell resendMessage:(UdeskMessage *)resendMessage {

    @udWeakify(self);
    if (self.inputBar.agent.code != UDAgentStatusResultOnline &&
        self.inputBar.agent.code != UDAgentStatusResultLeaveMessage) {
        [self.chatViewModel showAlertViewWithAgent];
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
    
    if ([self.inputBar.inputTextView resignFirstResponder]) {
        [self layoutOtherMenuViewHiden:YES];
    }
}

#pragma mark - 下拉加载更多数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    @try {
        
        if (scrollView.contentOffset.y<0 && self.messageTableView.isRefresh) {
            //开始刷新
            [self.messageTableView startLoadingMoreMessages];
            //获取更多数据
            [self.chatViewModel pullMoreDateBaseMessage];
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
        _callingView.ud_top = UD_SCREEN_HEIGHT;
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
        _callInviteView.ud_top = UD_SCREEN_HEIGHT;
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
        _titleView = [[UdeskChatTitleView alloc] initWithFrame:CGRectMake(0, 0, titleViewWidth, 44) sdkConfig:self.sdkConfig];
    }
    return _titleView;
}

#pragma mark - 表情view
- (UdeskEmotionManagerView *)emotionManagerView {

    if (!_emotionManagerView) {
        CGFloat emotionHeight = (UD_SCREEN_WIDTH<375?200:216) + (ud_is_iPhoneX ? 34 : 0);
        _emotionManagerView = [[UdeskEmotionManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), emotionHeight)];
        _emotionManagerView.delegate = self;
        _emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        _emotionManagerView.alpha = 0.0;
        [self.view addSubview:_emotionManagerView];
    }
    
    return _emotionManagerView;
}

#pragma mark - 图片选择器
- (UdeskPhotographyHelper *)photographyHelper {
    
    if (!_photographyHelper) {
        _photographyHelper = [[UdeskPhotographyHelper alloc] init];
    }
    
    return _photographyHelper;
}

#pragma mark - 吐司提示view
- (UdeskVoiceRecordHUD *)voiceRecordHUD {

    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[UdeskVoiceRecordHUD alloc] init];
    }
    return _voiceRecordHUD;
}

#pragma mark - 录音动画view
- (UdeskVoiceRecordView *)voiceRecordView {

    if (!_voiceRecordView) {
        _voiceRecordView = [[UdeskVoiceRecordView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), ud_is_iPhoneX ? 234 : 200)];
        _voiceRecordView.alpha = 0.0;
        _voiceRecordView.delegate = self;
        [self.view addSubview:_voiceRecordView];
    }
    
    return _voiceRecordView;
}

#pragma mark - UdeskVoiceRecordViewDelegate
//完成录音
- (void)finishRecordedWithVoicePath:(NSString *)voicePath withAudioDuration:(NSString *)duration {

    [self didSendMessageWithVoice:voicePath audioDuration:duration];
}
//录音时间太短
- (void)speakDurationTooShort {

    [self.voiceRecordHUD showTooShortRecord:self.view];
}

#pragma mark - 显示功能面板
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    //根据textViewInputViewType切换功能面板
    [self.inputBar.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.inputBar.frame;
        __block CGRect otherMenuViewFrame = CGRectMake(0, 0, 0, 0);
        
        CGFloat spacing = 0;
        if (ud_is_iPhoneX) {
            spacing = 34;
        }
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) - spacing : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            self.inputBar.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emotionManagerView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.emotionManagerView.alpha = !hide;
            self.emotionManagerView.frame = otherMenuViewFrame;
            
        };
        
        void (^VoiceManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.voiceRecordView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.voiceRecordView.alpha = !hide;
            self.voiceRecordView.frame = otherMenuViewFrame;
            
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case UDInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UDInputViewTypeVoice: {
                    VoiceManagerViewAnimation(hide);
                    break;
                }
                case UDInputViewTypeNormal: {
                    VoiceManagerViewAnimation(hide);
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case UDInputViewTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    VoiceManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UDInputViewTypeVoice: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    VoiceManagerViewAnimation(hide);
                    break;
                }
                case UDInputViewTypeNormal: {
                    VoiceManagerViewAnimation(!hide);
                    EmotionManagerViewAnimation(!hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [self.messageTableView setTableViewInsetsWithBottomValue:self.view.frame.size.height
         - self.inputBar.frame.origin.y];
        
        [self.messageTableView scrollToBottomAnimated:NO];
        
    } completion:^(BOOL finished) {
        
        if (hide) {
            self.textViewInputViewType = UDInputViewTypeNormal;
        }
    }];

}

#pragma mark - 发送文字
- (void)didSendTextAction:(NSString *)text {

    @udWeakify(self);
    [self.chatViewModel sendTextMessage:text completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
    
    [self.inputBar.inputTextView setText:nil];
}

#pragma mark - 发送图片
- (void)didSendMessageWithPhoto:(UIImage *)photo {
    
    @udWeakify(self);
    [self.chatViewModel sendImageMessage:photo completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
    
}

//发送GIF图片
- (void)didSendGIFImageMessage:(NSData *)data {
    
    @udWeakify(self);
    [self.chatViewModel sendGIFImageMessage:data completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
}

#pragma mark - 发送视频
- (void)didSendVideoMessage:(NSData *)videoData videoName:(NSString *)videoName {

    @udWeakify(self);
    [self.chatViewModel sendVideoMessage:videoData videoName:videoName progress:^(NSString *key,float progress){
    
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
        
        NSArray *array = [self.chatViewModel.messageArray valueForKey:@"messageId"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[array indexOfObject:messageId] inSection:0];
        UdeskVideoCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
        [cell setActivityIndicatorViewFrameWithSendStatus:UDMessageSendStatusSending];
        
        if ([cell isKindOfClass:[UdeskVideoCell class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.videoProgressView.progress = progress;
                if (progress == 1.0f || sendStatus == UDMessageSendStatusSuccess) {
                    [cell.videoPercentButton setTitle:getUDLocalizedString(@"udesk_has_send") forState:UIControlStateNormal];
                    [cell setActivityIndicatorViewFrameWithSendStatus:UDMessageSendStatusSuccess];
                }
                else {
                    [cell.videoPercentButton setTitle:[NSString stringWithFormat:@"%.f%%",progress*100] forState:UIControlStateNormal];
                }
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 发送语音
- (void)didSendMessageWithVoice:(NSString *)voicePath audioDuration:(NSString*)audioDuration {
    
    @udWeakify(self);
    [self.chatViewModel sendAudioMessage:voicePath audioDuration:audioDuration completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
    
}

//根据发送状态更新UI
- (void)updateMessageStatus:(UdeskMessage *)message {
    
    switch (message.messageStatus) {
        case UDMessageSendStatusSuccess:
            
            //更新UI
            [self updateChatMessageUI:message];
            break;
        case UDMessageSendStatusFailed:
        case UDMessageSendStatusOffSending:
            
            if (self.inputBar.agent.code == UDAgentStatusResultLeaveMessage) {
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
        
        NSArray *messageArray = self.chatViewModel.messageArray;
        
        for (UdeskBaseMessage *baseMessage in messageArray) {
            
            if ([baseMessage.message.messageId isEqualToString:message.messageId]) {
                
                baseMessage.message.messageStatus = message.messageStatus;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.chatViewModel.messageArray indexOfObject:baseMessage] inSection:0];
                
                UdeskBaseCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
                [cell setActivityIndicatorViewFrameWithSendStatus:baseMessage.message.messageStatus];
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

#pragma mark - UDEmotionManagerView Delegate
- (void)emojiViewDidPressDeleteButton:(UIButton *)deletebutton {

    if (self.inputBar.inputTextView.text.length > 0) {
        NSRange lastRange = [self.inputBar.inputTextView.text rangeOfComposedCharacterSequenceAtIndex:self.inputBar.inputTextView.text.length-1];
        self.inputBar.inputTextView.text = [self.inputBar.inputTextView.text substringToIndex:lastRange.location];
    }
}

//点击表情
- (void)emojiViewDidSelectEmoji:(NSString *)emoji {
    if ([self.inputBar.inputTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.inputBar.inputTextView.text isEqualToString:@"输入消息..."]) {
        self.inputBar.inputTextView.text = nil;
        self.inputBar.inputTextView.textColor = [UIColor blackColor];
    }
    self.inputBar.inputTextView.text = [self.inputBar.inputTextView.text stringByAppendingString:emoji];
}
//点击表情面板的发送按钮
- (void)didEmotionViewSendAction {

    [self didSendTextAction:self.inputBar.inputTextView.text];
}

//点击返回
- (void)dismissChatViewController {
    
    //隐藏键盘
    [self.inputBar.inputTextView resignFirstResponder];
    if (self.sdkSetting) {
        [self checkInvestigationWhenLeave];
    }
    else {
        [self dismissViewController];
    }
}

//检查是否设置返回弹出满意度评价
- (void)checkInvestigationWhenLeave {
    
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
    if (!self.inputBar.agent.agentId) {
        [self dismissViewController];
        return;
    }
    
    
    //检查是否已经评价
    UdeskAgentSurvey *agentSurvey = [UdeskAgentSurvey survey];
    [agentSurvey checkHasSurveyWithAgentId:self.inputBar.agent.agentId completion:^(NSString *hasSurvey,NSError *error) {
        
        //失败
        if (error) {
            [self dismissViewController];
            return ;
        }
        //还未评价
        if (![hasSurvey boolValue]) {
            
            [agentSurvey showAgentSurveyAlertViewWithAgentId:self.inputBar.agent.agentId isShowErrorAlert:NO completion:^(BOOL result, NSError *error) {
                if (!result) {
                    [self dismissViewController];
                }
                else {
                    [self didSurveyCompletion:getUDLocalizedString(@"udesk_top_view_thanks_evaluation")];
                }
            }];
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
        if (self.sdkConfig.leaveChatViewController) {
            self.sdkConfig.leaveChatViewController();
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
    [self ud_subscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {

        @try {
            
            @udStrongify(self);
            if (self.textViewInputViewType == UDInputViewTypeText) {
                //计算键盘的Y
                CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                CGRect inputViewFrame = self.inputBar.frame;
                //底部功能栏需要的Y
                CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                //tableview的bottom
                CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
                if (inputViewFrameY > messageViewFrameBottom)
                    inputViewFrameY = messageViewFrameBottom;
                //改变底部功能栏frame
                self.inputBar.frame = CGRectMake(inputViewFrame.origin.x,
                                                 inputViewFrameY,
                                                 inputViewFrame.size.width,
                                                 inputViewFrame.size.height);
                
                //适配X
                if (!isShowing) {
                    if (ud_is_iPhoneX) {
                        self.inputBar.ud_bottom -= 34;
                    }
                }
                
                //改变tableview frame
                [self.messageTableView setTableViewInsetsWithBottomValue:self.view.frame.size.height
                 - self.inputBar.frame.origin.y];
                
                if (isShowing) {
                    [self.messageTableView scrollToBottomAnimated:NO];
                    self.emotionManagerView.alpha = 0.0;
                    self.voiceRecordView.alpha = 0.0;
                } else {
                    
                    [self.inputBar.inputTextView resignFirstResponder];
                }
                
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }

    } completion:nil];

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
    [self ud_unsubscribeKeyboard];
    // 停止播放语音
    [[UdeskAudioPlayerHelper shareInstance] stopAudio];
    
    self.chatViewModel.isNotShowAlert = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //离开页面放弃排队
    if (self.inputBar.agent.code == UDAgentStatusResultQueue) {
        [UdeskManager quitQueueWithType:self.sdkConfig.quitQueueType];
    }
    //取消所有请求
    [UdeskManager cancelAllOperations];
}

- (void)dealloc {
    
    NSLog(@"%@销毁了",[self class]);
    _messageTableView.delegate = nil;
    _messageTableView.dataSource = nil;
}

@end
