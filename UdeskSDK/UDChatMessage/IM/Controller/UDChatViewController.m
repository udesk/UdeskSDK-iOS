//
//  UDChatViewController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDChatViewController.h"
#import "UDReceiveMessage.h"
#import "UDTopAlertView.h"
#import "UDAgentModel.h"
#import "UDAgentStatusView.h"
#import "UDAgentViewModel.h"
#import "UDMessageInputView.h"
#import "UDMessageTableView.h"
#import "UDMessageTextView.h"
#import "UDMessageContentView.h"
#import "UDMessageTableViewCell.h"
#import "UDTicketViewController.h"
#import "UDEmotionManagerView.h"
#import "UDVoiceRecordHUD.h"
#import "UDPhotographyHelper.h"
#import "UDVoiceRecordHelper.h"
#import "UDChatDataController.h"
#import "UDChatViewModel.h"
#import "UDChatCellViewModel.h"
#import "UIViewController+UDKeyboardAnimation.h"
#import "UDFoundationMacro.h"
#import <AVFoundation/AVFoundation.h>
#import "UDViewExt.h"
#import "UDManager.h"
#import "UdeskUtils.h"
#import "NSArray+UDMessage.h"

#define UDTitleLength  UD_SCREEN_WIDTH>320?200:170

@interface UDChatViewController ()<UIGestureRecognizerDelegate,UDMessageInputViewDelegate,UDMessageTableViewCellDelegate,UDChatTableViewDelegate,UDEmotionManagerViewDelegate,UDChatViewModelDelegate>

@property (nonatomic, assign) UDInputViewType textViewInputViewType;

@property (nonatomic, assign) BOOL networkSwitch;

@end

@implementation UDChatViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resendClickFailedMessage:) name:ClickResendMessage object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化消息页面布局
    [self initilzer];
    //初始化数据
    [self initData];
    //请求客服数据
    [self requestAgentData];
    //加载DB数据
    [self loadDatabaseMessage];
    //网路状态的变换
    [self networkStatusChange];
    
}

#pragma mark - 初始化视图
- (void)initilzer {
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // 提示用户允许访问麦克风
    if (ud_isIOS7) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            
        }];
    }
    
    // 初始化message tableView
	UDMessageTableView *messageTableView = [[UDMessageTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    messageTableView.chatTableViewDelegate = self;
    
    [self.view addSubview:messageTableView];
    [self.view sendSubviewToBack:messageTableView];
	_messageTableView = messageTableView;
    
    // 设置Message TableView 的bottom
    CGFloat inputViewHeight = 50.0f;
    [self.messageTableView setTableViewInsetsWithBottomValue:inputViewHeight];
    
    // 设置整体背景颜色
    [self setBackgroundColor:[UIColor colorWithRed:0.918f  green:0.922f  blue:0.925f alpha:1]];
    
    
    // 输入工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.ud_height - inputViewHeight,
                                   self.view.ud_width,
                                   inputViewHeight);
    
    // 初始化输入工具条
    UDMessageInputView *inputView = [[UDMessageInputView alloc] initWithFrame:inputFrame tableView:_messageTableView];
    inputView.delegate = self;
    [self.view addSubview:inputView];
    [self.view bringSubviewToFront:inputView];
    
    _messageInputView = inputView;
    
    UDAgentStatusView *agentStatusView = [[UDAgentStatusView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-UDTitleLength)/2, 0, UDTitleLength, 44)];
    self.navigationItem.titleView = agentStatusView;
    _agentStatusView = agentStatusView;
    
}
#pragma mark - UDChatTableViewDelegate
//点击空白处隐藏键盘
- (void)didTapChatTableView:(UITableView *)tableView {
    
    [self layoutOtherMenuViewHiden:YES];
}
//滑动视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)UIScrollView {

    //滑动表隐藏Menu
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (self.textViewInputViewType != UDInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
}
//点击消息
- (void)didSelectedOnMessage:(UDMessage *)message indexPath:(NSIndexPath *)indexPath messageTableViewCell:(UDMessageTableViewCell *)messageTableViewCell {
    
    //点击cell对应的操作
    [self.chatCellViewModel didSelectedOnMessage:message
                                       indexPath:indexPath
                                messageInputView:self.messageInputView
                            messageTableViewCell:messageTableViewCell];
}

#pragma mark - 初始化模型
- (void)initData {
    
    self.chatCellViewModel = [[UDChatCellViewModel alloc] init];
    
    self.dataController = [[UDChatDataController alloc] init];
    
    self.chatViewModel = [[UDChatViewModel alloc] init];
    
    self.messageTableView.chatViewModel = self.chatViewModel;
    
    self.chatViewModel.delegate = self;
    
    self.agentViewModel = [[UDAgentViewModel alloc] init];
}

#pragma mark - 请求客服数据
- (void)requestAgentData {

    UDWEAKSELF
    [self.agentViewModel requestAgentModel:^(UDAgentModel *agentModel, NSError *error) {
        //装载客服数据
        [weakSelf loadAgentDataReload:agentModel];
        
    }];
    
}

//装载客服数据
- (void)loadAgentDataReload:(UDAgentModel *)agentModel {
    
    //更新客服状态文字
    [self.agentStatusView bindDataWithAgentModel:agentModel];
    //登录Udesk
    [self.chatViewModel loginUdeskWithAgent:agentModel];
    //底部功能栏根据客服状态code做操作
    self.messageInputView.agentCode = agentModel.code;
    
}

#pragma makr - 根据网络状态变化做事
- (void)networkStatusChange {
    
    UDWEAKSELF
    [UDManager receiveNetwork:^(UDNetworkStatus reachability) {
        
        if (reachability == UDNotReachable) {
            
            weakSelf.networkSwitch = YES;
            [weakSelf setNetWorkStatusChangeUI:NO];
            
        } else {
            
            if (weakSelf.networkSwitch) {
                weakSelf.networkSwitch = NO;
                [weakSelf setNetWorkStatusChangeUI:YES];
            }
        }

    }];
    
}

- (void)setNetWorkStatusChangeUI:(BOOL)isNetwork {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        self.chatViewModel.agentModel.code = isNetwork?2000:2003;
        self.messageInputView.agentCode = isNetwork?2000:2003;
        [self.agentStatusView agentOnlineOrNotOnline:isNetwork?@"available":@"notNetwork"];
        [UDTopAlertView showWithType:isNetwork?UDAlertTypeOnline:UDAlertTypeError text:isNetwork?getUDLocalizedString(@"客服上线了！"):getUDLocalizedString(@"网络断开链接了！") parentView:self.view];
    });
    
}

#pragma mark - 加载db数据
- (void)loadDatabaseMessage {

    [self.dataController getDatabaseHistoryMessage:^(NSArray *dbMessageArray) {
        //更新数据
        [self.chatViewModel viewModelWithDatabase:dbMessageArray];
        //判断db数据条数是否需要下拉刷新
        [self.messageTableView finishLoadingMoreMessages:dbMessageArray.count];
        
    }];
}
#pragma mark - 下拉加载更多数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y<=0 && self.messageTableView.isRefresh) {
        //开始刷新
        [self.messageTableView startLoadingMoreMessages];
        //获取更多数据
        [self.dataController getDatabaseHistoryMessage:^(NSArray *dbMessageArray) {
            //配置更多数据
            [self.chatViewModel viewModelWithMoreMessage:dbMessageArray];
            //延迟0.5，提高用户体验
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //关闭刷新、刷新数据
                [self.messageTableView finishLoadingMoreMessages:dbMessageArray.count];
                
                [self.messageTableView reloadData];
                
            });
            
        }];
        
    }
    
}

#pragma mark - UDChatViewModelDelegate
//接收客服状态变化
- (void)receiveAgentPresence:(NSString *)presence {
    //更新客服状态title
    [self.agentStatusView agentOnlineOrNotOnline:presence];
    
    if ([presence isEqualToString:@"available"]) {

        [UDTopAlertView showWithType:UDAlertTypeOnline text:getUDLocalizedString(@"客服上线了！") parentView:self.view];
    } else {
        
        [UDTopAlertView showWithType:UDAlertTypeOffline text:getUDLocalizedString(@"客服下线了！") parentView:self.view];
    }
    
}
#pragma mark - 客户被转接了
- (void)notificationRedirect:(UDAgentModel *)agentModel {

    //装载客服数据
    [self loadAgentDataReload:agentModel];
}

#pragma mark - 刷新TableView
- (void)reloadChatTableView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.messageTableView reloadData];
        [self.messageTableView scrollToBottomAnimated:YES];
    });
    
}

#pragma mark - 离线发送表单
- (void)clickSendOffLineTicket {

    UDTicketViewController *offLineTicket = [[UDTicketViewController alloc] init];
    
    [self.navigationController pushViewController:offLineTicket animated:YES];
}

#pragma mark - 录制语音
- (UDVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        
        UDWEAKSELF
        _voiceRecordHelper = [[UDVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            
            UIButton *holdDown = weakSelf.messageInputView.holdDownButton;
            holdDown.selected = NO;
            holdDown.highlighted = NO;
            weakSelf.isMaxTimeStop = YES;
            
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}
#pragma mark - 录制语音动画
- (UDVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[UDVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    }
    return _voiceRecordHUD;
}
#pragma mark - 表情面板
- (UDEmotionManagerView *)emotionManagerView {
    
    if (!_emotionManagerView) {
        UDEmotionManagerView *emotionManagerView = [[UDEmotionManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), UD_SCREEN_WIDTH<375?200:216)];
        emotionManagerView.delegate = self;
        emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        emotionManagerView.alpha = 0.0;
        [self.view addSubview:emotionManagerView];
        _emotionManagerView = emotionManagerView;
    }
    [self.view bringSubviewToFront:_emotionManagerView];
    
    return _emotionManagerView;
}
#pragma mark - 图片选择器
- (UDPhotographyHelper *)photographyHelper {
    
    if (!_photographyHelper) {
        _photographyHelper = [[UDPhotographyHelper alloc] init];
    }
    
    return _photographyHelper;
}

#pragma mark - 显示功能面板
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    //根据textViewInputViewType切换功能面板

    [self.chatViewModel layoutOtherMenuViewHiden:hide
                                        ViewType:self.textViewInputViewType
                                        chatView:self.view
                                       tabelView:self.messageTableView
                                       inputView:self.messageInputView
                                     emotionView:self.emotionManagerView
                                      completion:^(BOOL finished) {
                                          
                                          if (hide) {
                                              self.textViewInputViewType = UDInputViewTypeNormal;
                                          }
                                      }];
        
}
#pragma mark - UDMessageInputView Delegate
- (void)inputTextViewWillBeginEditing:(UDMessageTextView *)messageInputTextView {
    self.textViewInputViewType = UDInputViewTypeText;
}

//点击语音or键盘按钮改变
- (void)didChangeSendVoiceAction:(BOOL)changed {
    if (changed) {
        if (self.textViewInputViewType == UDInputViewTypeText)
            return;
        // 在这之前，textViewInputViewType已经不是UDTextViewTextInputType
        [self layoutOtherMenuViewHiden:YES];
    }
}

- (void)didUDMessageInputView {
    //根据客服code 实现相应的点击事件
    [self.chatViewModel clickInputView];
}

#pragma mark - 发送文字
- (void)didSendTextAction:(NSString *)text {

    [self.chatViewModel sendTextMessage:text completion:^(UDMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        [self sendMessageStatus:sendStatus message:message];
    }];
    
    [self.messageInputView.inputTextView setText:nil];
}

#pragma mark - 发送图片
- (void)didSendMessageWithPhoto:(UIImage *)photo {
    UDWEAKSELF
    [self.chatViewModel sendImageMessage:photo completion:^(UDMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        [weakSelf sendMessageStatus:sendStatus message:message];
    }];
    
}
#pragma mark - 发送语音
- (void)didSendMessageWithAudio:(NSString *)audioPath audioDuration:(NSString*)audioDuration {
    UDWEAKSELF
    [self.chatViewModel sendAudioMessage:audioPath audioDuration:audioDuration completion:^(UDMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        [weakSelf sendMessageStatus:sendStatus message:message];
    }];
    
}
#pragma mark - 发送用户点击的失败消息
- (void)resendClickFailedMessage:(NSNotification *)notif {
    UDWEAKSELF
    UDMessage *failedMessage = [notif.userInfo objectForKey:@"failedMessage"];
    
    failedMessage.agent_jid = self.chatViewModel.agentModel.jid;
    
    [UDManager sendMessage:failedMessage completion:^(UDMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        [weakSelf sendMessageStatus:sendStatus message:message];
    }];
}

//根据发送状态更新UI
- (void)sendMessageStatus:(BOOL )sendStatus message:(UDMessage *)message {
    
    if (sendStatus) {
        //根据发送状态更新UI
        [self sendStatusConfigUI:sendStatus message:message];
        
    } else {
        UDWEAKSELF
        [self.chatViewModel.failedMessageArray addObject:message];
        //开启重发
        [self.chatViewModel resendFailedMessage:^(UDMessage *failedMessage, BOOL sendStatus) {
            //发送成功删除失败消息数组里的消息
            if (sendStatus) {
                [weakSelf.chatViewModel.failedMessageArray removeObject:failedMessage];
            }
            //根据发送状态更新UI
            [weakSelf sendStatusConfigUI:sendStatus message:message];
        }];
        
    }
    
}
//根据发送状态更新UI
- (void)sendStatusConfigUI:(BOOL)sendStatus message:(UDMessage *)message {

    UDWEAKSELF
    [self.chatViewModel.messageArray ud_each:^(UDMessage *oldMessage){
    
        if ([oldMessage.contentId isEqualToString:message.contentId]) {
            
            message.messageStatus = sendStatus?UDMessageSuccess:UDMessageFailed;
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[weakSelf.chatViewModel.messageArray indexOfObject:message] inSection:0];
            
            UDMessageTableViewCell *cell = [weakSelf.messageTableView cellForRowAtIndexPath:indexPath];
            [cell.messageContentView.indicatorView stopAnimating];
            
            cell.messageContentView.messageAgainButton.hidden = sendStatus?YES:NO;
            
            [UDManager updateTableWithSqlString:[NSString stringWithFormat:@"update Message set sendflag='%d' where msgid='%@'",sendStatus?2:1,message.contentId] params:nil];
        }
        
    }];
    
}

#pragma mark - 点击图片
- (void)didSelectedMultipleMediaAction {

    self.textViewInputViewType = UDInputViewTypeShareMenu;
    [self layoutOtherMenuViewHiden:NO];
}
#pragma mark - 点击表情
- (void)didSendFaceAction:(BOOL)sendFace {
    if (sendFace) {
        self.textViewInputViewType = UDInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}
#pragma mark - UDMessageInputViewDelegate
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {

    [self prepareRecordWithCompletion:completion];
}
//选择的发送图片方式
- (void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {

    //打开图片选择器
    void (^PickerMediaBlock)(UIImage *image) = ^(UIImage *image) {
        if (image) {
            [self didSendMessageWithPhoto:image];
        }
    };
    
    [self.photographyHelper showImagePickerControllerSourceType:sourceType onViewController:self compled:PickerMediaBlock];
}

//开始录音
- (void)didStartRecordingVoiceAction {

    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:nil];
}

//取消录音
- (void)didCancelRecordingVoiceAction {

    UDWEAKSELF
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
}

//录音完成
- (void)didFinishRecoingVoiceAction {

    if (self.isMaxTimeStop == NO) {
        [self finishRecorded];
    } else {
        self.isMaxTimeStop = NO;
    }
}
//当手指离开按钮的范围内时
- (void)didDragOutsideAction {
    [self.voiceRecordHUD resaueRecord];
}

//当手指再次进入按钮的范围内时
- (void)didDragInsideAction {
    [self.voiceRecordHUD pauseRecord];
}

//准备录音
- (void)prepareRecordWithCompletion:(UDPrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingCompletion:completion];
}
//录音完成
- (void)finishRecorded {
    UDWEAKSELF
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        [weakSelf didSendMessageWithAudio:weakSelf.voiceRecordHelper.recordPath audioDuration:weakSelf.voiceRecordHelper.recordDuration];
    }];
}

#pragma mark - UDEmotionManagerView Delegate
- (void)emojiViewDidPressDeleteButton:(UIButton *)deletebutton {

    if (self.messageInputView.inputTextView.text.length > 0) {
        NSRange lastRange = [self.messageInputView.inputTextView.text rangeOfComposedCharacterSequenceAtIndex:self.messageInputView.inputTextView.text.length-1];
        self.messageInputView.inputTextView.text = [self.messageInputView.inputTextView.text substringToIndex:lastRange.location];
    }
    
}
//点击表情
- (void)emojiViewDidSelectEmoji:(NSString *)emoji {
    self.messageInputView.inputTextView.text = [self.messageInputView.inputTextView.text stringByAppendingString:emoji];
}
//点击表情面板的发送按钮
- (void)didEmotionViewSendAction {

    [self didSendTextAction:self.messageInputView.inputTextView.text];
}

#pragma mark - 设置背景颜色
- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    _messageTableView.backgroundColor = color;
}

#pragma mark - 监听键盘通知做出相应的操作
- (void)subscribeToKeyboard {
    UDWEAKSELF
    [self ud_subscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        
        if (weakSelf.textViewInputViewType == UDInputViewTypeText) {
            //计算键盘的Y
            CGFloat keyboardY = [weakSelf.view convertRect:keyboardRect fromView:nil].origin.y;
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            //底部功能栏需要的Y
            CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
            //tableview的bottom
            CGFloat messageViewFrameBottom = weakSelf.view.frame.size.height - inputViewFrame.size.height;
            if (inputViewFrameY > messageViewFrameBottom)
                inputViewFrameY = messageViewFrameBottom;
            //改变底部功能栏frame
            weakSelf.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                         inputViewFrameY,
                                                         inputViewFrame.size.width,
                                                         inputViewFrame.size.height);
            //改变tableview frame
            [weakSelf.messageTableView setTableViewInsetsWithBottomValue:weakSelf.view.frame.size.height
             - weakSelf.messageInputView.frame.origin.y];
            
            if (isShowing) {
                [weakSelf.messageTableView scrollToBottomAnimated:NO];
                weakSelf.emotionManagerView.alpha = 0.0;
            } else {
                
                [weakSelf.messageInputView.inputTextView resignFirstResponder];
                
            }
            
        }
        
    } completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //监听键盘
    [self subscribeToKeyboard];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.iMNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.iMNavigationColor;
        self.navigationController.navigationBar.tintColor = Config.iMBackButtonColor;
    }
    //设置客户在线
    [UDManager setCustomerOnline];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // remove键盘通知或者手势
    [self ud_unsubscribeKeyboard];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
    
    //用过返回上级页面了，发送中的消息改为发送失败，如果有需求，开发者可自定义
    [UDManager updateTableWithSqlString:@"update Message set sendflag='1' where sendflag = '0'" params:nil];
    
    //返回上级页面，设置客户离线
    [UDManager setCustomerOffline];
    //客户不在当前页面停止请求排队客服
    self.agentViewModel.stopRequest = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    NSLog(@"UDMsgTableViewController销毁了");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:ClickResendMessage object:nil];
    _messageTableView.delegate = nil;
    _messageTableView.dataSource = nil;
    _messageTableView.chatTableViewDelegate = nil;
    _messageTableView = nil;
    _messageInputView.delegate = nil;
    _messageInputView = nil;
    _emotionManagerView.delegate = nil;
    _chatViewModel.delegate = nil;
    _photographyHelper = nil;
    _agentStatusView = nil;
    _agentViewModel = nil;

}

@end
