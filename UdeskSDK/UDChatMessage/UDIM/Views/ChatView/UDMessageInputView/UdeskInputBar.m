//
//  UdeskInputBar.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/23.
//  Copyright © 2016年 xuchen. All rights reserved.
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

/** 按钮大小 */
static CGFloat const InputBarViewButtonDiameter = 30.0;
/** 输入框高度 */
static CGFloat const InputBarViewHeight = 37.0;
/** 输入框距离顶部的垂直距离 */
static CGFloat const InputBarViewToVerticalEdgeSpacing = 5.0;
/** 输入框距离顶部的横行距离 */
static CGFloat const InputBarViewToHorizontalEdgeSpacing = 10.0;
/** 输入框功能按钮横行的间距 */
static CGFloat const InputBarViewButtonToHorizontalEdgeSpacing = 25.0;
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
    UIView   *lineView;
    UdeskMessageTableView *messageTableView;
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
//        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
    if (hlImage)
//        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
        [button setImage:image forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBarWithStyle {

    //分割线
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, 0.5f)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    
    //初始化输入框
    _inputTextView = [[UdeskMessageTextView  alloc] initWithFrame:CGRectMake(InputBarViewToHorizontalEdgeSpacing, InputBarViewToVerticalEdgeSpacing, UD_SCREEN_WIDTH-InputBarViewToHorizontalEdgeSpacing*2, InputBarViewHeight)];
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.textViewColor;
    self.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.inputViewColor;
    
    // KVO 检查contentSize
    [_inputTextView addObserver:self
                         forKeyPath:@"contentSize"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
    
    [_inputTextView setEditable:YES];

    [self addSubview:_inputTextView];
    
    //表情
    emotionButton = [self createButtonWithImage:[UIImage ud_defaultSmileImage] HLImage:[UIImage ud_defaultSmileHighlightedImage]];
    emotionButton.frame = CGRectMake(InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    [emotionButton addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emotionButton];
    
    //语音
    voiceButton = [self createButtonWithImage:[UIImage ud_defaultVoiceImage] HLImage:[UIImage ud_defaultVoiceHighlightedImage]];
    voiceButton.frame = CGRectMake(emotionButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    [voiceButton addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceButton];
    
    //相机
    cameraButton = [self createButtonWithImage:[UIImage ud_defaultCameraImage] HLImage:[UIImage ud_defaultCameraHighlightedImage]];
    cameraButton.frame = CGRectMake(voiceButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    [cameraButton addTarget:self action:@selector(cameraButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraButton];
    
    //相册
    albumButton = [self createButtonWithImage:[UIImage ud_defaultPhotoImage] HLImage:[UIImage ud_defaultPhotoHighlightedImage]];
    albumButton.frame = CGRectMake(cameraButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
    [albumButton addTarget:self action:@selector(albumButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:albumButton];
    
    //评价(后期做)
    /*
     surveyButton = [self createButtonWithImage:[UIImage ud_defaultSurveyImage] HLImage:[UIImage ud_defaultSurveyHighlightedImage]];
     surveyButton.frame = CGRectMake(albumButton.ud_right+InputBarViewButtonToHorizontalEdgeSpacing, InputBarViewButtonToVerticalEdgeSpacing, InputBarViewButtonDiameter, InputBarViewButtonDiameter);
     [surveyButton addTarget:self action:@selector(surveyButton:) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:surveyButton];
     */
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

    //检查客服状态
    if ([self checkAgentStatusValid]) {
        button.selected = !button.selected;
        if ([self.delegate respondsToSelector:@selector(didSelectVoiceButton:)]) {
            [self.delegate didSelectVoiceButton:button.selected];
        }
    }
}

//点击相机按钮
- (void)cameraButton:(UIButton *)button {
    
    //检查客服状态
    if ([self checkAgentStatusValid]) {
        if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
            [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    }
    
}

//点击相册按钮
- (void)albumButton:(UIButton *)button {

    //检查客服状态
    if ([self checkAgentStatusValid]) {
        if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
            [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    
}

- (void)surveyButton:(UIButton *)button {

    //检查客服状态
    if ([self checkAgentStatusValid]) {
        
        if (self.agent.agentId) {
            [UdeskAgentSurvey.store showAgentSurveyAlertViewWithAgentId:self.agent.agentId completion:^{
                
                //评价提交成功Alert
                if ([self.delegate respondsToSelector:@selector(didSurveyWithMessage:)]) {
                    [self.delegate didSurveyWithMessage:getUDLocalizedString(@"udesk_top_view_thanks_evaluation")];
                    button.selected = !button.selected;
                }
            }];
        }
    }
}

- (BOOL)checkAgentStatusValid {

    if (self.agent.code != UDAgentStatusResultOnline) {
        
        if ([self.delegate respondsToSelector:@selector(didUDMessageInputView)]) {
            [self.delegate didUDMessageInputView];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    
    CGRect lineFrame = lineView.frame;
    
    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText],
                              [self numberOfLines:self.inputTextView.text]);
    
    lineView.frame = CGRectMake(0, lineFrame.origin.y - changeInHeight, lineFrame.size.width, lineFrame.size.height);
    
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          lineView.frame.origin.y+lineView.frame.size.height+InputBarViewToVerticalEdgeSpacing,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    
    self.inputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f,
                                                       (numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f);
    
    self.inputTextView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.inputTextView.contentSize.height - self.inputTextView.bounds.size.height);
        [self.inputTextView setContentOffset:bottomOffset animated:YES];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length - 2, 1)];
    }
}

- (NSUInteger)numberOfLines:(NSString *)text {
    
    return [[text componentsSeparatedByString:@"\n"] count] + 1;
}

+ (CGFloat)maxLines {
    return 3.0f;
}

+ (CGFloat)maxHeight {
    return ([UdeskInputBar maxLines] + 1.0f) * InputBarViewButtonDiameter;
}

#pragma mark - Text view delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.agent.code == UDAgentStatusResultOnline) {
        
        if ([self.inputTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.inputTextView.text isEqualToString:getUDLocalizedString(@"udesk_typing")]) {
            self.inputTextView.text = @"";
            self.inputTextView.textColor = [UIColor blackColor];
        }
        
        if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
            [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
        }
        
        emotionButton.selected = NO;
        voiceButton.selected = NO;
    } else {
        
        if ([self.delegate respondsToSelector:@selector(didUDMessageInputView)]) {
            [self.delegate didUDMessageInputView];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if (self.agent.code == UDAgentStatusResultOnline) {
        
        if (!textViewHeight)
            textViewHeight = [self getTextViewContentH:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    NSDate *nowDate = [NSDate date];
    NSTimeInterval time = [nowDate timeIntervalSinceDate:sendDate];
    if (time>0.5) {
        sendDate = nowDate;
        [UdeskManager sendClientInputtingWithContent:textView.text];
    }
    //输入预知
    if ([UdeskTools isBlankString:textView.text]) {
        [UdeskManager sendClientInputtingWithContent:textView.text];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        //发送出去以后置空输入预知
        [UdeskManager sendClientInputtingWithContent:@""];
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
        }
        return NO;
    }
    return YES;
}

//文字折行KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        
        if (![self.inputTextView.textColor isEqual:[UIColor lightGrayColor]] && ![self.inputTextView.text isEqualToString:getUDLocalizedString(@"udesk_typing")]) {
            [self layoutAndAnimateMessageInputTextView:object];
        }
    }
    
}

#pragma mark - UITextView Helper Method
- (CGFloat)getTextViewContentH:(UITextView *)textView {
    //返回文字高度
    if (ud_isIOS7) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}


#pragma mark - UITextView跟随文字多少变化
- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    //最大高度
    CGFloat maxHeight = [UdeskInputBar maxHeight];
    
    //获取文字高度
    CGFloat contentH = [self getTextViewContentH:textView];
    
    if (textViewHeight==0) {
        textViewHeight = InputBarViewButtonDiameter;
    }
    BOOL isShrinking = contentH < textViewHeight;
    
    CGFloat changeInHeight = contentH - textViewHeight;
    
    if (!isShrinking && (textViewHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - textViewHeight);
    }
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             //改变tableview的frame
                             [messageTableView setTableViewInsetsWithBottomValue:messageTableView.contentInset.bottom + changeInHeight];
                             
                             [messageTableView scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 if (ud_isIOS6) {
                                     textViewHeight = MIN(contentH, maxHeight);
                                 }
                                 // 改变textView的frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                             //根据changeInHeight修改inputFunctionView的frame
                             CGRect inputViewFrame = self.frame;
                             self.frame = CGRectMake(0.0f,
                                                     inputViewFrame.origin.y,
                                                     inputViewFrame.size.width,
                                                     inputViewFrame.size.height + changeInHeight);
                             
                             if (!isShrinking) {
                                 if (ud_isIOS6) {
                                    textViewHeight = MIN(contentH, maxHeight);
                                 }
                                 // 改变textView的frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        textViewHeight = MIN(contentH, maxHeight);
    }
    
    // textView高度为最大时，不再增加previousTextViewContentHeight
    if (textViewHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
    
}

- (void)dealloc
{
        
    // remove KVO
    [self.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    
    [self.inputTextView setEditable:NO];
}

@end
