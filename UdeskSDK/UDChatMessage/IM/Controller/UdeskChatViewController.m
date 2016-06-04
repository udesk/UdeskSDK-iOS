//
//  UdeskChatViewController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskChatViewController.h"
#import "UdeskTopAlertView.h"
#import "UdeskAgentModel.h"
#import "UdeskAgentStatusView.h"
#import "UdeskMessageInputView.h"
#import "UdeskMessageTableView.h"
#import "UdeskMessageTableViewCell.h"
#import "UdeskTicketViewController.h"
#import "UdeskEmotionManagerView.h"
#import "UdeskVoiceRecordHUD.h"
#import "UdeskPhotographyHelper.h"
#import "UdeskVoiceRecordHelper.h"
#import "UdeskChatViewModel.h"
#import "UIViewController+UdeskKeyboardAnimation.h"
#import "UdeskFoundationMacro.h"
#import <AVFoundation/AVFoundation.h>
#import "UdeskViewExt.h"
#import "UdeskUtils.h"
#import "UdeskTools.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskAudioPlayerHelper.h"
#import "UdeskPhotoManeger.h"
#import "UDManager.h"

@interface UdeskChatViewController ()<UIGestureRecognizerDelegate,UDMessageInputViewDelegate,UDMessageTableViewCellDelegate,UDEmotionManagerViewDelegate,UITableViewDelegate,UITableViewDataSource,UDAudioPlayerHelperDelegate>

@property (nonatomic, assign) UDInputViewType           textViewInputViewType;//输入消息类型
@property (nonatomic, assign) BOOL                      isMaxTimeStop;//判断是不是超出了录音最大时长
@property (nonatomic, weak  ) UdeskMessageTableView     *messageTableView;//用于显示消息的TableView
@property (nonatomic, weak  ) UdeskMessageInputView     *messageInputView;//用于显示发送消息类型控制的工具条，在底部
@property (nonatomic, weak  ) UdeskAgentStatusView      *agentStatusView;//客服状态view
@property (nonatomic, weak  ) UdeskEmotionManagerView   *emotionManagerView;//管理表情的控件
@property (nonatomic, strong) UdeskMessageTableViewCell *currentSelectedCell;//cell
@property (nonatomic, strong) UdeskVoiceRecordHelper    *voiceRecordHelper;//管理录音工具对象
@property (nonatomic, strong) UdeskVoiceRecordHUD       *voiceRecordHUD;//语音录制动画
@property (nonatomic, strong) UdeskPhotographyHelper    *photographyHelper;//管理本机的摄像和图片库的工具对象
@property (nonatomic, strong) UdeskChatViewModel        *chatViewModel;//viewModel

@end

@implementation UdeskChatViewController

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
    
    //初始化viewModel
    [self initViewModel];
    //初始化消息页面布局
    [self initilzer];
    //重写返回按钮
    [self setCloseNavigationItem];
}

#pragma mark - 添加左侧导航栏按钮
- (void)setCloseNavigationItem {
    //取消按钮
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 70, 40);
    [closeButton setTitle:getUDLocalizedString(@"返回") forState:UIControlStateNormal];
    [closeButton setImage:[UIImage ud_defaultBackImage] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if((FUDSystemVersion>=7.0)){
        
        negativeSpacer.width = -19;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,closeNavigationItem];
    }else
        self.navigationItem.leftBarButtonItem = closeNavigationItem;
    
}

- (void)closeButtonAction {
    
    //取消所有请求
    [self.chatViewModel cancelPollingAgent];
    [UDManager ud_cancelAllOperations];
    
    //用过返回上级页面了，发送中的消息改为发送失败，如果有需求，开发者可自定义
    [UDManager updateTableWithSqlString:@"update Message set sendflag='1' where sendflag = '0'" params:nil];
    
    //返回上级页面，设置客户离线
    [UDManager setCustomerOffline];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化viewModel
- (void)initViewModel {
    
    self.chatViewModel = [[UdeskChatViewModel alloc] initWithAgentId:self.agent_id withGroupId:self.group_id];
    @udWeakify(self);
    //接收客服信息
    self.chatViewModel.fetchAgentDataBlock = ^(UdeskAgentModel *agentModel){
        
        //更新客服状态文字
        @udStrongify(self);
        if (agentModel.code) {
            
            [self.agentStatusView bindDataWithAgentModel:agentModel];
            //显示top AlertView
            [UdeskTopAlertView showWithAgentModel:agentModel parentView:self.view];
            //底部功能栏根据客服状态code做操作
            self.messageInputView.agentCode = agentModel.code;
        }
    };
    //更新消息内容
    self.chatViewModel.updateMessageContentBlock = ^{
        
        @udStrongify(self);
        [self.messageTableView reloadData];
    };
    //离线留言
    self.chatViewModel.clickSendOffLineTicket = ^{
        
        @udStrongify(self);
        UdeskTicketViewController *offLineTicket = [[UdeskTicketViewController alloc] init];
        [self.navigationController pushViewController:offLineTicket animated:YES];
    };
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
	UdeskMessageTableView *messageTableView = [[UdeskMessageTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    [messageTableView finishLoadingMoreMessages:self.chatViewModel.message_count];
    
    [self.view addSubview:messageTableView];
    [self.view sendSubviewToBack:messageTableView];
	_messageTableView = messageTableView;
    
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChatTableView:)];
    
    [messageTableView addGestureRecognizer:tap];
    
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
    UdeskMessageInputView *inputView = [[UdeskMessageInputView alloc] initWithFrame:inputFrame tableView:_messageTableView];
    inputView.delegate = self;
    [self.view addSubview:inputView];
    [self.view bringSubviewToFront:inputView];
    
    _messageInputView = inputView;
    
    //客服标题
    CGFloat agentStatusTitleLength = [[UIScreen mainScreen] bounds].size.width>320?200:170;
    
    UdeskAgentStatusView *agentStatusView = [[UdeskAgentStatusView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-agentStatusTitleLength)/2, 20, agentStatusTitleLength, 44)];
    
    self.navigationItem.titleView = agentStatusView;
    
    _agentStatusView = agentStatusView;
    
    //表情view
    if (!_emotionManagerView) {
        UdeskEmotionManagerView *emotionManagerView = [[UdeskEmotionManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), UD_SCREEN_WIDTH<375?200:216)];
        emotionManagerView.delegate = self;
        emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        emotionManagerView.alpha = 0.0;
        [self.view addSubview:emotionManagerView];
        _emotionManagerView = emotionManagerView;
    }
    [self.view bringSubviewToFront:_emotionManagerView];
}

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatViewModel numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskMessage * message = [self.chatViewModel objectAtIndexPath:indexPath.row];
    
    BOOL displayTimestamp = [self shouldDisplayTimeForRowAtIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"UDMessageTableViewCell";
    
    UdeskMessageTableViewCell *messageTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!messageTableViewCell) {
        
        messageTableViewCell = [[UdeskMessageTableViewCell alloc] initWithMessage:message displaysTimestamp:displayTimestamp reuseIdentifier:cellIdentifier];
        messageTableViewCell.delegate = self;
    }
    
    messageTableViewCell.indexPath = indexPath;
    [messageTableViewCell configureCellWithMessage:message displaysTimestamp:displayTimestamp];
    
    return messageTableViewCell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskMessage *message = [self.chatViewModel objectAtIndexPath:indexPath.row];
    
    CGFloat calculateCellHeight = [self calculateCellHeightWithMessage:message atIndexPath:indexPath];
    
    return calculateCellHeight;
}

#pragma mark - 计算cell的高度
- (CGFloat)calculateCellHeightWithMessage:(UdeskMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    
    BOOL displayTimestamp = [self shouldDisplayTimeForRowAtIndexPath:indexPath];
    
    cellHeight = [UdeskMessageTableViewCell calculateCellHeightWithMessage:message displaysTimestamp:displayTimestamp];
    
    return cellHeight;
}

#pragma mark - 是否显示时间轴Label
- (BOOL)shouldDisplayTimeForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0 || indexPath.row>=[self.chatViewModel numberOfItemsInSection:indexPath.section]){
        return YES;
    }else{
        
        UdeskMessage *message = [self.chatViewModel objectAtIndexPath:indexPath.row];
        UdeskMessage *previousMessage=[self.chatViewModel objectAtIndexPath:indexPath.row-1];
        NSInteger interval=[message.timestamp timeIntervalSinceDate:previousMessage.timestamp];
        if(interval>60*3){
            return YES;
        }else{
            return NO;
        }
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

#pragma mark - UDTableViewCellDelegate
- (void)didSelectedOnMessage:(UdeskMessage *)message indexPath:(NSIndexPath *)indexPath messageTableViewCell:(UdeskMessageTableViewCell *)messageTableViewCell {
    
    //点击cell对应的操作
    switch (message.messageType) {
            
        case UDMessageMediaTypePhoto: {
            
            [self.messageInputView.inputTextView resignFirstResponder];
            
            UdeskPhotoManeger *photoManeger = [UdeskPhotoManeger maneger];
            
            [photoManeger showLocalPhoto:messageTableViewCell.messageContentView.photoImageView withImageMessage:message];
            
        }
            break;
        case UDMessageMediaTypeVoice:
            
            [[UdeskAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageContentView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageContentView.animationVoiceImageView stopAnimating];
                [[UdeskAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageContentView.animationVoiceImageView startAnimating];
                [[UdeskAudioPlayerHelper shareInstance] playAudioWithMessage:message];
            }
            
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UDAudioPlayerHelper Delegate
- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer {
    
    if (!_currentSelectedCell) {
        return;
    }
    
    [_currentSelectedCell.messageContentView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - UDChatTableViewDelegate
//点击空白处隐藏键盘
- (void)didTapChatTableView:(UITableView *)tableView {
    
    [self layoutOtherMenuViewHiden:YES];
}

#pragma mark - 下拉加载更多数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y<0 && self.messageTableView.isRefresh) {
        //开始刷新
        [self.messageTableView startLoadingMoreMessages];
        //获取更多数据
        [self.chatViewModel pullMoreDateBaseMessage];
        //延迟0.8，提高用户体验
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //关闭刷新、刷新数据
            [self.messageTableView finishLoadingMoreMessages:self.chatViewModel.message_total_pages];
        });
    }
    
}

#pragma mark - 录制语音
- (UdeskVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        
        @udWeakify(self);
        _voiceRecordHelper = [[UdeskVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            
            @udStrongify(self);
            UIButton *holdDown = self.messageInputView.holdDownButton;
            holdDown.selected = NO;
            holdDown.highlighted = NO;
            self.isMaxTimeStop = YES;
            
            [self finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            @udStrongify(self);
            self.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}
#pragma mark - 录制语音动画
- (UdeskVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[UdeskVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    }
    return _voiceRecordHUD;
}
#pragma mark - 图片选择器
- (UdeskPhotographyHelper *)photographyHelper {
    
    if (!_photographyHelper) {
        _photographyHelper = [[UdeskPhotographyHelper alloc] init];
    }
    
    return _photographyHelper;
}

#pragma mark - 显示功能面板
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    //根据textViewInputViewType切换功能面板
    [self.messageInputView.inputTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.messageInputView.frame;
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            self.messageInputView.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emotionManagerView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.emotionManagerView.alpha = !hide;
            self.emotionManagerView.frame = otherMenuViewFrame;
            
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case UDInputViewTypeEmotion: {
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
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UDInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [self.messageTableView setTableViewInsetsWithBottomValue:self.view.frame.size.height
         - self.messageInputView.frame.origin.y];
        
        [self.messageTableView scrollToBottomAnimated:NO];
        
    } completion:^(BOOL finished) {
        
        if (hide) {
            self.textViewInputViewType = UDInputViewTypeNormal;
        }
    }];

}
#pragma mark - UDMessageInputView Delegate
- (void)inputTextViewWillBeginEditing:(UdeskMessageTextView *)messageInputTextView {
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
    [self.chatViewModel clickInputViewShowAlertView];
}

#pragma mark - 发送文字
- (void)didSendTextAction:(NSString *)text {

    @udWeakify(self);
    [self.chatViewModel sendTextMessage:text completion:^(UdeskMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        @udStrongify(self);
        [self sendMessageStatus:sendStatus message:message];
    }];
    
    [self.messageInputView.inputTextView setText:nil];
}

#pragma mark - 发送图片
- (void)didSendMessageWithPhoto:(UIImage *)photo {
    
    @udWeakify(self);
    [self.chatViewModel sendImageMessage:photo completion:^(UdeskMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        @udStrongify(self);
        [self sendMessageStatus:sendStatus message:message];
    }];
    
}
#pragma mark - 发送语音
- (void)didSendMessageWithAudio:(NSString *)audioPath audioDuration:(NSString*)audioDuration {
    
    @udWeakify(self);
    [self.chatViewModel sendAudioMessage:audioPath audioDuration:audioDuration completion:^(UdeskMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        @udStrongify(self);
        [self sendMessageStatus:sendStatus message:message];
    }];
    
}
#pragma mark - 发送用户点击的失败消息
- (void)resendClickFailedMessage:(NSNotification *)notif {
    
    UdeskMessage *failedMessage = [notif.userInfo objectForKey:@"failedMessage"];
    failedMessage.agent_jid = self.chatViewModel.agentModel.jid;
    @udWeakify(self);
    [UDManager sendMessage:failedMessage completion:^(UdeskMessage *message, BOOL sendStatus) {
        //处理发送结果UI
        @udStrongify(self);
        [self sendMessageStatus:sendStatus message:message];
    }];
}

//根据发送状态更新UI
- (void)sendMessageStatus:(BOOL )sendStatus message:(UdeskMessage *)message {
    
    if (sendStatus) {
        //根据发送状态更新UI
        [self sendStatusConfigUI:sendStatus message:message];
        
    } else {
        [self.chatViewModel.failedMessageArray addObject:message];
        //开启重发
        @udWeakify(self);
        [self.chatViewModel resendFailedMessage:^(UdeskMessage *failedMessage, BOOL sendStatus) {
            //发送成功删除失败消息数组里的消息
            @udStrongify(self);
            if (sendStatus) {
                [self.chatViewModel.failedMessageArray removeObject:failedMessage];
            }
            //根据发送状态更新UI
            [self sendStatusConfigUI:sendStatus message:message];
        }];
        
    }
    
}
//根据发送状态更新UI
- (void)sendStatusConfigUI:(BOOL)sendStatus message:(UdeskMessage *)message {
    
    for (UdeskMessage *oldMessage in self.chatViewModel.messageArray) {
        
        if ([oldMessage.contentId isEqualToString:message.contentId]) {
            
            message.messageStatus = sendStatus?UDMessageSuccess:UDMessageFailed;
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.chatViewModel.messageArray indexOfObject:message] inSection:0];
            
            UdeskMessageTableViewCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
            [cell.messageContentView.indicatorView stopAnimating];
            
            cell.messageContentView.messageAgainButton.hidden = sendStatus?YES:NO;
            
            [UDManager updateTableWithSqlString:[NSString stringWithFormat:@"update Message set sendflag='%d' where msgid='%@'",sendStatus?2:1,message.contentId] params:nil];
        }

    }
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

    @udWeakify(self);
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordHUD = nil;
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
    
    @udWeakify(self);
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        @udStrongify(self);
        [self didSendMessageWithAudio:self.voiceRecordHelper.recordPath audioDuration:self.voiceRecordHelper.recordDuration];
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
    @udWeakify(self);
    [self ud_subscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        @udStrongify(self);
        if (self.textViewInputViewType == UDInputViewTypeText) {
            //计算键盘的Y
            CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
            CGRect inputViewFrame = self.messageInputView.frame;
            //底部功能栏需要的Y
            CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
            //tableview的bottom
            CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
            if (inputViewFrameY > messageViewFrameBottom)
                inputViewFrameY = messageViewFrameBottom;
            //改变底部功能栏frame
            self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                         inputViewFrameY,
                                                         inputViewFrame.size.width,
                                                         inputViewFrame.size.height);
            //改变tableview frame
            [self.messageTableView setTableViewInsetsWithBottomValue:self.view.frame.size.height
             - self.messageInputView.frame.origin.y];
            
            if (isShowing) {
                [self.messageTableView scrollToBottomAnimated:NO];
                self.emotionManagerView.alpha = 0.0;
            } else {
                
                [self.messageInputView.inputTextView resignFirstResponder];
                
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
    
    // 停止播放语音
    [[UdeskAudioPlayerHelper shareInstance] stopAudio];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
    
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
    _messageTableView = nil;
    _messageInputView.delegate = nil;
    _messageInputView = nil;
    _emotionManagerView.delegate = nil;
    _emotionManagerView = nil;
    _photographyHelper = nil;
    _agentStatusView = nil;
    _chatViewModel = nil;
    
}

@end
