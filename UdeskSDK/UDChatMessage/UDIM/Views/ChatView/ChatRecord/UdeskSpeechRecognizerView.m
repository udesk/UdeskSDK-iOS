//
//  UdeskSpeechRecognizerView.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/8.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskSpeechRecognizerView.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "UIView+UdeskSDK.h"
#import "UdeskSDKMacro.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskHPGrowingTextView.h"
#import "UdeskChatViewController.h"
#import "UdeskSpeechRecognizerViewController.h"

#if __has_include("BDSEventManager.h")
#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#endif

//#error "请在官网新建应用，配置包名，并在此填写应用的 api key, secret key, appid(即appcode)"
const NSString* API_KEY = @"ESomnKOLskqGespGtvIBD7jm";
const NSString* SECRET_KEY = @"RAA2u215ynjzoNE78kLOmZDfhTGcZQ73";
const NSString* APP_ID = @"15212039";

const CGFloat udRecognizerContentViewHeight = 320;
const CGFloat udRecognizerTextViewHeight = 120;
const CGFloat udRecognizerTextViewEditHeight = 250;

@interface UdeskSpeechRecognizerView()

@property (nonatomic, strong) UdeskHPGrowingTextView *textView;
@property (nonatomic, strong) UIButton   *closeButton;
@property (nonatomic, strong) UIButton   *cleanButton;
@property (nonatomic, strong) UIButton   *sendButton;
@property (nonatomic, strong) UILabel    *tipLabel;
@property (nonatomic, strong) UIView     *recordView;
@property (nonatomic, strong) CALayer    *volumeLayer;

@property (nonatomic, strong) UIButton   *collapseButton;
@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UIView     *lineView;

@property (nonatomic, copy  ) NSString   *temporaryText;

@property (nonatomic, strong) UdeskSpeechRecognizerViewController *recognizerController;

#if __has_include("BDSEventManager.h")
@property (nonatomic, strong) BDSEventManager *asrEventManager;
#endif

@end

@implementation UdeskSpeechRecognizerView

- (instancetype)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        
        [self setupUI];
        [self configVoiceRecognitionClient];
    }
    return self;
}

- (void)configVoiceRecognitionClient {
    
#if __has_include("BDSEventManager.h")
    // 创建语音识别对象
    self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    // 设置语音识别代理
    [self.asrEventManager setDelegate:self];
    // 参数配置：在线身份验证
    [self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    // 设置 APPID
    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    // 开启长语音
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    // 长语音请务必开启本地VAD
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
    
    
    //    NSString *mfe_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_dnn" ofType:@"dat"];
    //    //设置MFE模型文件
    //    [self.asrEventManager setParameter:mfe_dnn_filepath forKey:BDS_ASR_MFE_DNN_DAT_FILE];
    //    NSString *cmvn_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_cmvn" ofType:@"dat"];
    //    //设置MFE CMVN文件路径
    //    [self.asrEventManager setParameter:cmvn_dnn_filepath forKey:BDS_ASR_MFE_CMVN_DAT_FILE];
    //    [self.asrEventManager setParameter:@(1001.f) forKey:BDS_ASR_MFE_MAX_SPEECH_PAUSE];
    //    [self.asrEventManager setParameter:@(1000.f) forKey:BDS_ASR_MFE_MAX_WAIT_DURATION];
    
    // 开启离线语义(本地语义)
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU];
    // 开启在线语义
    [self.asrEventManager setParameter:@"15363" forKey:BDS_ASR_PRODUCT_ID];
#endif
}

- (void)setupUI {
    
    //导航
    _navView = [[UIView alloc] initWithFrame:CGRectZero];
    _navView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_navView];
    
    //收起按钮
    _collapseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _collapseButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_collapseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_collapseButton setTitle:getUDLocalizedString(@"udesk_collapse") forState:UIControlStateNormal];
    [_collapseButton addTarget:self action:@selector(closeEditContentAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_collapseButton];
    
    //标题
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.text = getUDLocalizedString(@"udesk_edit_content");
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navView addSubview:_titleLabel];
    
    //分割线
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = [UIColor colorWithRed:0.965f  green:0.969f  blue:0.969f alpha:1];
    [_navView addSubview:_lineView];
    
    //内容
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, UD_SCREEN_HEIGHT-udRecognizerContentViewHeight, UD_SCREEN_WIDTH, udRecognizerContentViewHeight)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    _textView = [[UdeskHPGrowingTextView alloc] initWithFrame:CGRectMake(10, 12, UD_SCREEN_WIDTH-(16*2), udRecognizerTextViewHeight)];
    _textView.minHeight = udRecognizerTextViewHeight;
    _textView.font = [UIFont systemFontOfSize:18];
    [_contentView addSubview:_textView];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _textView.udBottom+(udIsIPhoneXSeries?38:68), UD_SCREEN_WIDTH, 15)];
    _tipLabel.font = [UIFont systemFontOfSize:14];
    _tipLabel.textColor = [UIColor colorWithRed:0.376f  green:0.38f  blue:0.384f alpha:1];
    _tipLabel.text = getUDLocalizedString(@"udesk_hold_to_talk");
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_tipLabel];
    
    _recordView = [[UIView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH - 60) / 2, _tipLabel.udBottom+20, 60, 60)];
    _recordView.backgroundColor = [UIColor colorWithRed:0.922f  green:0.922f  blue:0.922f alpha:1];
    [_recordView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    _recordView.layer.cornerRadius = 60 / 2;
    [_contentView addSubview:_recordView];
    
    UIImageView *micImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:getUDBundlePath(@"udRobotVoice.png")]];
    micImageView.frame = CGRectMake(0, 0, 60, 60);
    [micImageView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
    [_recordView addSubview:micImageView];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    longGesture.delaysTouchesBegan = NO;
    longGesture.delaysTouchesEnded = NO;
    longGesture.minimumPressDuration = 0;
    [_recordView addGestureRecognizer:longGesture];
    
    _volumeLayer = [CALayer layer];
    _volumeLayer.opacity = 0.25;
    _volumeLayer.backgroundColor = [UIColor colorWithRed:0.675f  green:0.792f  blue:0.965f alpha:1].CGColor;
    [self changeVolumeLayerDiameter:_volumeLayer.frame.size.width];
    [_contentView.layer insertSublayer:_volumeLayer below:_recordView.layer];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(58, _recordView.udTop, 26, 26);
    _closeButton.udCenterY = _recordView.udCenterY;
    [_closeButton setImage:[UIImage imageWithContentsOfFile:getUDBundlePath(@"udDown.png")] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeRecognizerAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_closeButton];
    
    NSString *cleanText = getUDLocalizedString(@"udesk_clean");
    CGFloat cleanWidth = [UdeskStringSizeUtil textSize:cleanText withFont:[UIFont systemFontOfSize:18] withSize:CGSizeMake(CGFLOAT_MAX, 25)].width;
    
    _cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cleanButton.frame = CGRectMake(58, _recordView.udTop, cleanWidth, 25);
    _cleanButton.udCenterY = _recordView.udCenterY;
    _cleanButton.hidden = YES;
    [_cleanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cleanButton setTitle:cleanText forState:UIControlStateNormal];
    [_cleanButton addTarget:self action:@selector(cleanRecognizerAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_cleanButton];
    
    NSString *sendText = getUDLocalizedString(@"udesk_send");
    CGFloat sendWidth = [UdeskStringSizeUtil textSize:cleanText withFont:[UIFont systemFontOfSize:18] withSize:CGSizeMake(CGFLOAT_MAX, 25)].width;
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(UD_SCREEN_WIDTH-58-sendWidth, _recordView.udTop, sendWidth, 25);
    _sendButton.udCenterY = _recordView.udCenterY;
    _sendButton.hidden = YES;
    [_sendButton setTitleColor:[UIColor colorWithRed:0.188f  green:0.478f  blue:0.91f alpha:1] forState:UIControlStateNormal];
    [_sendButton setTitle:sendText forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendRecognizerAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_sendButton];
}

- (void)closeRecognizerAction:(UIButton *)button {
    
    [self dismiss];
    [self cleanRecognizerAction:nil];
}

- (void)cleanRecognizerAction:(UIButton *)button {
    
    self.textView.text = nil;
    self.textView.placeholder = nil;
    self.cleanButton.hidden = YES;
    self.sendButton.hidden = YES;
    self.closeButton.hidden = NO;
    self.temporaryText = nil;
}

- (void)sendRecognizerAction:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRecognizerVoiceResultText:)]) {
        [self.delegate didSendRecognizerVoiceResultText:self.textView.text];
    }
    
    [self closeRecognizerAction:nil];
}

- (void)changeVolumeLayerDiameter:(CGFloat)dia_ {
    
    CGFloat dia = _recordView.frame.size.width + dia_;
    CGRect frame = CGRectMake(_recordView.center.x - dia/2, _recordView.center.y - dia/2, dia, dia);
    _volumeLayer.frame = frame;
    _volumeLayer.cornerRadius = dia/2;
    _volumeLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
}

- (void)panGestureRecognizerAction:(UIGestureRecognizer *)sender {
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        [self startWorking];
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self stopWorking];
    }
}

- (void)startWorking {
    
    self.tipLabel.hidden = YES;
    self.closeButton.hidden = YES;
    self.cleanButton.hidden = YES;
    self.sendButton.hidden = YES;
#if __has_include("BDSEventManager.h")
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
#endif
}

- (void)stopWorking {
    
    self.tipLabel.hidden = NO;
    self.closeButton.hidden = YES;
    self.cleanButton.hidden = NO;
    self.sendButton.hidden = NO;
#if __has_include("BDSEventManager.h")
    [self.asrEventManager sendCommand:BDS_ASR_CMD_STOP];
#endif
    [self changeVolumeLayerDiameter:0];
    
    if (self.textView.text.length == 0) {
        [self cleanRecognizerAction:nil];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.navView.frame = CGRectMake(0, self.editable?0:UD_SCREEN_HEIGHT, UD_SCREEN_WIDTH, udIsIPhoneXSeries?88:64);
    
    CGFloat buttonWidth = [UdeskStringSizeUtil textSize:self.collapseButton.titleLabel.text withFont:[UIFont systemFontOfSize:15] withSize:CGSizeMake(CGFLOAT_MAX, 25)].width;
    self.collapseButton.frame = CGRectMake(16, self.navView.udBottom-11-25, buttonWidth, 25);
    
    CGFloat width = [UdeskStringSizeUtil textSize:self.titleLabel.text withFont:[UIFont systemFontOfSize:17] withSize:CGSizeMake(CGFLOAT_MAX, 25)].width;
    self.titleLabel.frame = CGRectMake((UD_SCREEN_WIDTH-width)/2, self.navView.udBottom-13-25, width, 25);
    
    self.contentView.frame = CGRectMake(0, self.editable?self.navView.udBottom:(UD_SCREEN_HEIGHT-udRecognizerContentViewHeight), UD_SCREEN_WIDTH, self.editable?(UD_SCREEN_HEIGHT-self.navView.udHeight):udRecognizerContentViewHeight);
    self.textView.frame = CGRectMake(10, 12, UD_SCREEN_WIDTH-(16*2), self.editable?udRecognizerTextViewEditHeight:udRecognizerTextViewHeight);
    self.textView.minHeight = self.editable?udRecognizerTextViewEditHeight:udRecognizerTextViewHeight;
}

#if __has_include("BDSEventManager.h")
#pragma mark - MVoiceRecognitionClientDelegate
- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj {
    
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            self.textView.placeholder = getUDLocalizedString(@"udesk_please_talk");
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            if (aObj) {
                NSArray *results = aObj[@"results_recognition"];
                NSLog(@"EVoiceRecognitionClientWorkStatusFlushData===================%@",results.firstObject);
                if ([results isKindOfClass:[NSArray class]]) {
                    if (![UdeskSDKUtil isBlankString:self.temporaryText]) {
                        self.textView.text = [self.temporaryText stringByAppendingString:results.firstObject];
                    }
                    else {
                        self.textView.text = results.firstObject;
                    }
                }
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            
            NSArray *results = aObj[@"results_recognition"];
            NSLog(@"EVoiceRecognitionClientWorkStatusFinish===================%@",results.firstObject);
            self.temporaryText = [UdeskSDKUtil isBlankString:self.temporaryText]?results.firstObject:[self.temporaryText stringByAppendingString:results.firstObject];
            self.textView.text = self.temporaryText;
            [self changeVolumeLayerDiameter:0];
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            [self changeVolumeLayerDiameter:[aObj floatValue]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            [self onEnd];
            break;
        }
        default:
            break;
    }
}
#endif

- (void)onEnd {
    
    if (self.textView.text.length == 0) {
        [self cleanRecognizerAction:nil];
        self.tipLabel.hidden = NO;
    }
    else {
        self.tipLabel.hidden = NO;
        self.closeButton.hidden = YES;
        self.cleanButton.hidden = NO;
        self.sendButton.hidden = NO;
    }
    [self changeVolumeLayerDiameter:0];
}

- (void)dismiss {
    [_recognizerController dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    [_recognizerController dismissWithCompletion:completion];
}

- (void)show {
    [self showWithCompletion:nil];
}

- (void)showWithCompletion:(void (^)(void))completion {
    
    if ([[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskSpeechRecognizerViewController class]]) {
        return;
    }
    
    if (![[UdeskSDKUtil currentViewController] isKindOfClass:[UdeskChatViewController class]]) {
        return;
    }
    
    _recognizerController = [[UdeskSpeechRecognizerViewController alloc] init];
    [_recognizerController showRecognizerView:self completion:completion];
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)closeEditContentAction:(UIButton *)button {
    
    self.navView.udTop = UD_SCREEN_HEIGHT;
    self.contentView.udTop = UD_SCREEN_HEIGHT-330;
    
    self.temporaryText = self.textView.text;
    [self.textView resignFirstResponder];
}

- (void)startEditContent {
    
    self.closeButton.hidden = YES;
    self.cleanButton.hidden = YES;
    self.sendButton.hidden = YES;
    self.recordView.hidden = YES;
    self.tipLabel.hidden = YES;
    self.volumeLayer.hidden = YES;
    
    [self setNeedsLayout];
}

- (void)stopEditContent {
    
    if (self.textView.text.length > 0) {
        self.closeButton.hidden = YES;
        self.cleanButton.hidden = NO;
        self.sendButton.hidden = NO;
    }
    else {
        self.closeButton.hidden = NO;
        self.cleanButton.hidden = YES;
        self.sendButton.hidden = YES;
    }
    
    self.recordView.hidden = NO;
    self.tipLabel.hidden = NO;
    self.volumeLayer.hidden = NO;
    
    [self setNeedsLayout];
}

@end
