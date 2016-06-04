//
//  UdeskMessageInputView.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskMessageInputView.h"
#import "UdeskMessageTableView.h"
#import "UdeskMessageTextView.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UdeskTools.h"

#define ViewHeight 30 //图标大小

@interface UdeskMessageInputView () <UITextViewDelegate,UIActionSheetDelegate>
/**
 *  是否取消錄音
 */
@property (nonatomic, assign, readwrite) BOOL isCancelled;

/**
 *  是否正在錄音
 */
@property (nonatomic, assign, readwrite) BOOL isRecording;
/**
 *  记录TextView的高度
 */
@property (nonatomic, assign) NSInteger textViewHeight;
/**
 *  消息TableView
 */
@property (nonatomic, strong) UdeskMessageTableView *messageTableView;

@end

@implementation UdeskMessageInputView

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UdeskMessageTableView *)tabelView {
    self = [super initWithFrame:frame];
    if (self) {
        
        _messageTableView = tabelView;
        
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
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ViewHeight, ViewHeight)];
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark - 配置输入工具条的样式和布局
- (void)setupMessageInputViewBarWithStyle {
    //语音按钮
    UIButton *voiceChangeButton = [self createButtonWithImage:[UIImage ud_defaultVoiceImage] HLImage:[UIImage ud_defaultVoiceHighlightedImage]];
    [voiceChangeButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    voiceChangeButton.tag = 21;
    [voiceChangeButton setBackgroundImage:[UIImage ud_defaultKeyboardImage] forState:UIControlStateSelected];
    voiceChangeButton.frame = CGRectMake(7, (self.frame.size.height-ViewHeight)/2, ViewHeight, ViewHeight);
    
    [self addSubview:voiceChangeButton];
    
    self.voiceChangeButton = voiceChangeButton;
    
    //图片按钮
    UIButton *multiMediaSendButton = [self createButtonWithImage:[UIImage ud_defaultPhotoImage] HLImage:[UIImage ud_defaultPhotoHighlightedImage]];
    multiMediaSendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [multiMediaSendButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    multiMediaSendButton.tag = 22;
    multiMediaSendButton.frame = CGRectMake(UD_SCREEN_WIDTH-7-ViewHeight, (self.frame.size.height-ViewHeight)/2, ViewHeight, ViewHeight);
    [self addSubview:multiMediaSendButton];
    
    self.multiMediaSendButton = multiMediaSendButton;
    
    // 表情按钮
    UIButton *faceSendButton = [self createButtonWithImage:[UIImage ud_defaultSmileImage] HLImage:[UIImage ud_defaultSmileHighlightedImage]];
    faceSendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [faceSendButton setBackgroundImage:[UIImage ud_defaultKeyboardImage] forState:UIControlStateSelected];
    [faceSendButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    faceSendButton.tag = 23;
    faceSendButton.frame = CGRectMake(multiMediaSendButton.frame.origin.x-ViewHeight-6, (self.frame.size.height-ViewHeight)/2, ViewHeight, ViewHeight);
    [self addSubview:faceSendButton];
    
    self.faceSendButton = faceSendButton;
    
    //初始化输入框
    UdeskMessageTextView *textView = [[UdeskMessageTextView  alloc] initWithFrame:CGRectZero];
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textView.delegate = self;
    
    [self addSubview:textView];
    self.inputTextView = textView;
    
    _inputTextView.frame = CGRectMake(voiceChangeButton.frame.origin.x+voiceChangeButton.frame.size.width+6, (self.frame.size.height-37)/2, (faceSendButton.frame.origin.x)-(voiceChangeButton.frame.origin.x+voiceChangeButton.frame.size.width+13), 37);
    _inputTextView.backgroundColor = Config.textViewColor;
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 4.5f;
    self.backgroundColor = Config.inputViewColor;
    
    // KVO 检查contentSize
    [self.inputTextView addObserver:self
                         forKeyPath:@"contentSize"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
    
    [self.inputTextView setEditable:YES];
    
    // 如果是可以发送语音的，那就需要一个按钮录音的按钮，事件可以在外部添加
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    UIButton *holdDownButton = [self createButtonWithImage:UD_STRETCH_IMAGE([UIImage ud_defaultVoiceInputImage], edgeInsets) HLImage:UD_STRETCH_IMAGE([UIImage ud_defaultVoiceInputHighlightedImage], edgeInsets)];
    [holdDownButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [holdDownButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [holdDownButton setTitle:@"松开 结束"  forState:UIControlStateHighlighted];
    holdDownButton.frame = CGRectMake(voiceChangeButton.frame.origin.x+voiceChangeButton.frame.size.width+6, (self.frame.size.height-37)/2, (faceSendButton.frame.origin.x)-(voiceChangeButton.frame.origin.x+voiceChangeButton.frame.size.width+13), 37);
    holdDownButton.alpha = self.voiceChangeButton.selected;
    [holdDownButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [holdDownButton addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [holdDownButton addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    [self addSubview:holdDownButton];
    self.holdDownButton = holdDownButton;
}

#pragma mark - Action
- (void)sendButtonAction:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
        [self.delegate didSendTextAction:_inputTextView.text];
    }
}

- (void)messageStyleButtonClicked:(UIButton *)sender {
    
    if (_agentCode==2000) {
        
        NSInteger index = sender.tag;
        switch (index) {
            case 21: {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    self.inputedText = self.inputTextView.text;
                    self.inputTextView.text = @"";
                    [self.inputTextView resignFirstResponder];
                } else {
                    self.inputTextView.text = self.inputedText;
                    self.inputedText = nil;
                    [self.inputTextView becomeFirstResponder];
                }
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = sender.selected;
                    self.inputTextView.alpha = !sender.selected;
                } completion:^(BOOL finished) {
                    
                }];
                
                if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                    [self.delegate didChangeSendVoiceAction:sender.selected];
                }
                
                break;
            }
            case 23: {
                sender.selected = !sender.selected;
                self.voiceChangeButton.selected = !sender.selected;
                
                if (!sender.selected) {
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.holdDownButton.alpha = sender.selected;
                        self.inputTextView.alpha = !sender.selected;
                    } completion:^(BOOL finished) {
                        
                    }];
                } else {
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.holdDownButton.alpha = !sender.selected;
                        self.inputTextView.alpha = sender.selected;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
                
                if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                    [self.delegate didSendFaceAction:sender.selected];
                }
                break;
            }
            case 22: {
                
                self.faceSendButton.selected = NO;
                if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction)]) {
                    [self.delegate didSelectedMultipleMediaAction];
                }
                
                NSString *cancelTitle = getUDLocalizedString(@"取消");
                NSString *albumTitle = getUDLocalizedString(@"从相册选取");
                NSString *cameraTitle = getUDLocalizedString(@"拍照");
                
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:cameraTitle,albumTitle , nil];
                [sheet showInView:self.superview];
                
                
                break;
            }
            default:
                break;
        }

    } else {
        
        if ([self.delegate respondsToSelector:@selector(didUDMessageInputView)]) {            
            [self.delegate didUDMessageInputView];
        }
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
                    [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
                }
            }
            break;
        }
        case 1: {
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(sendImageWithSourceType:)]) {
                    [self.delegate sendImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                }
            }
            break;
        }
    }
    actionSheet = nil;
}

- (void)holdDownButtonTouchDown {
    
    if ([UdeskTools canRecord]) {
        
        self.isCancelled = NO;
        self.isRecording = NO;
        if ([self.delegate respondsToSelector:@selector(prepareRecordingVoiceActionWithCompletion:)]) {
            //这边回调 return 的 YES, 或 NO, 可以让底层知道该次录音是否成功, 今儿处理无用的 record 对象
            @udWeakify(self);
            [self.delegate prepareRecordingVoiceActionWithCompletion:^BOOL{
                @udStrongify(self);
                //这边要判断回调回来的时候, 使用者是不是已经早就松开手了
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

}

- (void)holdDownButtonTouchUpOutside {

    //如果已经开始录音了, 才需要做取消的动作, 否则只要切换 isCancelled, 不让录音开始。
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
            [self.delegate didCancelRecordingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownButtonTouchUpInside {

    //如果已经开始录音了, 才需要做取消的动作, 否则只要切换 isCancelled, 不让录音开始。
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
            [self.delegate didFinishRecoingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragOutside {

    //如果已经开始录音了, 才需要做取消的动作, 否则只要切换 isCancelled, 不让录音开始。
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
            [self.delegate didDragOutsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragInside {

    //如果已经开始录音了, 才需要做取消的动作, 否则只要切换 isCancelled, 不让录音开始。
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
            [self.delegate didDragInsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}
#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    
    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText],
                              [self numberOfLines:self.inputTextView.text]);
    
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
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
    return ([UdeskMessageInputView maxLines] + 1.0f) * ViewHeight;
}

#pragma mark - Text view delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (_agentCode == 2000) {
        
        if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
            [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
        }
        self.faceSendButton.selected = NO;
        self.voiceChangeButton.selected = NO;
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
    if (_agentCode == 2000) {
        
        if (!self.textViewHeight)
            self.textViewHeight = [self getTextViewContentH:textView];
        
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
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
        [self layoutAndAnimateMessageInputTextView:object];
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
    CGFloat maxHeight = [UdeskMessageInputView maxHeight];
    
    //获取文字高度
    CGFloat contentH = [self getTextViewContentH:textView];
    
    if (self.textViewHeight==0) {
        self.textViewHeight = 36;
    }
    BOOL isShrinking = contentH < self.textViewHeight;
    
    CGFloat changeInHeight = contentH - self.textViewHeight;
    
    if (!isShrinking && (self.textViewHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.textViewHeight);
    }
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             //改变tableview的frame
                             [_messageTableView setTableViewInsetsWithBottomValue:_messageTableView.contentInset.bottom + changeInHeight];
                             
                             [_messageTableView scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 if (ud_isIOS6) {
                                     self.textViewHeight = MIN(contentH, maxHeight);
                                 }
                                 // 改变textView的frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                             //根据changeInHeight修改inputFunctionView的frame
                             CGRect inputViewFrame = self.frame;
                             self.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if (!isShrinking) {
                                 if (ud_isIOS6) {
                                     self.textViewHeight = MIN(contentH, maxHeight);
                                 }
                                 // 改变textView的frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.textViewHeight = MIN(contentH, maxHeight);
    }
    
    // textView高度为最大时，不再增加previousTextViewContentHeight
    if (self.textViewHeight == maxHeight) {
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

- (void)dealloc {
    
    // remove KVO
    [self.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    
    [self.inputTextView setEditable:NO];
    
    self.inputedText = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;
}

@end
