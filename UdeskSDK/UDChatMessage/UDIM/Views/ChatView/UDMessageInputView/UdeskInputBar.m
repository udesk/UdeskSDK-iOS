//
//  UdeskInputBar.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskInputBar.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKConfig.h"
#import "UdeskFoundationMacro.h"
#import "UdeskViewExt.h"
#import "UdeskManager.h"
#import "UdeskTools.h"
#import "UdeskAgentSurvey.h"
#import "UdeskUtils.h"
#import <AVFoundation/AVFoundation.h>
#import<AssetsLibrary/ALAssetsLibrary.h>

/** 按钮大小 */
static CGFloat const InputBarViewButtonDiameter = 30.0;
/** 输入框高度 */
static CGFloat const InputBarViewHeight = 37.0;
/** 输入框距离顶部的垂直距离 */
static CGFloat const InputBarViewToVerticalEdgeSpacing = 5.0;
/** 输入框距离顶部的横行距离 */
static CGFloat const InputBarViewToHorizontalEdgeSpacing = 10.0;
/** 输入框功能按钮横行的间距 */
static CGFloat const InputBarViewButtonToHorizontalEdgeSpacing = 20.0;
/** 输入框按钮距离顶部的垂直距离 */
static CGFloat const InputBarViewButtonToVerticalEdgeSpacing = 45.0;

@interface UdeskInputBar()<UITextViewDelegate>

@end

@implementation UdeskInputBar {

    UIButton *emotionButton;//表情
    UIButton *voiceButton;//语音
    UIButton *cameraButton;//相机
    UIButton *albumButton;//相册
    UIButton *surveyButton;//评价
    UIButton *locationButton;//地理位置
    UIView   *lineView;
    UdeskMessageTableView *messageTableView;
    CGRect      originalChatViewFrame;
    NSDate  *sendDate;
    NSInteger textViewHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UdeskMessageTableView *)tabelView {
    self = [super initWithFrame:frame];
    if (self) {
        
        messageTableView = tabelView;
        sendDate = [NSDate date];
        [self setup];
    }
    return self;
}

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setup];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBarWithStyle];
    }
}

#pragma mark - layout subViews UI
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, InputBarViewButtonDiameter, InputBarViewButtonDiameter)];
    if (image)
        [button setImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setImage:image forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBarWithStyle {

    //分割线
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, 0.5f)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    
    //初始化输入框
    _inputTextView = [[UdeskHPGrowingTextView  alloc] initWithFrame:CGRectMake(InputBarViewToHorizontalEdgeSpacing, InputBarViewToVerticalEdgeSpacing, UD_SCREEN_WIDTH-InputBarViewToHorizontalEdgeSpacing*2, InputBarViewHeight)];
    _inputTextView.placeholder = getUDLocalizedString(@"udesk_typing");
    _inputTextView.delegate = (id)self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.textViewColor;
    self.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.inputViewColor;
    [self addSubview:_inputTextView];
    
    //所有都隐藏了
    if (self.hiddenEmotionButton && self.hiddenVoiceButton && self.hiddenCameraButton && self.hiddenAlbumButton && !self.enableImSurvey.boolValue) {
        [self updateInputBarForLeaveMessage];
        return;
    }
    
    //表情
    emotionButton = [self createButtonWithImage:[UIImage ud_defaultSmileImage] HLImage:[UIImage ud_defaultSmileHighlightedImage]];
    emotionButton.frame = CGRectMake(InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    emotionButton.hidden = self.hiddenEmotionButton;
    [emotionButton addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emotionButton];
    
    //语音
    voiceButton = [self createButtonWithImage:[UIImage ud_defaultVoiceImage] HLImage:[UIImage ud_defaultVoiceHighlightedImage]];
    CGFloat voiceButtonX = emotionButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing;
    if (self.hiddenEmotionButton) {
        voiceButtonX = InputBarViewButtonToHorizontalEdgeSpacing;
    }
    voiceButton.frame = CGRectMake(voiceButtonX, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    voiceButton.hidden = self.hiddenVoiceButton;
    [voiceButton addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceButton];
    
    //相机
    cameraButton = [self createButtonWithImage:[UIImage ud_defaultCameraImage] HLImage:[UIImage ud_defaultCameraHighlightedImage]];
    
    CGFloat cameraButtonX = InputBarViewButtonToHorizontalEdgeSpacing + voiceButton.ud_right;
    if (self.hiddenVoiceButton) {
        cameraButtonX = cameraButtonX - voiceButton.ud_right + emotionButton.ud_right;
        if (self.hiddenEmotionButton) {
            cameraButtonX = InputBarViewButtonToHorizontalEdgeSpacing;
        }
    }

    cameraButton.frame = CGRectMake(cameraButtonX, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    cameraButton.hidden = self.hiddenCameraButton;
    [cameraButton addTarget:self action:@selector(cameraClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraButton];
    
    CGFloat albumButtonX = cameraButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing;
    if (self.hiddenCameraButton) {
        albumButtonX = albumButtonX - cameraButton.ud_right + voiceButton.ud_right;
        if (self.hiddenVoiceButton) {
            albumButtonX = albumButtonX - voiceButton.ud_right + emotionButton.ud_right;
            if (self.hiddenEmotionButton) {
                albumButtonX = InputBarViewButtonToHorizontalEdgeSpacing;
            }
        }
    }

    //相册
    albumButton = [self createButtonWithImage:[UIImage ud_defaultPhotoImage] HLImage:[UIImage ud_defaultPhotoHighlightedImage]];
    albumButton.frame = CGRectMake(albumButtonX, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    albumButton.hidden = self.hiddenAlbumButton;
    [albumButton addTarget:self action:@selector(albumClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:albumButton];
    
    CGFloat surveyButtonX = albumButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing;
    if (self.hiddenAlbumButton) {
        surveyButtonX = surveyButtonX - albumButton.ud_right + cameraButton.ud_right;
        if (self.hiddenCameraButton) {
            surveyButtonX = surveyButtonX - cameraButton.ud_right + voiceButton.ud_right;
            if (self.hiddenVoiceButton) {
                surveyButtonX = surveyButtonX - voiceButton.ud_right + emotionButton.ud_right;
                if (self.hiddenEmotionButton) {
                    surveyButtonX = InputBarViewButtonToHorizontalEdgeSpacing;
                }
            }
        }
    }
    
    //评价
    surveyButton = [self createButtonWithImage:[UIImage ud_defaultSurveyImage] HLImage:[UIImage ud_defaultSurveyHighlightedImage]];
    surveyButton.frame = CGRectMake(surveyButtonX, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    surveyButton.hidden = !self.enableImSurvey.boolValue;
    [surveyButton addTarget:self action:@selector(surveyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:surveyButton];
    
    CGFloat locationButtonX = surveyButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing;
    if (!self.enableImSurvey.boolValue) {
        locationButtonX = locationButtonX - surveyButton.ud_right + albumButton.ud_right;
        if (self.hiddenAlbumButton) {
            locationButtonX = locationButtonX - albumButton.ud_right + voiceButton.ud_right;
            if (self.hiddenCameraButton) {
                locationButtonX = locationButtonX - cameraButton.ud_right + voiceButton.ud_right;
                if (self.hiddenVoiceButton) {
                    locationButtonX = locationButtonX - voiceButton.ud_right + emotionButton.ud_right;
                    if (self.hiddenEmotionButton) {
                        locationButtonX = InputBarViewButtonToHorizontalEdgeSpacing;
                    }
                }
            }
        }
    }
    
    locationButton = [self createButtonWithImage:[UIImage ud_defaultLocationImage] HLImage:[UIImage ud_defaultLocationHighlightedImage]];
    locationButton.frame = CGRectMake(locationButtonX, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    locationButton.hidden = self.hiddenLocationButton;
    [locationButton addTarget:self action:@selector(locationClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:locationButton];
}

//点击表情按钮
- (void)emotionClick:(UIButton *)button {
    
    //检查客服状态
    if ([self checkAgentStatusValid]) {
        button.selected = !button.selected;
        if ([self.delegate respondsToSelector:@selector(didSelectEmotionButton:)]) {
            [self.delegate didSelectEmotionButton:button.selected];
        }
    }
}

//点击语音
- (void)voiceClick:(UIButton *)button {
    
    if (ud_isIOS7)
    {
    
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                // 用户同意获取数据
                //检查客服状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self checkAgentStatusValid]) {
                        button.selected = !button.selected;
                        if ([self.delegate respondsToSelector:@selector(didSelectVoiceButton:)]) {
                            [self.delegate didSelectVoiceButton:button.selected];
                        }
                    }
                });
                
            } else {
                // 可以显示一个提示框告诉用户这个app没有得到允许？
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:getUDLocalizedString(@"udesk_microphone_denied")
                                               delegate:nil
                                      cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                });
                
            }
        }];
    }
    else {
        if ([self checkAgentStatusValid]) {
            button.selected = !button.selected;
            if ([self.delegate respondsToSelector:@selector(didSelectVoiceButton:)]) {
                [self.delegate didSelectVoiceButton:button.selected];
            }
        }
    }
}

//点击相机按钮
- (void)cameraClick:(UIButton *)button {
    
    //检查客服状态
    if ([self checkAgentStatusValid]) {
        if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
            [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    }
}

//点击相册按钮
- (void)albumClick:(UIButton *)button {
    
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (*stop) {
                //点击“好”回调方法
                //检查客服状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self checkAgentStatusValid]) {
                        if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
                            [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                        }
                    }
                });
                return;
            }
            *stop = TRUE;
            
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:getUDLocalizedString(@"udesk_album_denied")
                                           delegate:nil
                                  cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                  otherButtonTitles:nil] show];
#pragma clang diagnostic pop
            });
        }];
    }
    else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        
        if ([self checkAgentStatusValid]) {
            if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
                [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
        }
    }
    else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
    
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:getUDLocalizedString(@"udesk_album_denied")
                                       delegate:nil
                              cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                              otherButtonTitles:nil] show];
#pragma clang diagnostic pop
        });
    }
    
}

- (void)locationClick:(UIButton *)button {

    //检查客服状态
    if ([self checkAgentStatusValid]) {
        button.selected = !button.selected;
        if ([self.delegate respondsToSelector:@selector(didSelectLocationButton:)]) {
            [self.delegate didSelectLocationButton:button.selected];
        }
    }
}

//点击评价
- (void)surveyClick:(UIButton *)button {

    //先将未到时间执行前的任务取消。
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(showAgentSurvey:) object:button];
    [self performSelector:@selector(showAgentSurvey:) withObject:button afterDelay:0.35f];
}

- (void)showAgentSurvey:(UIButton *)button {

    //检查客服状态
    if ([self checkAgentStatusValid]) {
        
        if (self.agent.agentId) {
            
            UdeskAgentSurvey *agentSurvey = [UdeskAgentSurvey survey];
            [agentSurvey checkHasSurveyWithAgentId:self.agent.agentId completion:^(NSString *hasSurvey,NSError *error) {
                
                if (![hasSurvey boolValue]) {
                    
                    [agentSurvey showAgentSurveyAlertViewWithAgentId:self.agent.agentId isShowErrorAlert:YES completion:^(BOOL result, NSError *error){
                        
                        //评价提交成功Alert
                        if ([self.delegate respondsToSelector:@selector(didSurveyWithMessage:hasSurvey:)]) {
                            [self.delegate didSurveyWithMessage:getUDLocalizedString(@"udesk_top_view_thanks_evaluation") hasSurvey:NO];
                            button.selected = !button.selected;
                        }
                    }];
                }
                else {
                    
                    [self.delegate didSurveyWithMessage:getUDLocalizedString(@"udesk_has_survey")  hasSurvey:YES];
                }
            }];
        }
    }
}

- (BOOL)checkAgentStatusValid {

    if (self.agent.code != UDAgentStatusResultOnline &&
        self.agent.code != UDAgentStatusResultLeaveMessage) {
        
        if ([self.delegate respondsToSelector:@selector(didUDMessageInputView)]) {
            [self.delegate didUDMessageInputView];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Text view delegate
- (void)growingTextViewDidChange:(UdeskHPGrowingTextView *)growingTextView {

    NSDate *nowDate = [NSDate date];
    NSTimeInterval time = [nowDate timeIntervalSinceDate:sendDate];
    if (time>0.5) {
        sendDate = nowDate;
        [UdeskManager sendClientInputtingWithContent:growingTextView.text];
    }
    //输入预知
    if ([UdeskTools isBlankString:growingTextView.text]) {
        [UdeskManager sendClientInputtingWithContent:growingTextView.text];
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    
    if ([self.inputTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.inputTextView.text isEqualToString:getUDLocalizedString(@"udesk_typing")]) {
        self.inputTextView.text = @"";
        self.inputTextView.textColor = [UIColor blackColor];
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    emotionButton.selected = NO;
    voiceButton.selected = NO;
    
    return YES;
}

- (void)growingTextViewDidBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView becomeFirstResponder];
}

- (void)growingTextViewDidEndEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView resignFirstResponder];
}

- (BOOL)growingTextView:(UdeskHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        //发送出去以后置空输入预知
        if ([self checkAgentStatusValid]) {
            [UdeskManager sendClientInputtingWithContent:@""];
            if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
                [self.delegate didSendTextAction:growingTextView.text];
            }
            return NO;
        }
    }
    return YES;
}

- (void)growingTextView:(UdeskHPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff     = (self.inputTextView.frame.size.height - height);
    //确保tableView的y不大于原始的y
    CGFloat tableViewOriginY = messageTableView.frame.origin.y + diff;
    if (tableViewOriginY > originalChatViewFrame.origin.y) {
        tableViewOriginY = originalChatViewFrame.origin.y;
    }
    messageTableView.frame = CGRectMake(messageTableView.frame.origin.x, tableViewOriginY, messageTableView.frame.size.width, messageTableView.frame.size.height);
    self.frame     = CGRectMake(0, self.frame.origin.y + diff, self.frame.size.width, self.frame.size.height - diff);
    
    //按钮靠下
    [self reFramefunctionBtnAfterTextViewChange];
}

- (void)reFramefunctionBtnAfterTextViewChange
{
    CGFloat buttonY = self.ud_height-InputBarViewToVerticalEdgeSpacing-InputBarViewButtonDiameter;
    
    emotionButton.frame = CGRectMake(InputBarViewButtonToHorizontalEdgeSpacing, buttonY, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    voiceButton.frame = CGRectMake(emotionButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, buttonY, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    cameraButton.frame = CGRectMake(voiceButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, buttonY, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    albumButton.frame = CGRectMake(cameraButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, buttonY, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    surveyButton.frame = CGRectMake(albumButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, buttonY, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    
    CGFloat locationButtonX = surveyButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing;
    if (!self.enableImSurvey.boolValue) {
        locationButtonX = locationButtonX - surveyButton.ud_right + albumButton.ud_right;
    }
    
    locationButton.frame = CGRectMake(locationButtonX, buttonY, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
}

//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage {
    
    if (self.ud_height == 50.f) {
        return;
    }
    if (emotionButton) {
        emotionButton.hidden = YES;
    }
    if (voiceButton) {
        voiceButton.hidden = YES;
    }
    if (cameraButton) {
        cameraButton.hidden = YES;
    }
    if (albumButton) {
        albumButton.hidden = YES;
    }
    if (surveyButton) {
        surveyButton.hidden = YES;
    }
    if (locationButton) {
        locationButton.hidden = YES;
    }
    
    CGFloat inputViewHeight = 50.f;
    self.ud_height = inputViewHeight;
    self.ud_y += 30;
    [messageTableView setTableViewInsetsWithBottomValue:inputViewHeight];
}

//隐藏满意度
- (void)setEnableImSurvey:(NSNumber *)enableImSurvey {

    _enableImSurvey = enableImSurvey;
    if (surveyButton) {
        surveyButton.hidden = enableImSurvey.boolValue;
    }
}

//隐藏相册
- (void)setHiddenAlbumButton:(BOOL)hiddenAlbumButton {
    
    _hiddenAlbumButton = hiddenAlbumButton;
    if (albumButton) {
        albumButton.hidden = hiddenAlbumButton;
        surveyButton.frame = CGRectMake(cameraButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    }
}

//隐藏语音
- (void)setHiddenVoiceButton:(BOOL)hiddenVoiceButton {
    
    _hiddenVoiceButton = hiddenVoiceButton;
    if (voiceButton) {
        voiceButton.hidden = hiddenVoiceButton;
        cameraButton.frame = CGRectMake(emotionButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
        albumButton.frame = CGRectMake(cameraButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
        surveyButton.frame = CGRectMake(albumButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    }
}

//隐藏表情
- (void)setHiddenEmotionButton:(BOOL)hiddenEmotionButton {
    
    _hiddenEmotionButton = hiddenEmotionButton;
    if (emotionButton) {
        emotionButton.hidden = hiddenEmotionButton;
        voiceButton.frame = CGRectMake(InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
        cameraButton.frame = CGRectMake(voiceButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
        albumButton.frame = CGRectMake(cameraButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
        surveyButton.frame = CGRectMake(albumButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    }
}

//隐藏相机
- (void)setHiddenCameraButton:(BOOL)hiddenCameraButton {
    
    _hiddenCameraButton = hiddenCameraButton;
    if (cameraButton) {
        cameraButton.hidden = hiddenCameraButton;
        albumButton.frame = CGRectMake(voiceButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
        surveyButton.frame = CGRectMake(albumButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
