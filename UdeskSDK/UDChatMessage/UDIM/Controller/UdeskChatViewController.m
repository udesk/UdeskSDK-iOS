
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
#import "UdeskImagePicker.h"
#import "UIViewController+UdeskSDK.h"
#import "UIView+UdeskSDK.h"
#import "UdeskImageUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskAudioPlayer.h"
#import "UdeskManager.h"
#import "UdeskBaseCell.h"
#import "UdeskVoiceRecordView.h"
#import "UdeskVideoCell.h"
#import "UdeskImageCell.h"
#import "UdeskChatTitleView.h"
#import "UdeskLocationViewController.h"
#import "UdeskImagePickerController.h"
#import "UdeskSmallVideoViewController.h"
#import "UdeskChatInputToolBar.h"
#import "UdeskChatToolBarMoreView.h"
#import "UdeskPrivacyUtil.h"
#import "UdeskVoiceRecord.h"
#import "UdeskEmojiKeyboardControl.h"
#import "UdeskSurveyView.h"
#import "UdeskSmallVideoNavigationController.h"
#import "UdeskMessageUtil.h"
#import "UdeskSDKAlert.h"
#import "UdeskAgentMenuViewController.h"
#import "UdeskRobotTipsView.h"
#import "UdeskSDKShow.h"
#import "UdeskSurveyManager.h"
#import "UdeskSpeechRecognizerView.h"
#import "UIBarButtonItem+UdeskSDK.h"
#import "UdeskProductView.h"

static CGFloat udInputBarHeight = 54.0f;

@interface UdeskChatViewController ()<UITableViewDelegate,UITableViewDataSource,UdeskChatViewModelDelegate,UdeskCellDelegate,UdeskImagePickerControllerDelegate,UdeskSmallVideoViewControllerDelegate,UdeskChatInputToolBarDelegate,UdeskChatToolBarMoreViewDelegate,UdeskEmojiKeyboardControlDelegate,UdeskSpeechRecognizerViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UdeskMessageTableView     *messageTableView;//用于显示消息的TableView
@property (nonatomic, strong) UdeskEmojiKeyboardControl *emojiKeyboard;
@property (nonatomic, strong) UdeskChatToolBarMoreView  *moreView;
@property (nonatomic, strong) UdeskChatInputToolBar     *chatInputToolBar;
@property (nonatomic, strong) UdeskChatTitleView        *titleView;//标题
@property (nonatomic, strong) UdeskVoiceRecordView      *voiceRecordView;//
@property (nonatomic, strong) UdeskRobotTipsView        *robotTipsView;
@property (nonatomic, strong) UdeskSpeechRecognizerView *recognizerView;
@property (nonatomic, strong) UdeskProductView          *productView;

@property (nonatomic, strong) UdeskImagePicker    *photographyHelper;//
@property (nonatomic, strong) UdeskVoiceRecord    *voiceRecordHelper;//

@property (nonatomic, assign) BOOL                      isMaxTimeStop;//判断是不是超出了录音最大时长
@property (nonatomic, assign) BOOL                      backAlreadyDisplayedSurvey;//返回展示满意度
@property (nonatomic, strong, readwrite) UdeskChatViewModel  *chatViewModel;

@end

@implementation UdeskChatViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    //进入sdk页面
    [UdeskManager enterSDKPage];
    //初始化viewModel
    [self setupViewModel];
    //初始化消息页面布局
    [self setupUI];
}

#pragma mark - 初始化ViewModel
- (void)setupViewModel {
    
    self.chatViewModel = [[UdeskChatViewModel alloc] initWithSDKSetting:self.sdkSetting delegate:self];
}

#pragma mark - @protocol UdeskChatViewModelDelegate
//刷新表
- (void)reloadChatTableView {
    
    @udWeakify(self);
    //更新消息内容
    dispatch_async(dispatch_get_main_queue(), ^{
        @udStrongify(self);
        //是否需要下拉刷新
        [self.messageTableView finishLoadingMoreMessages:self.chatViewModel.isShowRefresh];
        [self.messageTableView reloadData];
        [self.messageTableView scrollToBottomAnimated:NO];
    });
}

- (void)reloadMoreMessageChatTableView {
    
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self safeCellUpdate:indexPath.section row:indexPath.row];
    });
}

- (void)safeCellUpdate:(NSUInteger)section row:(NSUInteger)row {
    
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
- (void)didUpdateAgentPresence:(UdeskAgent *)agent {

    [UdeskTopAlertView showWithCode:agent.statusType withMessage:agent.message parentView:self.view];
    [self didUpdateAgentModel:agent];
}

//更新客服信息
- (void)didUpdateAgentModel:(UdeskAgent *)agent {
    if (!agent || agent == (id)kCFNull) return ;

    [self setupAgentSessionMessageUI:YES];
    self.moreView.agent = agent;
    self.chatInputToolBar.agent = agent;
    [self.titleView updateTitle:agent];
    
    //客服在线
    if (agent.statusType == UDAgentStatusResultOnline) {
        //自动消息
        [self sendPreMessage];
    }
    else if (agent.statusType == UDAgentStatusResultOffline) {
        //会话已关闭
        [self layoutOtherMenuViewHiden:YES];
        [self.chatInputToolBar resetAllButtonSelectedStatus];
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

/** 展示机器人会话 */
- (void)showRobotSessionWithName:(NSString *)name {
    
    self.titleView.titleLabel.text = name;
    [self setupRobotMessageUI:YES];
}

//客户在黑名单
- (void)customerOnTheBlacklist:(NSString *)message {
    
    if ([UdeskSDKUtil isBlankString:message]) {
        message = getUDLocalizedString(@"udesk_alert_view_blocked_list");
    }
    
    [UdeskSDKAlert showWithMessage:message handler:^{
        [self dismissViewController];
    }];
}

//网络断开链接
- (void)didReceiveNetworkDisconnect {
    
    //网络不可用
    self.chatInputToolBar.networkDisconnect = YES;
    self.titleView.titleLabel.text = getUDLocalizedString(@"udesk_network_interrupt");
    [UdeskTopAlertView showAlertType:UDAlertTypeNetworkFailure withMessage:getUDLocalizedString(@"udesk_notwork_failure") parentView:self.view];
}

//自动转人工
- (void)didReceiveAutoTransferAgentServer {
    
    [self transferToAgentServer];
}

//显示转人工按钮
- (void)showTransferButton {
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem udRightItemWithTitle:getUDLocalizedString(@"udesk_redirect") target:self action:@selector(didSelectNavigationRightButton)];
}

//更新标题
- (void)updateChatTitleWithText:(NSString *)text {
    
    self.titleView.titleLabel.text = text;
}

//配置人工会话的UI
- (void)setupAgentSessionMessageUI:(BOOL)isAgentSession {
    
    [self setupPreSessionMessageUI:NO];
    
    self.chatInputToolBar.isAgentSession = isAgentSession;
    self.moreView.isAgentSession = isAgentSession;
    self.chatInputToolBar.networkDisconnect = NO;
}

//配置无消息对话过滤的UI
- (void)setupPreSessionMessageUI:(BOOL)isPreSessionMessage {
    
    [self setupRobotMessageUI:NO];
    
    self.chatInputToolBar.isPreSession = isPreSessionMessage;
    self.moreView.isPreSession = isPreSessionMessage;
    self.chatInputToolBar.networkDisconnect = NO;
}

//配置机器人的UI
- (void)setupRobotMessageUI:(BOOL)isRobotSession {
    
    self.chatInputToolBar.isRobotSession = isRobotSession;
    self.moreView.isRobotSession = isRobotSession;
    self.chatInputToolBar.networkDisconnect = NO;
    
    //显示转人工按钮
    if (isRobotSession) {
        [self showTransferButton];
    }
    
    //无法转人工
    if (!self.sdkSetting.enableAgent.boolValue) {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    //设置了客服发送多少条消息之后才展示转人工按钮
    if (self.sdkSetting.showRobotTimes.integerValue) {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    if (!isRobotSession) {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

//发送预知消息
- (void)sendPreMessage {
    
    if (!self.sdkConfig.preSendMessages || self.sdkConfig.preSendMessages == (id)kCFNull) return ;
    
    //自动消息
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        for (id messageContent in self.sdkConfig.preSendMessages) {
            if ([messageContent isKindOfClass:[NSString class]]) {
                [self sendTextMessageWithContent:messageContent completion:nil];
            }
            else if ([messageContent isKindOfClass:[UIImage class]]) {
                [self sendImageMessageWithImage:messageContent completion:nil];
            }
        }
        self.sdkConfig.preSendMessages = nil;
    });
}

#pragma mark - 配置UI
- (void)setupUI {
    
    //用户自己设置了标题
    if (self.sdkConfig.imTitle) {
        self.title = self.sdkConfig.imTitle;
    }
    else {
        self.navigationItem.titleView = self.titleView;
    }
    
    self.view.backgroundColor = self.sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
    
    //聊天页面
	_messageTableView = [[UdeskMessageTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    _messageTableView.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
    [self.view addSubview:_messageTableView];
    [self.view sendSubviewToBack:_messageTableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChatTableView:)];
    tap.cancelsTouchesInView = false;
    tap.delegate = self;
    [_messageTableView addGestureRecognizer:tap];
    
    //咨询对象
    if (self.sdkConfig.productDictionary) {
        self.productView.productData = self.sdkConfig.productDictionary;
        _messageTableView.udTop = self.productView.udBottom;
        _messageTableView.udHeight = _messageTableView.udHeight - self.productView.udBottom;
    }
    
    //输入框
    _chatInputToolBar = [[UdeskChatInputToolBar alloc] initWithFrame:CGRectMake(0.0f,self.view.udHeight - udInputBarHeight - (udIsIPhoneXSeries?34:0),self.view.udWidth,udInputBarHeight+(udIsIPhoneXSeries?34:0)) tableView:_messageTableView];
    _chatInputToolBar.delegate = self;
    [self.view addSubview:_chatInputToolBar];
    
    //配置自定义按钮
    _chatInputToolBar.enableSurvey = self.sdkSetting.enableImSurvey.boolValue;
    _chatInputToolBar.customButtonConfigs = self.sdkConfig.customButtons;
    
    _messageTableView.udHeight -= udIsIPhoneXSeries?34:0;
    [_messageTableView setTableViewInsetsWithBottomValue:self.view.udHeight - _chatInputToolBar.udY];
}

//点击空白处隐藏键盘
- (void)didTapChatTableView:(UIGestureRecognizer *)recognizer {
    
    if ([self.chatInputToolBar.chatTextView resignFirstResponder]) {
        [self layoutOtherMenuViewHiden:YES];
        [self.chatInputToolBar resetAllButtonSelectedStatus];
    }
}

#pragma mark - @protocol UdeskChatInputToolBarDelegate
//发送文本消息
- (void)didSendText:(NSString *)text {
    
    [self sendTextMessageWithContent:text completion:nil];
}

//点击语音
- (void)didSelectVoice:(UdeskButton *)voiceButton {
    
    //机器人
    if (self.moreView.isRobotSession) {
        [self.recognizerView show];
        [self layoutOtherMenuViewHiden:YES];
        return;
    }
    
    if (voiceButton.selected) {
        [self layoutOtherMenuViewHiden:YES];
    } else {
        [self.chatInputToolBar.chatTextView becomeFirstResponder];
    }
}

//点击表情
- (void)didSelectEmotion:(UdeskButton *)emotionButton {
    
    if (emotionButton.selected) {
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.chatInputToolBar.chatTextView becomeFirstResponder];
    }
}

//点击更多
- (void)didSelectMore:(UdeskButton *)moreButton {
    
    if (moreButton.selected) {
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.chatInputToolBar.chatTextView becomeFirstResponder];
    }
}

//点击UdeskChatInputToolBar
- (void)didClickChatInputToolBar {
    
    if (self.chatInputToolBar.agent.sessionType == UDAgentSessionTypeHasOver) {
        self.titleView.titleLabel.text = getUDLocalizedString(@"udesk_connecting");
    }
    [self.chatViewModel showSDKAlert];
}

//点击自定义按钮
- (void)didSelectCustomToolBar:(UdeskCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    [self callbackCustomButtonActionWithIndex:index];
}

//点击自定义评价
- (void)didSelectCustomToolBarSurvey:(UdeskCustomToolBar *)toolBar {
    
    [self servicesFeedbackSurveyWithAgentId:self.chatInputToolBar.agent.agentId];
}

//准备录音
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    
    [self.voiceRecordHelper prepareRecordingCompletion:completion];
}

//开始录音
- (void)didStartRecordingVoiceAction {
    
    [self.voiceRecordView startRecordingAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:nil];
}

//手指向上滑动取消录音
- (void)didCancelRecordingVoiceAction {
    
    @udWeakify(self);
    [self.voiceRecordView cancelRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordView = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
}

//松开手指完成录音
- (void)didFinishRecoingVoiceAction {
    
    if (self.isMaxTimeStop == NO) {
        [self finishRecorded];
    } else {
        self.isMaxTimeStop = NO;
    }
}

//当手指离开按钮的范围内时
- (void)didDragOutsideAction {
    
    [self.voiceRecordView resaueRecord];
}

//当手指再次进入按钮的范围内时
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
        [self sendVoiceMessageWithVoicePath:self.voiceRecordHelper.recordPath voiceDuration:self.voiceRecordHelper.recordDuration completion:nil];
    }];
}

//文本发生改变
- (void)chatTextViewShouldChangeText:(NSString *)text {
    
    //机器人会话使用联想功能
    if (self.moreView.isRobotSession) {
        [self.robotTipsView updateWithKeyword:text];
    }
}

#pragma mark - @protocol UdeskChatToolBarMoreViewDelegate
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
    
    [self.chatInputToolBar.chatTextView resignFirstResponder];
    [self.chatViewModel startUdeskVideoCall];
}

//开始定位
- (void)startUdeskLocation {
    
    //用户自己选择回调方式定位
    if (self.sdkConfig.actionConfig.locationButtonClickBlock) {
        self.sdkConfig.actionConfig.locationButtonClickBlock(self);
        return;
    }
    
    UdeskLocationViewController *location = [[UdeskLocationViewController alloc] initWithSDKConfig:self.sdkConfig hasSend:NO];
    location.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:location animated:YES completion:nil];
    @udWeakify(self);
    location.sendLocationBlock = ^(UdeskLocationModel *model) {
        
        @udStrongify(self);
        [self sendLoactionMessageWithModel:model completion:nil];
    };
}

//评价客服
- (void)servicesFeedbackSurveyWithAgentId:(NSString *)agentId {
    
    [UdeskSurveyManager checkHasSurveyWithAgentId:agentId isRobotSession:self.moreView.isRobotSession completion:^(BOOL hasSurvey, NSError *error) {
        if (hasSurvey) {
            [UdeskTopAlertView showAlertType:UDAlertTypeOrange withMessage:getUDLocalizedString(@"udesk_has_survey") parentView:self.view];
        }
        else {
            [self showSurveyViewWithAgentId:agentId];
        }
    }];
}

//显示满意度评价
- (void)showSurveyViewWithAgentId:(NSString *)agentId {
    
    UdeskSurveyView *surveyView = [[UdeskSurveyView alloc] initWithAgentId:agentId imSubSessionId:[NSString stringWithFormat:@"%ld",(long)self.chatInputToolBar.agent.imSubSessionId] isRobotSession:self.moreView.isRobotSession];
    [surveyView show];
}

//开启用户相册
- (void)openCustomerAlubm {
    
    [UdeskPrivacyUtil checkPermissionsOfAlbum:^{
        
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        if (ud_isIOS8 && sdkConfig.isImagePickerEnabled) {
            
            UdeskImagePickerController *imagePicker = [[UdeskImagePickerController alloc] init];
            imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
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
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }];
            
            return;
        }
        
        [self sendImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
}

#pragma mark - @protocol UdeskImagePickerControllerDelegate
// 如果选择发送了图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos {
    
    for (UIImage *image in photos) {
        [self sendImageMessageWithImage:image completion:nil];
    }
}

// 如果选择发送了视频，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingVideos:(NSArray<NSString *> *)videoPaths {
    
    for (NSString *path in videoPaths) {
        [self sendVideoMessageWithVideoFile:path completion:nil];
    }
}

// 如果选择发送了gif图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingGIFImages:(NSArray<NSData *> *)gifImages {
    
    for (NSData *data in gifImages) {
        [self sendGIFMessageWithGIFData:data completion:nil];
    }
}

#pragma mark - @protocol UdeskSmallVideoViewControllerDelegate
//拍摄视频
- (void)didFinishRecordSmallVideo:(NSDictionary *)videoInfo {
    
    if (![videoInfo.allKeys containsObject:@"videoURL"]) {
        return;
    }
    NSString *url = videoInfo[@"videoURL"];
    [self sendVideoMessageWithVideoFile:url completion:nil];
}

//拍摄图片
- (void)didFinishCaptureImage:(UIImage *)image {
    
    [self sendImageMessageWithImage:image completion:nil];
}

//ios8以下的选择图片和拍照方式
- (void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    //打开图片选择器
    void (^PickerMediaBlock)(UIImage *image) = ^(UIImage *image) {
        if (image) {
            [self sendImageMessageWithImage:[UdeskImageUtil fixOrientation:image] completion:nil];
        }
    };
    
    //打开图片选择器(gif)
    void (^PickerMediaGIFBlock)(NSData *gifData) = ^(NSData *gifData) {
        if (gifData) {
            [self sendGIFMessageWithGIFData:gifData completion:nil];
        }
    };
    
    //打开视频选择器
    void (^PickerMediaVideoBlock)(NSString *filePath,NSString *videoName) = ^(NSString *filePath,NSString *videoName) {
        if (filePath) {
            [self sendVideoMessageWithVideoFile:filePath completion:nil];
        }
    };
    
    [self.photographyHelper showImagePickerControllerSourceType:sourceType
                                               onViewController:self
                                                        compled:PickerMediaBlock
                                                     compledGif:PickerMediaGIFBlock
                                                   compledVideo:PickerMediaVideoBlock];
}


#pragma mark - @protocol TableViewDataSource
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

#pragma mark - @protocol TableViewDelegate
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

//滑动table
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

//下拉加载更多数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y<0 && self.messageTableView.isRefresh) {
        //开始刷新
        [self.messageTableView startLoadingMoreMessages];
        //获取更多数据
        [self.chatViewModel fetchNextPageMessages];
        //延迟1.5，提高用户体验
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //关闭刷新、刷新数据
            [self.messageTableView finishLoadingMoreMessages:self.chatViewModel.isShowRefresh];
        });
    }
}

#pragma mark - @protocol UdeskCellDelegate
- (void)didTapChatImageView {
    [self.view endEditing:YES];
}

//再次呼叫
- (void)didTapUdeskVideoCallMessage:(UdeskMessage *)message {
    [self startUdeskVideoCall];
}

//结构化消息
- (void)didTapStructMessageButtonWithValue:(NSString *)value callbackName:(NSString *)callbackName {

    if (self.sdkConfig.actionConfig.structMessageClickBlock) {
        self.sdkConfig.actionConfig.structMessageClickBlock(value,callbackName);
    }
}

//点击商品消息
- (void)didTapGoodsMessageWithModel:(UdeskGoodsModel *)goodsModel {
    
    if (self.sdkConfig.actionConfig.goodsMessageClickBlock) {
        self.sdkConfig.actionConfig.goodsMessageClickBlock(self,goodsModel);
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
    location.modalPresentationStyle = UIModalPresentationFullScreen;
    location.locationModel = model;
    [self presentViewController:location animated:YES completion:nil];
}

//点击重发消息
- (void)didResendMessage:(UdeskMessage *)resendMessage {

    @udWeakify(self);
    [self.chatViewModel resendMessageWithMessage:resendMessage progress:^(float percent) {
        
        //更新进度
        @udStrongify(self);
        [self updateUploadProgress:percent messageId:resendMessage.messageId sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        //处理发送结果UI
        @udStrongify(self);
        [self updateChatMessageUI:message];
    }];
}

//点击留言
- (void)didTapLeaveMessageButton:(UdeskMessage *)message {
    [self.chatViewModel leaveMessageTapAction];
}

//点击常见问题
- (void)didSendRobotMessage:(UdeskMessage *)message {
    
    @udWeakify(self);
    [self.chatViewModel sendRobotMessage:message completion:^(UdeskMessage *message) {
        @udStrongify(self);
        [self updateChatMessageUI:message];
    }];
}

//点击消息转人工
- (void)didTapTransferAgentServer:(UdeskMessage *)message {
    
    [self transferToAgentServer];
}

//答案已评价
- (void)aswerHasSurvey {
    
    [UdeskTopAlertView showAlertType:UDAlertTypeOrange withMessage:getUDLocalizedString(@"udesk_answer_has_survey") parentView:self.view];
}

//刷新
- (void)reloadTableViewAtCell:(UITableViewCell *)cell {
    
    [self reloadChatTableView];
}

#pragma mark - @protocol UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UILabel class]]){
        return NO;
    }
    return YES;
}

#pragma mark - 发送文字
- (void)sendTextMessageWithContent:(NSString *)content completion:(void(^)(UdeskMessage *message))completion {
    if (!content || content == (id)kCFNull) return ;
    if (![content isKindOfClass:[NSString class]]) return ;

    //最大字符限制
    if (content.length > 800) {
        [UdeskSDKAlert showWithMessage:getUDLocalizedString(@"udesk_text_max_num") handler:nil];
        return;
    }
    
    @udWeakify(self);
    [self.chatViewModel sendTextMessage:content completion:^(UdeskMessage *message) {
        if (completion) completion(message);

        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
    
    [self.chatInputToolBar.chatTextView setText:nil];
    self.robotTipsView.alpha = 0;
}

#pragma mark - 发送图片
- (void)sendImageMessageWithImage:(UIImage *)image completion:(void(^)(UdeskMessage *message))completion {
    if (!image || image == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendImageMessage:image progress:^(NSString *key,float progress){
        
        @udStrongify(self);
        [self updateUploadProgress:progress messageId:key sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        if (completion) completion(message);

        @udStrongify(self);
        [self updateMessageStatus:message];
        [self updateUploadProgress:message.messageStatus == UDMessageSendStatusSuccess?1:0 messageId:message.messageId sendStatus:message.messageStatus];
    }];
}

//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData completion:(void(^)(UdeskMessage *message))completion {
    if (!gifData || gifData == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendGIFImageMessage:gifData progress:^(NSString *key,float progress){
        
        @udStrongify(self);
        [self updateUploadProgress:progress messageId:key sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        if (completion) completion(message);

        @udStrongify(self);
        [self updateMessageStatus:message];
        [self updateUploadProgress:message.messageStatus == UDMessageSendStatusSuccess?1:0 messageId:message.messageId sendStatus:message.messageStatus];
    }];
}

#pragma mark - 发送视频
- (void)sendVideoMessageWithVideoFile:(NSString *)videoFile completion:(void(^)(UdeskMessage *message))completion {
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
    
        @udStrongify(self);
        [self updateUploadProgress:progress messageId:key sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *message) {
        if (completion) completion(message);
        
        @udStrongify(self);
        [self updateMessageStatus:message];
        [self updateUploadProgress:message.messageStatus == UDMessageSendStatusSuccess?1:0 messageId:message.messageId sendStatus:message.messageStatus];
    }];
}

#pragma mark - 发送语音
- (void)sendVoiceMessageWithVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void(^)(UdeskMessage *message))completion {
    if (!voicePath || voicePath == (id)kCFNull) return ;
    if (!voiceDuration || voiceDuration == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendVoiceMessage:voicePath voiceDuration:voiceDuration completion:^(UdeskMessage *message) {
        if (completion) completion(message);
        
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
}

#pragma mark - 发送位置信息
- (void)sendLoactionMessageWithModel:(UdeskLocationModel *)locationModel completion:(void(^)(UdeskMessage *message))completion {
    if (!locationModel || locationModel == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendLocationMessage:locationModel completion:^(UdeskMessage *message) {
        if (completion) completion(message);
        
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
}

#pragma mark - 发送商品信息
- (void)sendGoodsMessageWithModel:(UdeskGoodsModel *)goodsModel completion:(void(^)(UdeskMessage *message))completion {
    if (!goodsModel || goodsModel == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.chatViewModel sendGoodsMessage:goodsModel completion:^(UdeskMessage *message) {
        if (completion) completion(message);
        
        @udStrongify(self);
        [self updateMessageStatus:message];
    }];
}

#pragma mark - 更新消息状态
//根据发送状态更新UI
- (void)updateMessageStatus:(UdeskMessage *)message {
    if (!message || message == (id)kCFNull) return ;
    
    switch (message.messageStatus) {
        case UDMessageSendStatusSuccess:
            
            [self updateChatMessageUI:message];
            break;
        case UDMessageSendStatusFailed:
        case UDMessageSendStatusOffSending:
            
            if (self.chatInputToolBar.agent.statusType != UDAgentStatusResultOnline ||
                self.chatInputToolBar.agent.sessionType == UDAgentSessionTypeHasOver) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

//更新上传进度
- (void)updateUploadProgress:(float)progress messageId:(NSString *)messageId sendStatus:(UDMessageSendStatus)sendStatus {
        
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            
            NSArray *array = [self.chatViewModel.messagesArray valueForKey:@"messageId"];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[array indexOfObject:messageId] inSection:0];
            UdeskBaseCell *cell = [self.messageTableView cellForRowAtIndexPath:indexPath];
            
            if ([cell isKindOfClass:[UdeskImageCell class]]) {
                UdeskImageCell *imageCell = (UdeskImageCell *)cell;
                if (progress == 1.0f || sendStatus == UDMessageSendStatusSuccess) {
                    [imageCell uploadImageSuccess];
                }
                else {
                    [imageCell imageUploading];
                    imageCell.progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                }
            }
            else if ([cell isKindOfClass:[UdeskVideoCell class]]) {
                UdeskVideoCell *videoCell = (UdeskVideoCell *)cell;
                if (progress == 1.0f || sendStatus == UDMessageSendStatusSuccess) {
                    [videoCell uploadVideoSuccess];
                    [videoCell updateMessageSendStatus:UDMessageSendStatusSuccess];
                }
                else {
                    videoCell.uploadProgressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                }
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    });
}

#pragma mark - 自动重发
- (void)beginResendMessage:(UdeskMessage *)message {
    
    [self.chatViewModel addResendMessageToArray:message];
    @udWeakify(self);
    [self.chatViewModel autoResendFailedMessageWithProgress:^(float percent) {
        
        @udStrongify(self);
        [self updateUploadProgress:percent messageId:message.messageId sendStatus:UDMessageSendStatusSending];
        
    } completion:^(UdeskMessage *failedMessage) {
        
        //发送成功删除失败消息数组里的消息
        @udStrongify(self);
        if (failedMessage.messageStatus == UDMessageSendStatusSuccess) {
            [self.chatViewModel removeResendMessageInArray:failedMessage];
        }

        [self updateChatMessageUI:message];
        [self updateUploadProgress:failedMessage.messageStatus == UDMessageSendStatusSuccess?1:0 messageId:message.messageId sendStatus:failedMessage.messageStatus];
    }];
}

#pragma mark - @protocol UdeskEmojiKeyboardControlDelegate
//点击默认表情
- (void)emojiViewDidPressEmojiWithResource:(NSString *)resource {
    if (!resource || resource == (id)kCFNull) return ;
    
    if ([self.chatInputToolBar.chatTextView.textColor isEqual:[UIColor lightGrayColor]] &&
        [self.chatInputToolBar.chatTextView.text isEqualToString:getUDLocalizedString(@"udesk_typing")]) {
        self.chatInputToolBar.chatTextView.text = nil;
        self.chatInputToolBar.chatTextView.textColor = [UIColor blackColor];
    }
    self.chatInputToolBar.chatTextView.text = [self.chatInputToolBar.chatTextView.text stringByAppendingString:resource];
}

//点击自定义表情
- (void)emojiViewDidPressStickerWithResource:(NSString *)resource {
    if (!resource || resource == (id)kCFNull) return ;
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:resource]];
    NSString *imageType = [UdeskImageUtil contentTypeForImageData:imageData];
    if ([imageType isEqualToString:@"gif"]) {
        [self sendGIFMessageWithGIFData:imageData completion:nil];
    }
    else {
        [self sendImageMessageWithImage:[UIImage imageWithData:imageData] completion:nil];
    }
}

//删除表情
- (void)emojiViewDidPressDelete {
    
    if (self.chatInputToolBar.chatTextView.text.length > 0) {
        NSRange lastRange = [self.chatInputToolBar.chatTextView.text rangeOfComposedCharacterSequenceAtIndex:self.chatInputToolBar.chatTextView.text.length-1];
        self.chatInputToolBar.chatTextView.text = [self.chatInputToolBar.chatTextView.text substringToIndex:lastRange.location];
    }
}

//发送表情
- (void)emojiViewDidPressSend {
    
    [self sendTextMessageWithContent:self.chatInputToolBar.chatTextView.text completion:nil];
}

#pragma mark - 导航栏右侧按钮事件
- (void)didSelectNavigationRightButton {
    
    [self transferToAgentServer];
}

//转人工
- (void)transferToAgentServer {
    
    //开通了导航栏
    if (self.sdkSetting.enableImGroup.boolValue) {
     
        [UdeskManager fetchAgentMenu:^(id responseObject, NSError *error) {
            
            if (error) return ;
            NSArray *result = [responseObject objectForKey:@"result"];
            //有设置客服导航栏
            if (result.count) {
                
                UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:self.sdkConfig];
                UdeskAgentMenuViewController *agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:self.sdkConfig setting:self.sdkSetting];
                agentMenu.menuDataSource = result;
                @udWeakify(self);
                agentMenu.didSelectAgentGroupServerBlock = ^{
                    @udStrongify(self);
                    self.titleView.titleLabel.text = getUDLocalizedString(@"udesk_connecting");
                    [self.chatViewModel transferToAgentServer];
                };
                [show presentOnViewController:self udeskViewController:agentMenu transiteAnimation:UDTransiteAnimationTypePush completion:nil];
            }
        }];
        return;
    }
    
    self.titleView.titleLabel.text = getUDLocalizedString(@"udesk_connecting");
    [self.chatViewModel transferToAgentServer];
}

#pragma mark - 返回页面事件
- (void)dismissChatViewController {
    
    //隐藏键盘
    [self.chatInputToolBar.chatTextView resignFirstResponder];
    if (self.sdkSetting && !self.chatInputToolBar.isRobotSession) {
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
    [UdeskManager checkHasSurveyWithAgentId:self.chatInputToolBar.agent.agentId completion:^(BOOL hasSurvey,NSError *error) {
        
        //失败
        if (error) {
            [self dismissViewController];
            return ;
        }
        //还未评价
        if (!hasSurvey) {
            //标记满意度只显示一次
            self.backAlreadyDisplayedSurvey = YES;
            [self showSurveyViewWithAgentId:self.chatInputToolBar.agent.agentId];
        }
        else {
            [self dismissViewController];
        }
    }];
}

- (void)dismissViewController {
    
    //离开页面
    if (self.sdkConfig) {
        if (self.sdkConfig.actionConfig.leaveChatViewControllerBlock) {
            self.sdkConfig.actionConfig.leaveChatViewControllerBlock();
        }
    }
    
    //离开页面放弃排队
    if (self.chatInputToolBar.agent.statusType == UDAgentStatusResultQueue) {
        [UdeskManager quitQueueWithType:self.sdkConfig.quitQueueMode];
    }
    //取消所有请求
    [UdeskManager LeaveSDKPage];
    
    //dismiss
    [super dismissChatViewController];
}

#pragma mark - 监听键盘通知做出相应的操作
- (void)subscribeToKeyboard {

    @udWeakify(self);
    [self udSubscribeKeyboardWithBeforeAnimations:nil animations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {

        @udStrongify(self);
        if (self.chatInputToolBar.chatInputType == UdeskChatInputTypeText) {
            //计算键盘的Y
            CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
            CGRect inputViewFrame = self.chatInputToolBar.frame;
            //底部功能栏需要的Y
            CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height + (udIsIPhoneXSeries?34:0);
            //tableview的bottom
            CGFloat messageViewFrameBottom = self.view.udHeight - inputViewFrame.size.height;
            if (inputViewFrameY > messageViewFrameBottom) {
                inputViewFrameY = messageViewFrameBottom;
            }
            //改变底部功能栏frame
            self.chatInputToolBar.frame = CGRectMake(inputViewFrame.origin.x,inputViewFrameY, inputViewFrame.size.width, inputViewFrame.size.height);
            //改变tableview frame
            [self.messageTableView setTableViewInsetsWithBottomValue:self.view.udHeight - self.chatInputToolBar.udY];
            
            if (isShowing) {
                [self.messageTableView scrollToBottomAnimated:NO];
                self.emojiKeyboard.alpha = 0.0;
                self.moreView.alpha = 0.0;
            } else {
                [self.chatInputToolBar.chatTextView resignFirstResponder];
            }
        }
        
    } completion:nil];
}

#pragma mark - 显示功能面板
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    //根据textViewInputViewType切换功能面板
    self.robotTipsView.alpha = 0;
    [self.chatInputToolBar.chatTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.chatInputToolBar.frame;
        __block CGRect otherMenuViewFrame = CGRectMake(0, 0, 0, 0);
        
        CGFloat spacing = 0;
        if (udIsIPhoneXSeries) {
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
            [self.view bringSubviewToFront:self.emojiKeyboard];
        };
        
        void (^MoreViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.moreView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.moreView.alpha = !hide;
            self.moreView.frame = otherMenuViewFrame;
            [self.view bringSubviewToFront:self.moreView];
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
                    MoreViewAnimation(!hide);
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UdeskChatInputTypeVoice: {
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
        
        [self.messageTableView setTableViewInsetsWithBottomValue:self.view.udHeight - self.chatInputToolBar.udY];
        [self.messageTableView scrollToBottomAnimated:NO];
        
    } completion:^(BOOL finished) {
        
        if (hide) {
            self.chatInputToolBar.chatInputType = UdeskChatInputTypeNormal;
        }
    }];
}

#pragma mark - @protocol UdeskRecognizerViewDelegate
- (void)didSendRecognizerVoiceResultText:(NSString *)resultText {
    [self sendTextMessageWithContent:resultText completion:nil];
}

#pragma mark - lazy
//标题栏
- (UdeskChatTitleView *)titleView {
    if (!_titleView) {
        CGFloat titleViewWidth = UD_SCREEN_WIDTH>320?220:185;
        _titleView = [[UdeskChatTitleView alloc] initWithFrame:CGRectMake(0, 0, titleViewWidth, 44)];
    }
    return _titleView;
}

//表情
- (UdeskEmojiKeyboardControl *)emojiKeyboard {
    if (!_emojiKeyboard) {
        _emojiKeyboard = [[UdeskEmojiKeyboardControl alloc] init];
        _emojiKeyboard.delegate = self;
        _emojiKeyboard.backgroundColor = self.sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
        _emojiKeyboard.alpha = 0.0;
        [self.view addSubview:_emojiKeyboard];
    }
    return _emojiKeyboard;
}

//更多
- (UdeskChatToolBarMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[UdeskChatToolBarMoreView alloc] initWithEnableSurvey:self.sdkSetting.enableImSurvey.boolValue enableVideoCall:self.sdkSetting.sdkVCall.boolValue];
        _moreView.backgroundColor = self.sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
        _moreView.alpha = 0.0;
        _moreView.delegate = self;
        [self.view addSubview:_moreView];
    }
    return _moreView;
}

//机器人提示
- (UdeskRobotTipsView *)robotTipsView {
    if (!_robotTipsView) {
        _robotTipsView = [[UdeskRobotTipsView alloc] initWithFrame:CGRectMake(0, UD_SCREEN_HEIGHT, UD_SCREEN_WIDTH, 0) chatInputToolBar:self.chatInputToolBar];
        @udWeakify(self);
        _robotTipsView.didTapRobotTipsBlock = ^(UdeskMessage *message) {
            @udStrongify(self);
            [self.chatInputToolBar.chatTextView setText:nil];
            [self.chatViewModel sendRobotMessage:message completion:^(UdeskMessage *message) {
                [self updateChatMessageUI:message];
            }];
        };
        [self.view addSubview:_robotTipsView];
    }
    return _robotTipsView;
}

//图片选择器
- (UdeskImagePicker *)photographyHelper {
    if (!_photographyHelper) {
        _photographyHelper = [[UdeskImagePicker alloc] init];
    }
    return _photographyHelper;
}

//机器人录音
- (UdeskSpeechRecognizerView *)recognizerView {
    if (!_recognizerView) {
        _recognizerView = [[UdeskSpeechRecognizerView alloc] init];
        _recognizerView.delegate = self;
    }
    return _recognizerView;
}

//录音动画
- (UdeskVoiceRecordView *)voiceRecordView {
    if (!_voiceRecordView) {
        _voiceRecordView = [[UdeskVoiceRecordView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    }
    return _voiceRecordView;
}

//咨询对象
- (UdeskProductView *)productView {
    if (!_productView) {
        _productView = [[UdeskProductView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, kUDProductHeight)];
        @udWeakify(self);
        _productView.didTapProductSendBlock = ^(NSString *productURL) {
            @udStrongify(self);
            //发送咨询对象URL
            if (self.sdkConfig.actionConfig.productMessageSendLinkClickBlock) {
                self.sdkConfig.actionConfig.productMessageSendLinkClickBlock(self,self.sdkConfig.productDictionary);
            }
            else {
                [self sendTextMessageWithContent:productURL completion:nil];
            }
        };
        [self.view addSubview:_productView];
    }
    return _productView;
}

//录音
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat spacing = udIsIPhoneXSeries?34:0;
    
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // remove键盘通知或者手势
    [self udUnsubscribeKeyboard];
    // 停止播放语音
    [[UdeskAudioPlayer shared] stopAudio];
}

- (void)dealloc {
    
    _messageTableView.delegate = nil;
    _messageTableView.dataSource = nil;
}

@end
