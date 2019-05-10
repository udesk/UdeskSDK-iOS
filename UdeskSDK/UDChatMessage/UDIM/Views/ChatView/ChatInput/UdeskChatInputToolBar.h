//
//  UdeskChatInputToolBar.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/20.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskAgent.h"
#import "UdeskHPGrowingTextView.h"
#import "UdeskButton.h"

@class UdeskCustomButtonConfig;
@class UdeskCustomToolBar;
@class UdeskMessageTableView;

typedef NS_ENUM(NSUInteger, UdeskChatInputType) {
    UdeskChatInputTypeNormal = 0,
    UdeskChatInputTypeText,
    UdeskChatInputTypeEmotion,
    UdeskChatInputTypeVoice,
    UdeskChatInputTypeMore,
};

@protocol UdeskChatInputToolBarDelegate <NSObject>

/** 输入框将要开始编辑 */
//- (void)chatTextViewShouldBeginEditing:(UdeskHPGrowingTextView *)chatTextView;
/** 发送文本消息，包括系统的表情 */
- (void)didSendText:(NSString *)text;
/** 点击语音 */
- (void)didSelectVoice:(UdeskButton *)voiceButton;
/** 点击表情 */
- (void)didSelectEmotion:(UdeskButton *)emotionButton;
/** 点击更多 */
- (void)didSelectMore:(UdeskButton *)moreButton;
/** 点击UdeskChatInputToolBar */
- (void)didClickChatInputToolBar;
/** 点击自定义按钮 */
- (void)didSelectCustomToolBar:(UdeskCustomToolBar *)toolBar atIndex:(NSInteger)index;
/** 点击自定义评价按钮 */
- (void)didSelectCustomToolBarSurvey:(UdeskCustomToolBar *)toolBar;

/** 准备录音 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion;
/** 开始录音 */
- (void)didStartRecordingVoiceAction;
/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction;
/** 松开手指完成录音 */
- (void)didFinishRecoingVoiceAction;
/** 当手指离开按钮的范围内时 */
- (void)didDragOutsideAction;
/** 当手指再次进入按钮的范围内时 */
- (void)didDragInsideAction;

@end

@interface UdeskChatInputToolBar : UIView

@property (nonatomic, strong) UdeskAgent *agent;

@property (nonatomic, strong) UdeskHPGrowingTextView *chatTextView;

@property (nonatomic, weak  ) id <UdeskChatInputToolBarDelegate> delegate;

@property (nonatomic, assign) UdeskChatInputType chatInputType;

@property (nonatomic, strong) NSArray<UdeskCustomButtonConfig *> *customButtonConfigs;
@property (nonatomic, assign) BOOL enableSurvey;
@property (nonatomic, assign) BOOL isPreSessionMessage;

- (instancetype)initWithFrame:(CGRect)frame tableView:(UdeskMessageTableView *)tabelView;

//重置录音按钮
- (void)resetRecordButton;

//重置所有按钮
- (void)resetAllButtonSelectedStatus;

@end
